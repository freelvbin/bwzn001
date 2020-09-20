%%
clear;
close all;
%% ������ʼ��
% c1 FM��c2 2FSK��c3 GMSK��c4 BPSK��c5 QPSK��c6 DQPSK��c7 OQPSK��c8 8PSK��c9 16QAM��c10 32QAM��c11 64QAM��c12 256QAM��c13 16APSK��c14 32APSK
% b1ѭ���롢b2����롢b3�����롢b4 Turbo��b5 LDPC��b7 TPC�ȣ�
% a1��������a2������a3 L-Z��a4 ADPCM��a5 MPEG-2��a6 H.264��a7 H.265��a8 G.711��a9 G.721��a10 G.723
Mod_Array = {'FM','2FSK','GMSK','BPSK','DQPSK','QPSK','OQPSK','8PSK','16QAM','32QAM','64QAM','256QAM','16APSK','32APSK'};

ChEnc_Arr = {'CRC' ,'Conv' ,'Hamming', 'Turbo','LDPC', 'TPC'};
ChEncType = 'CRC';

ScEnc_Arr = {'huffman', 'arithmetic', 'lz', 'ADPCM', 'MPEG2', 'H264', 'H265', 'G711', 'G721', 'G723'};
SrEncType = 'None';

select_Funchannelencode = 1; % �Ƿ�ִ���ŵ����뺯��
id_ChannelEncode = 1;   % �ŵ���������
run_time =  0.1;  % ��λ����
%% ���Ʋ�������
Fs = 40; % ������ ��λMHz
Fc = 70; % �ز�Ƶ��
fc_side = (randi([0,100],1) - 5)*0.001;  %�ز�ƫ��
% fc_side = 0;
fc_shift = Fc + fc_side;
rb = 0.1; % ��������,1,2,3
fc_fm = 8; % 20��70�ǵ�ЧLsamp��
Lsamp = Fs*1e6*run_time;  % ������

Nfft = 65536;   % ������ͼFFT�ĵ���
datalength_fun_SigGen = 65536;% ���ƺ���ÿһ�ε��Ƶ����ݳ���
SNR = 15;
%%

folder_name_ch = 'D:\LBWork\BWZN\XHFX\Data\�ŵ�����\back\';
folder_namew  =  './Data/Data_Mod/';
%% �������
PA_FILE_LENGTH = 50e6; % unit��B
data_write_length = ceil(PA_FILE_LENGTH/2);
%% main code start 
hQuant=quantizer('nearest',[16 15]);% ����������Ӧ16λADC
fprintf('**** ��ʼ�����������ɣ�\n');
tic

fc_side = (randi([0,100],1) - 5)*0.001;  %�ز�ƫ��
mod_type = 'FM';
%% ���ֵ��ƺ���ļ�������
filename_base_moded_source = 'a_FMSource';
filename_base_moded = ['FM_', num2str((Fc+fc_side)*1000)];

filename_moded = [folder_namew,'_', filename_base_moded,'_mod.dat'];
filename_data_before_mod = [folder_namew, filename_base_moded_source, '_beforemod.dat']; %����ǰ������

fid_filename_moded = fopen(filename_moded, 'w');
%������������
fprintf('д����������ļ��� %s\n',filename_moded);

file_readlength = 2e4;
count = file_readlength;


fm_fm = rb/24; % FM�ź�ģ������źŴ��� rb/12
Belt_f = 5; % FM�źŵ���ָ��

PhaseIn = 0;
m1 = 0;
cnt_data_write_length = 0;
while (count == file_readlength && (cnt_data_write_length <= data_write_length))
    AnalogSig_fm = RandAnSig(Lsamp,fm_fm,Fs); % �������źű����Ƿ��ȹ�һ����
    fdev = Belt_f*fm_fm/max(abs(AnalogSig_fm)); % Ƶ��ƫ�Ƴ���Kf    
   
    SourceData = double(AnalogSig_fm);
    Lsamp = count;
    
    [msg_detect_float,PhaseOut]  = fun_SigGen(SourceData, mod_type, rb, (Fc+fc_side), fc_fm, Fs, Lsamp, SNR, PhaseIn);
    if(cnt_data_write_length == 0)
        fprintf('���ƺ����������ǰ���ݱ�����%d \n',length(msg_detect_float)/length(SourceData));
    end
    PhaseIn = PhaseOut;
    len_modded = length(msg_detect_float);
    msg_detect = quantize(hQuant,msg_detect_float)*2^15;
    fwrite(fid_filename_moded, msg_detect,'int16');
    cnt_data_write_length = cnt_data_write_length + length(msg_detect);
    m1 = m1 + 1;
    
end

fclose(fid_filename_moded);

fprintf('%d MB���������ļ����ɽ���\n',PA_FILE_LENGTH/1e6);
fprintf('-----------------------------------------------------------------------------\n');

toc
load handel
sound(y,Fs)


% %% �±�Ƶ ��������ͼ
% en_fun_scatterplot = 0;
% 
% if (en_fun_scatterplot == 1)
%     lpFilt = designfilt('lowpassfir','PassbandFrequency',0.3, ...
%         'StopbandFrequency',0.4,'PassbandRipple',0.5, ...
%         'StopbandAttenuation',65,'DesignMethod','kaiserwin');
%     
%     %%��Ƶ+�˲�
%     msg_detect_float_long_65536 = msg_detect_quant_long(1:65536);
%     msg_detect_I_mix = msg_detect_float_long_65536.*cos((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs)); % ��Ƶ
%     msg_detect_Q_mix = msg_detect_float_long_65536.* sin((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs));
%     
%     msg_detect_I = filter(lpFilt,msg_detect_I_mix); % ��ͨ�˲�
%     msg_detect_Q = filter(lpFilt,msg_detect_Q_mix); % ��ͨ�˲�
%     
%     msg_detect_IQ = msg_detect_I+1i*msg_detect_Q;
%     span = 10;       % Filter span
%     scatterplot(msg_detect_IQ(sps*span+1:sps:end-sps*span))
% end


% ���ƽ���������ͼ
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
%% ���Զ�ȡ�����ļ�
% fid_filename_freq1  = fopen(filename_freq1, 'r');
% A = fread(fid_filename_freq1,65536,'float');
% plot(A);
% fclose(fid_filename_freq1);

%% д������������ݵ��ļ�
% ��������ļ�

% for m=1:length(datain)/8
%     zz = bi2de(datain(m*8-7:m*8),'left-msb');
%     fwrite(fid_filename_beforemod,zz);
% end
% 
% if (using_Modulation == 1)
% end




