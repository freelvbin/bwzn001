from scipy import signal
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import sys
import os
import struct
import math

def get_file_buffer(file, start=0, end=0):
    file_length = os.path.getsize(file)
    with open(file, 'rb') as target_file:
        if start > 0:
            start = start % file_length
            target_file.seek(start)
        if end == 0:
            end = 65536 #int(config['Default']['downloadSize'])
        end = end % file_length
        if end > 0:
            buffer0 = target_file.read(end)
            buffer = struct.unpack('h'*int(end/2), buffer0)
        else:
            buffer = target_file.read()
    return buffer
'''
% % 下变频产生星座图
lpFilt = designfilt('lowpassfir', 'PassbandFrequency', 0.3, ...
'StopbandFrequency', 0.4, 'PassbandRipple', 0.5, ...
'StopbandAttenuation', 65, 'DesignMethod', 'kaiserwin');
% % 混频 + 滤波
msg_detect_I_mix = InSig. * cos((2 * pi * fc * (1:length(InSig))'/fs)); % 混频
msg_detect_Q_mix = InSig. * sin((2 * pi * fc * (1:length(InSig))'/fs));
msg_detect_I = filter(lpFilt, msg_detect_I_mix); % 低通滤波
msg_detect_Q = filter(lpFilt, msg_detect_Q_mix); % 低通滤波
msg_detect_IQ = msg_detect_I + 1i * msg_detect_Q;
scatterplot(msg_detect_IQ(floor(sps / 2): sps:end))
'''
def scatter_plot(buffer, filter_coff, Fs, fc, sps):
    length_buffer = len(buffer)
    x = np.linspace(0, (length_buffer - 1) / Fs, length_buffer)
    y_sin = np.sin(2 * fc * np.pi * x)
    y_cos = np.cos(2 * fc * np.pi * x)

    msg_detect_I_mix = buffer * y_sin
    msg_detect_Q_mix = buffer * y_cos

    msg_detect_I = signal.lfilter(filter_coff, 1, msg_detect_I_mix)
    msg_detect_Q = signal.lfilter(filter_coff, 1, msg_detect_Q_mix)

    startpoint = math.floor(sps/2)-1

    scatter_I = [(msg_detect_I[idx]) for idx in range(startpoint, len(msg_detect_I), sps)]
    scatter_Q = [(msg_detect_Q[idx]) for idx in range(startpoint, len(msg_detect_Q), sps)]

    plt.plot(scatter_I, scatter_Q, '*')
    plt.legend()
    plt.show()
    return scatter_I, scatter_Q
'''
频谱生成，频谱生成

'''
def get_power_spectral(modulation_id, sampling_rate, power=1, rate_type =1, file=''):

    # fft_size = int(config['PowerSpectrum']['fftSize'])#LB
    # end_index = int(config['PowerSpectrum']['flatFrameCount']) * fft_size #LB
    # buffer = get_coded_data('modulation', modulation_id, 0, end_index * 4) #LB


    if (rate_type == 3): # 抽样率
        deciRatio = 1
    elif (rate_type == 2):
        deciRatio = 8
    else:
        deciRatio = 64

    fft_size = 4096 #LB FFT点数
    end_index = 16*fft_size*deciRatio #LB 读取的文件长度
    data = get_file_buffer(file, 0, end_index) #LB 读取文件

    # data = struct.unpack('f' * int(len(buffer) / 4), buffer)#LB
    # buffer = get_coded_data('modulation', modulation_id, 0, end_index * 2)#LB
    # data = struct.unpack('h' * int(len(buffer) / 2), buffer)#LB
    if(power == 1): # 频谱
        data = np.power(data, power)
        x, y = signal.welch(data, sampling_rate, 'flattop', int(fft_size), scaling='spectrum')
    else:
        fc = 10000000 # 中心频率
        length_buffer = len(data)
        x = np.linspace(0, (length_buffer - 1) / sampling_rate, length_buffer)
        y_sin = np.sin(2 * fc * np.pi * x)
        y_cos = np.cos(2 * fc * np.pi * x)
        msg_detect_I_mix = data * y_sin #I路混频
        msg_detect_Q_mix = data * y_cos  #Q路混频
        filter_coff = [5.06834558206252e-05, -7.93729475878489e-05, -0.000220263432809440, -0.000117162797594676,
                       0.000266126266220123, 0.000519394429735287, 0.000159172391563387, -0.000650560955099894,
                       -0.000977610053620608, -0.000101429140720271, 0.00133238648357355, 0.00159560380094689,
                       -0.000174389098990111, -0.00242117752566539, -0.00233426650031818, 0.000834524632462554,
                       0.00402674588773692, 0.00310095778394608, -0.00209798382355121, -0.00625209009980773,
                       -0.00373637547558407, 0.00424860486002572, 0.00919635753043972, 0.00399762447900587,
                       -0.00767266480793567, -0.0129822576070143, -0.00352184517255624, 0.0129705263655936,
                       0.0178435336564948, 0.00172000204362927, -0.0212952667598293, -0.0243904370222594,
                       0.00258969725694249, 0.0355490066200026, 0.0346001216136025, -0.0128198242530558,
                       -0.0664125560950126, -0.0578295432729489, 0.0482054244956093, 0.210753713100735,
                       0.332526869687875,
                       0.332526869687875, 0.210753713100735, 0.0482054244956093, -0.0578295432729489,
                       -0.0664125560950126,
                       -0.0128198242530558, 0.0346001216136025, 0.0355490066200026, 0.00258969725694249,
                       -0.0243904370222594, -0.0212952667598293, 0.00172000204362927, 0.0178435336564948,
                       0.0129705263655936, -0.00352184517255624, -0.0129822576070143, -0.00767266480793567,
                       0.00399762447900587, 0.00919635753043972, 0.00424860486002572, -0.00373637547558407,
                       -0.00625209009980773, -0.00209798382355121, 0.00310095778394608, 0.00402674588773692,
                       0.000834524632462554, -0.00233426650031818, -0.00242117752566539, -0.000174389098990111,
                       0.00159560380094689, 0.00133238648357355, -0.000101429140720271, -0.000977610053620608,
                       -0.000650560955099894, 0.000159172391563387, 0.000519394429735287, 0.000266126266220123,
                       -0.000117162797594676, -0.000220263432809440, -7.93729475878489e-05, 5.06834558206252e-05]

        msg_detect_I = signal.lfilter(filter_coff, 1, msg_detect_I_mix) #I路低通滤波
        msg_detect_Q = signal.lfilter(filter_coff, 1, msg_detect_Q_mix)#路低通滤波
        I_Data_ds = msg_detect_I[0:len(msg_detect_I):deciRatio]   #I路抽取
        Q_Data_ds = msg_detect_Q[0:len(msg_detect_I):deciRatio]  # Q路抽取
        data = I_Data_ds - Q_Data_ds *1j
        data = np.power(data, power)
        x, y = signal.welch(data, sampling_rate, 'flattop', int(fft_size),  return_onesided=False, scaling='spectrum')
    y = np.sqrt(y)
    y = 20 * np.log10(np.clip(y, 1e-20, 1e1000))

    chart_data = dict()
    # chart_data['x_label'] = config['PowerSpectrum']['xLabel']
    # chart_data['y_label'] = config['PowerSpectrum']['yLabel']
    chart_data['x_data'] = x.astype(int).tolist()
    chart_data['y_data'] = np.round(y, 2).tolist()
    return chart_data

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

