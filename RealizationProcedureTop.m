%%
%%
clear;
close all;
%% 参数初始化
% c1 FM、c2 2FSK、c3 GMSK、c4 BPSK、c5 QPSK、c6 DQPSK、c7 OQPSK、c8 8PSK、c9 16QAM、c10 32QAM、c11 64QAM、c12 256QAM、c13 16APSK、c14 32APSK
% b1循环码、b2卷积码、b3汉明码、b4 Turbo、b5 LDPC、b7 TPC等；
% a1霍夫曼、a2算术、a3 L-Z、a4 ADPCM、a5 MPEG-2、a6 H.264、a7 H.265、a8 G.711、a9 G.721、a10 G.723
Mod_Array = {'FM','2FSK','GMSK','BPSK','DQPSK','QPSK','OQPSK','8PSK','16QAM','32QAM','64QAM','256QAM','16APSK','32APSK'};
Mod_Method = 'QPSK'; % ismember(Mod_Array(1),'FMd')

ChannelEncode_Array = {'None', 'CRC' ,'Conv' ,'Hamming', 'Turbo', 'TPC', 'LDPC'};
ChEncType = 'CRC';
ScEncFileName = {'huffman_2th.dat', 'ac_2th.dat', 'lz_2th.dat'};
SrEncType = 'None';

using_ChannelEncode = 0;
using_Modulation = 1;

select_Funchannelencode = 1; % 是否执行信道编码函数
id_ChannelEncode = 1;   % 信道编码子类
run_time =  0.1;  % 单位：秒
%% 调制参数设置
Fs = 40; % 采样率 单位MHz
Fc = 70; % 载波频率
% fc_side = (randi([0,100],1) - 5)*0.001;  %载波偏移
fc_side = 0;
fc_shift = Fc + fc_side;
rb = 10; % 符号速率,1, 0.1

sps = Fs/rb;
fc_fm = 8; % 20和70是等效Lsamp的
Lsamp = Fs*1e6*run_time;  % 样点数

Nfft = 65536;   % 各种谱图FFT的点数
datalength_fun_SigGen = 65536;% 调制函数每一次调制的数据长度
SNR = 15;
%% 联合调制参数
%组合方式
joint_type(1,1,:,:) = [1,1,2,3;1,1,3,3;1,1,4,3];
joint_type(1,2,:,:) = [1,2,5,2;1,2,6,2;1,2,7,2];
joint_type(1,3,:,:) = [1,3,2,1;1,3,3,1;1,3,4,1];

joint_type(2,1,:,:) = [2,1,5,3; 2,1,6,3; 2,1,7,3];
joint_type(2,2,:,:) = [2,2,2,2; 2,2,3,2; 2,2,4,2];
joint_type(2,3,:,:) = [2,3,5,1; 2,3,6,1; 2,3,7,1];


%% 信源编码
Nsym = Lsamp/sps; % 符号数
datain = randi([0 1],Nsym,1);
% SourceDatain = Fun_SourceEncode(datain);

