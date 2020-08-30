function [I_Data_ds,Q_Data_ds] = DCandDeci(quantized_msg_detect,fs,fc_est,deciRatio,hQuant)

%% 下变频 有量化
% 混频后低通滤波器
firlt_lowps = firhalfband(64,0.35);
% firlt_lowps = LowPassFlt_90fs_10fpass_20fstop; % 复基带信号带宽最多为300MHz/10MHz
firlt_lowps_q = quantize(hQuant,firlt_lowps);
% figure;freqz(firlt_lowps_q,1)

% 混频+滤波
theta = rand*pi*2;
msg_detect_I_mix = quantized_msg_detect.*(quantize(hQuant,cos((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta)))); % 混频
msg_detect_I = 2*filter(firlt_lowps_q,1,msg_detect_I_mix); % 低通滤波
msg_detect_Q_mix = quantized_msg_detect.*(quantize(hQuant,sin((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta))));
msg_detect_Q = 2*filter(firlt_lowps_q,1,msg_detect_Q_mix);
%% 下变频 无量化
% 
% % 混频后低通滤波器
% % firlt_lowps = firhalfband(64,0.35);
% firlt_lowps = LowPassFlt_90fs_10fpass_20fstop; % 复基带信号带宽最多为300MHz/10MHz
% firlt_lowps_q = firlt_lowps;
% % figure;freqz(firlt_lowps_q,1)
% 
% % 混频+滤波
% theta = rand*pi*2;
% msg_detect_I_mix = quantized_msg_detect.*cos((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta)); % 混频
% msg_detect_I = 2*filter(firlt_lowps_q,1,msg_detect_I_mix); % 低通滤波
% msg_detect_Q_mix = quantized_msg_detect.* sin((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta));
% msg_detect_Q = 2*filter(firlt_lowps_q,1,msg_detect_Q_mix);
%% ---------抽取-------------------------
I_Data_ds = decimate(msg_detect_I,deciRatio,'fir'); % 实现时注意下滤波器的设计
Q_Data_ds = decimate(msg_detect_Q,deciRatio,'fir'); % 实现时注意下滤波器的设计