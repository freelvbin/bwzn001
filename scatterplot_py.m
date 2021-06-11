% scatterplot
clear;
close all;
fs = 40000000;

BaseName = 'D:/LBWork/BWZN/XHFX/Data/调制数据/';
FileName = 'G721_Conv_64QAM_N_70075_10000_45_mod.dat';

% BaseName = 'D:/LBWork/BWZN/XHFX/Data/调制数据1206/';
% FileName = 'H264_Hamming_32APSK_N_70065_100_45_mod.dat';
FileNameLong = [BaseName , FileName];

fc = 70075 * 1000;  % 信号的中心频率
sps = 4;       % 过采样率sps = 采样频率/符号速率 （高速sps = 4; 中速sps = 40; 低速 = 400）
    
%% 测试读取数据文件
fid_filename_freq1  = fopen(FileNameLong, 'r');
InSig = fread(fid_filename_freq1,65536*sps,'int16');
fclose(fid_filename_freq1);

%% 星座图
if (sps == 400 || sps == 40)
    lpFilt = designfilt('lowpassfir','PassbandFrequency',0.3, ...
        'StopbandFrequency',0.4,'PassbandRipple',0.5, ...
        'StopbandAttenuation',65,'DesignMethod','kaiserwin');
else
    lpFilt = designfilt('lowpassfir','PassbandFrequency',0.4, ...
        'StopbandFrequency',0.55,'PassbandRipple',0.5, ...
        'StopbandAttenuation',65,'DesignMethod','kaiserwin');
end
% % 混频+滤波
y_sin = sin((2*pi*fc*(1:length(InSig))'/fs));
y_cos = cos((2*pi*fc*(1:length(InSig))'/fs));
msg_detect_I_mix = InSig.* y_cos; % 混频
msg_detect_Q_mix = InSig.* y_sin;

msg_detect_I = filter(lpFilt,msg_detect_I_mix); % 低通滤波
msg_detect_Q = filter(lpFilt,msg_detect_Q_mix); % 低通滤波

msg_detect_IQ = msg_detect_I+1i*msg_detect_Q;

% scatterplot(msg_detect_IQ(sps*span+floor(sps/2):sps:end-sps*span))
%OQPSK
% real_msg = real(msg_detect_IQ(1:end-sps/2));
% imag_msg = imag(msg_detect_IQ(sps/2+1:end));
% new_msg = real_msg + 1i*imag_msg;
% scatterplot(new_msg(floor(sps/2):sps:end));
% figure(1);pwelch(msg_detect_IQ,4096);
scatter_I = real(msg_detect_IQ(floor(sps/2):sps:sps*16384));
scatter_Q = imag(msg_detect_IQ(floor(sps/2):sps:sps*16384));
scatterplot(msg_detect_IQ(floor(sps/2):sps:sps*16384))