def main(argv=None):
    # 测试功率谱


    # file = 'D:\LBWork\BWZN\XHFX\Data\调制数据0908back\ADPCM_TPC_BPSK_N_70036_1000_15_mod.dat'  # LB
    # rate_type = 2  # 中速信号，符号速率1000k

    # file = 'D:\LBWork\BWZN\XHFX\Data\调制数据0908back\ADPCM_CRC_DQPSK_N_70022_100_15_mod.dat'  # LB
    # rate_type = 1  # 低速信号，符号速率100k
    '''
    #频谱显示
    file = 'D:\LBWork\BWZN\XHFX\Data\调制数据0908back\ADPCM_LDPC_QPSK_N_70003_10000_15_mod.dat'  # LB
    rate_type = 3 # 高速信号，符号速率10000k

    power = 2
    chart_data = get_power_spectral(0, 40000000, power, rate_type, file)
    plt.plot(chart_data['x_data'], chart_data['y_data'])
    plt.legend()
    plt.show()
    '''
    #星座图显示

    file = 'QPSK_70000_10000_15_ID1_CRC_ID1_None_ID1_data.dat'
    file = 'D:\LBWork\BWZN\XHFX\Data\调制数据0908back\ADPCM_LDPC_QPSK_N_70003_10000_15_mod.dat'  # LB
    Fc = 70003000  # 信号的中心频率

    Fs = 40000000 # 采样频率
    sps = 4       # 过采样率sps = 采样频率/符号速率 （高速sps = 4; 中速sps = 40; 低速 = 400）
    filter_coff = [5.06834558206252e-05,-7.93729475878489e-05,-0.000220263432809440,-0.000117162797594676,0.000266126266220123,0.000519394429735287,0.000159172391563387,-0.000650560955099894,-0.000977610053620608,-0.000101429140720271,0.00133238648357355,0.00159560380094689,-0.000174389098990111,-0.00242117752566539,-0.00233426650031818,0.000834524632462554,0.00402674588773692,0.00310095778394608,-0.00209798382355121,-0.00625209009980773,-0.00373637547558407,0.00424860486002572,0.00919635753043972,0.00399762447900587,-0.00767266480793567,-0.0129822576070143,-0.00352184517255624,0.0129705263655936,0.0178435336564948,0.00172000204362927,-0.0212952667598293,-0.0243904370222594,0.00258969725694249,0.0355490066200026,0.0346001216136025,-0.0128198242530558,-0.0664125560950126,-0.0578295432729489,0.0482054244956093,0.210753713100735,0.332526869687875,0.332526869687875,0.210753713100735,0.0482054244956093,-0.0578295432729489,-0.0664125560950126,-0.0128198242530558,0.0346001216136025,0.0355490066200026,0.00258969725694249,-0.0243904370222594,-0.0212952667598293,0.00172000204362927,0.0178435336564948,0.0129705263655936,-0.00352184517255624,-0.0129822576070143,-0.00767266480793567,0.00399762447900587,0.00919635753043972,0.00424860486002572,-0.00373637547558407,-0.00625209009980773,-0.00209798382355121,0.00310095778394608,0.00402674588773692,0.000834524632462554,-0.00233426650031818,-0.00242117752566539,-0.000174389098990111,0.00159560380094689,0.00133238648357355,-0.000101429140720271,-0.000977610053620608,-0.000650560955099894,0.000159172391563387,0.000519394429735287,0.000266126266220123,-0.000117162797594676,-0.000220263432809440,-7.93729475878489e-05,5.06834558206252e-05]


    data_buffer = get_file_buffer(file, 0, 65536*64)
    scatter_I, scatter_Q = scatter_plot(data_buffer, filter_coff, Fs, Fc, sps)

    plt.plot(scatter_I, scatter_Q, '*')
    plt.show()  




if __name__ == "__main__":
    sys.exit(main())


