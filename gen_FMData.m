%%
clear;
close all;
%% 参数初始化
% c1 FM、c2 2FSK、c3 GMSK、c4 BPSK、c5 QPSK、c6 DQPSK、c7 OQPSK、c8 8PSK、c9 16QAM、c10 32QAM、c11 64QAM、c12 256QAM、c13 16APSK、c14 32APSK
% b1循环码、b2卷积码、b3汉明码、b4 Turbo、b5 LDPC、b7 TPC等；
% a1霍夫曼、a2算术、a3 L-Z、a4 ADPCM、a5 MPEG-2、a6 H.264、a7 H.265、a8 G.711、a9 G.721、a10 G.723
Mod_Array = {'FM','2FSK','GMSK','BPSK','DQPSK','QPSK','OQPSK','8PSK','16QAM','32QAM','64QAM','256QAM','16APSK','32APSK'};

ChEnc_Arr = {'CRC' ,'Conv' ,'Hamming', 'Turbo','LDPC', 'TPC'};
ChEncType = 'CRC';

ScEnc_Arr = {'huffman', 'arithmetic', 'lz', 'ADPCM', 'MPEG2', 'H264', 'H265', 'G711', 'G721', 'G723'};
SrEncType = 'None';

select_Funchannelencode = 1; % 是否执行信道编码函数
id_ChannelEncode = 1;   % 信道编码子类
run_time =  0.1;  % 单位：秒
%% 调制参数设置
Fs = 40; % 采样率 单位MHz
Fc = 70; % 载波频率
fc_side = (randi([0,100],1) - 5)*0.001;  %载波偏移
% fc_side = 0;
fc_shift = Fc + fc_side;
rb = 0.1; % 符号速率,1,2,3
fc_fm = 8; % 20和70是等效Lsamp的
Lsamp = Fs*1e6*run_time;  % 样点数

Nfft = 65536;   % 各种谱图FFT的点数
datalength_fun_SigGen = 65536;% 调制函数每一次调制的数据长度
SNR = 15;
%%

folder_name_ch = 'D:\LBWork\BWZN\XHFX\Data\信道编码\back\';
folder_namew  =  './Data/Data_Mod/';
%% 仿真参数
PA_FILE_LENGTH = 50e6; % unit：B
data_write_length = ceil(PA_FILE_LENGTH/2);
%% main code start 
hQuant=quantizer('nearest',[16 15]);% 量化器，对应16位ADC
fprintf('**** 开始调制数据生成：\n');
tic

fc_side = (randi([0,100],1) - 5)*0.001;  %载波偏移
mod_type = 'FM';
%% 各种调制后的文件名生成
filename_base_moded_source = 'a_FMSource';
filename_base_moded = ['FM_', num2str((Fc+fc_side)*1000)];

filename_moded = [folder_namew,'_', filename_base_moded,'_mod.dat'];
filename_data_before_mod = [folder_namew, filename_base_moded_source, '_beforemod.dat']; %调制前的数据

fid_filename_moded = fopen(filename_moded, 'w');
%调制数据生成
fprintf('写入调制数据文件： %s\n',filename_moded);

file_readlength = 2e4;
count = file_readlength;


fm_fm = rb/24; % FM信号模拟基带信号带宽 rb/12
Belt_f = 5; % FM信号调制指数

PhaseIn = 0;
m1 = 0;
cnt_data_write_length = 0;
while (count == file_readlength && (cnt_data_write_length <= data_write_length))
    AnalogSig_fm = RandAnSig(Lsamp,fm_fm,Fs); % 产生的信号本身即是幅度归一化的
    fdev = Belt_f*fm_fm/max(abs(AnalogSig_fm)); % 频率偏移常数Kf    
   
    SourceData = double(AnalogSig_fm);
    Lsamp = count;
    
    [msg_detect_float,PhaseOut]  = fun_SigGen(SourceData, mod_type, rb, (Fc+fc_side), fc_fm, Fs, Lsamp, SNR, PhaseIn);
    if(cnt_data_write_length == 0)
        fprintf('调制后数据与调制前数据倍数：%d \n',length(msg_detect_float)/length(SourceData));
    end
    PhaseIn = PhaseOut;
    len_modded = length(msg_detect_float);
    msg_detect = quantize(hQuant,msg_detect_float)*2^15;
    fwrite(fid_filename_moded, msg_detect,'int16');
    cnt_data_write_length = cnt_data_write_length + length(msg_detect);
    m1 = m1 + 1;
    
end

fclose(fid_filename_moded);

fprintf('%d MB调制数据文件生成结束\n',PA_FILE_LENGTH/1e6);
fprintf('-----------------------------------------------------------------------------\n');

toc
load handel
sound(y,Fs)


% %% 下变频 产生星座图
% en_fun_scatterplot = 0;
% 
% if (en_fun_scatterplot == 1)
%     lpFilt = designfilt('lowpassfir','PassbandFrequency',0.3, ...
%         'StopbandFrequency',0.4,'PassbandRipple',0.5, ...
%         'StopbandAttenuation',65,'DesignMethod','kaiserwin');
%     
%     %%混频+滤波
%     msg_detect_float_long_65536 = msg_detect_quant_long(1:65536);
%     msg_detect_I_mix = msg_detect_float_long_65536.*cos((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs)); % 混频
%     msg_detect_Q_mix = msg_detect_float_long_65536.* sin((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs));
%     
%     msg_detect_I = filter(lpFilt,msg_detect_I_mix); % 低通滤波
%     msg_detect_Q = filter(lpFilt,msg_detect_Q_mix); % 低通滤波
%     
%     msg_detect_IQ = msg_detect_I+1i*msg_detect_Q;
%     span = 10;       % Filter span
%     scatterplot(msg_detect_IQ(sps*span+1:sps:end-sps*span))
% end


% 绘制解调后的星座图
% En_saveScatterFile = 0;
% 
% if (En_saveScatterFile == 1)
%     plot(real(data_scatterplot),imag(data_scatterplot),'*');
%     for i = 1:5000 %length(data_scatterplot)
%         fwrite(fid_filename_Scatter, real(data_scatterplot(i)),'float');
%         fwrite(fid_filename_Scatter, imag(data_scatterplot(i)),'float');
%     end
% end
% fprintf('the value of fftframes is%6d\n',fftframes)% disp(['eee',num2str(a)])
% disp('All Finished')
%% 测试读取数据文件
% fid_filename_freq1  = fopen(filename_freq1, 'r');
% A = fread(fid_filename_freq1,65536,'float');
% plot(A);
% fclose(fid_filename_freq1);

%% 写调制输入的数据到文件
% 输出数据文件

% for m=1:length(datain)/8
%     zz = bi2de(datain(m*8-7:m*8),'left-msb');
%     fwrite(fid_filename_beforemod,zz);
% end
% 
% if (using_Modulation == 1)
% end




