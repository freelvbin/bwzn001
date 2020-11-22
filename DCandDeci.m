function [I_Data_ds,Q_Data_ds] = DCandDeci(quantized_msg_detect,fs,fc_est,deciRatio)

% %% �±�Ƶ ������
% % ��Ƶ���ͨ�˲���
% firlt_lowps = firhalfband(64,0.35);
% % firlt_lowps = LowPassFlt_90fs_10fpass_20fstop; % �������źŴ������Ϊ300MHz/10MHz
% 
% % ��Ƶ+�˲�
% theta = rand*pi*2;
% msg_detect_I_mix = quantized_msg_detect.*cos((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta)); % ��Ƶ
% msg_detect_I = 2*filter(firlt_lowps,1,msg_detect_I_mix); % ��ͨ�˲�
% msg_detect_Q_mix = quantized_msg_detect.*sin((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta));
% msg_detect_Q = 2*filter(firlt_lowps,1,msg_detect_Q_mix);
% 
% %% ---------��ȡ-------------------------
% 
% I_Data_ds = decimate(msg_detect_I,deciRatio,'fir'); % ʵ��ʱע�����˲��������
% Q_Data_ds = decimate(msg_detect_Q,deciRatio,'fir'); % ʵ��ʱע�����˲��������

%% �±�Ƶ ������2
% ��Ƶ���ͨ�˲���
firlt_lowps = firhalfband(64,0.35);
% firlt_lowps = LowPassFlt_90fs_10fpass_20fstop; % �������źŴ������Ϊ300MHz/10MHz

% ��Ƶ+�˲�
theta = rand*pi*2;
msg_detect_I_mix = quantized_msg_detect.*cos((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta)); % ��Ƶ
msg_detect_I = 2*filter(firlt_lowps,1,msg_detect_I_mix); % ��ͨ�˲�
msg_detect_Q_mix = quantized_msg_detect.*sin((2*pi*fc_est*(1:length(quantized_msg_detect))'/fs + theta));
msg_detect_Q = 2*filter(firlt_lowps,1,msg_detect_Q_mix);

%% ---------��ȡ-------------------------

I_Data_ds = msg_detect_I(1:deciRatio:end);
Q_Data_ds = msg_detect_Q(1:deciRatio:end);