%% 信道编码
if (using_ChannelEncode == 1)
    %%
    sync_header = [0 1 0 0 0 0 1 0];
    %%
    [ChannelEnc_DataOut,ChEncFrames,FrameLength] = Fun_ChannelEncode(datain,ChEncType,id_ChannelEncode,select_Funchannelencode,sync_header);
    file_name_ChEnc_base  = ['EnCh_',ChEncType,'_', num2str(FrameLength),'_', num2str(length(sync_header)), '_' ,num2str(ChEncFrames),'_', num2str(id_ChannelEncode), '_data.dat'];
    file_name_ChEnc = ['.\EncodeData\',file_name_ChEnc_base];
    
    if (select_Funchannelencode == 1)
        fid_file_EncoedeCh = fopen(file_name_ChEnc, 'w');
        % 输出数据文件
        if(mod(length(ChannelEnc_DataOut),8) == 0)
            for m=1:length(ChannelEnc_DataOut)/8
                zz = bi2de(ChannelEnc_DataOut(m*8-7:m*8)','left-msb');
                fwrite(fid_file_EncoedeCh,zz);
            end
        end
        fclose(fid_file_EncoedeCh);
        disp('ChannelEncode  END');
    else %测试读取数据文件
        %         fid_file_EncoedeCh  = fopen(file_name_ChEnc, 'r');
        %         data_read = fread(fid_file_EncoedeCh);
        %         data_read_bin = de2bi(data_read,8,'left-msb');
        %         ChannelEnc_DataOut = reshape(data_read_bin',[1,length(data_read)*8]);
        %         fclose(fid_file_EncoedeCh);
    end
    
    SourceData = ChannelEnc_DataOut;
else
    SourceData = randi([0 1],Nsym,1);
end
%% 各种调制后的文件名生成
if (using_Modulation == 1)
        file_dir =  '.\Data\';
        file_basename = [Mod_Method,'_', num2str((Fc+fc_side)*1000),'_',num2str(rb*1000),'_',num2str(SNR), '_ID',num2str(1),'_',ChEncType, '_ID', ...
            num2str(1), '_', SrEncType, '_ID', num2str(1)];
        
        filename_moded = [file_dir,file_basename, '_data.dat'];
        filename_data_before_mod = [file_basename, '_data_beforemod.dat']; %调制前的数据
    
    % %     %写excel表格
%         filename = 'testdata.xlsx';
%         sheet = 2;
%         for m = 7:7
%             A = {filename_data_before_mod,filename_moded,filename_freq1, filename_freq2,filename_freq4, filename_freq8, ' ',filename_Scatter,Mod_Method,...
%                 num2str(fc+fc_side),num2str(rb*1.3), 'high', num2str(rb), num2str(SNR), num2str(fs)};
%             xlRange = ['C',num2str(m)];
%     
%             xlswrite(filename,A,sheet,xlRange)
%         end

    % %     open file
        fid_filename_beforemod = fopen(filename_data_before_mod, 'w');
        fid_filename_moded = fopen(filename_moded, 'w');
end
%%  调制信号生成 num2str(fc+fc_side)
%%中频信号量化及.coe文件导出
hQuant=quantizer('nearest',[16 15]);% 量化器，对应16位ADC

if (using_Modulation == 1)
    PhaseIn = 0;
    for m = 1: floor(length(SourceData)/datalength_fun_SigGen)
        SourceData_seg = SourceData((m-1)*datalength_fun_SigGen+1 : m*datalength_fun_SigGen);
        [msg_detect_float,data_scatterplot,PhaseOut]  = fun_SigGen(SourceData_seg,Mod_Method,rb,(Fc+fc_side),fc_fm,Fs,Lsamp,SNR, PhaseIn);
        PhaseIn = 0;
        len_modded = length(msg_detect_float);
        msg_detect = quantize(hQuant,msg_detect_float)*2^15;
        fwrite(fid_filename_moded, msg_detect,'int16');   
        msg_detect_quant_long((m-1)*len_modded+1:m*len_modded) = msg_detect;
    end
    fclose(fid_filename_moded);

end
%% 下变频 产生星座图
en_fun_scatterplot = 0;

if (en_fun_scatterplot == 1)
    lpFilt = designfilt('lowpassfir','PassbandFrequency',0.3, ...
        'StopbandFrequency',0.4,'PassbandRipple',0.5, ...
        'StopbandAttenuation',65,'DesignMethod','kaiserwin');
    
    %%混频+滤波
    msg_detect_float_long_65536 = msg_detect_quant_long(1:65536);
    msg_detect_I_mix = msg_detect_float_long_65536.*cos((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs)); % 混频
    msg_detect_Q_mix = msg_detect_float_long_65536.* sin((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs));
    
    msg_detect_I = filter(lpFilt,msg_detect_I_mix); % 低通滤波
    msg_detect_Q = filter(lpFilt,msg_detect_Q_mix); % 低通滤波
    
    msg_detect_IQ = msg_detect_I+1i*msg_detect_Q;
    span = 10;       % Filter span
    scatterplot(msg_detect_IQ(sps*span+1:sps:end-sps*span))
end
%% 残留载频/带宽估计，提供下变频和抽取的必要参数

% nFFT = 8192;
% [fc_est, B_est_3dB] = coarseEst(msg_detect,nFFT,fs); % 带通/免混频采样后残留载频估计
% fc_est = 20.2;
% B_est = 1.5*B_est_3dB; % 设绝对带宽为3dB带宽的1.5倍
% -------------------------------------------------------

%% FFT
fftlen = Nfft*8;
fftframes = floor(length(msg_detect)/65536);
data_freq = zeros((fftlen/2+1)*fftframes,1);


for i = 1:fftframes
    data_section = msg_detect((i-1)*fftlen+1: i*fftlen);
    [p1, f1] = pwelch(data_section, Nfft,Nfft/2,Nfft,Fs);
    [p2, f1] = pwelch(data_section.^2, 65536,[],[],Fs);
    [p4, f1] = pwelch(data_section.^4, 65536,[],[],Fs);
    [p8, f1] = pwelch(data_section.^8, 65536,[],[],Fs);
    p1 = 10*log10(p1);
    p2 = 10*log10(p2);
    p4 = 10*log10(p4);
    p8 = 10*log10(p8);
    
    figure(1);
    subplot(2,3,1); plot(f1,p1);
    subplot(2,3,2); plot(f1,p2);
    subplot(2,3,3); plot(f1,p4);
    subplot(2,3,4); plot(f1,p8);
    
end

%% 绘制解调后的星座图
En_saveScatterFile = 0;

if (En_saveScatterFile == 1)
    % plot(real(data_scatterplot),imag(data_scatterplot),'*');
    for i = 1:5000 %length(data_scatterplot)
        fwrite(fid_filename_Scatter, real(data_scatterplot(i)),'float');
        fwrite(fid_filename_Scatter, imag(data_scatterplot(i)),'float');
    end
end
fprintf('the value of fftframes is%6d\n',fftframes)% disp(['eee',num2str(a)])
disp('All Finished')
%% 测试读取数据文件
% fid_filename_freq1  = fopen(filename_freq1, 'r');
% A = fread(fid_filename_freq1,65536,'float');
% plot(A);
% fclose(fid_filename_freq1);

%% 写调制输入的数据到文件
% 输出数据文件

for m=1:length(datain)/8
    zz = bi2de(datain(m*8-7:m*8),'left-msb');
    fwrite(fid_filename_beforemod,zz);
end

if (using_Modulation == 1)
    fclose(fid_filename_beforemod);

end




