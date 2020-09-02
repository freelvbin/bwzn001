%%
%%
clear;
close all;
%% ������ʼ��
% c1 FM��c2 2FSK��c3 GMSK��c4 BPSK��c5 QPSK��c6 DQPSK��c7 OQPSK��c8 8PSK��c9 16QAM��c10 32QAM��c11 64QAM��c12 256QAM��c13 16APSK��c14 32APSK
% b1ѭ���롢b2����롢b3�����롢b4 Turbo��b5 LDPC��b7 TPC�ȣ�
% a1��������a2������a3 L-Z��a4 ADPCM��a5 MPEG-2��a6 H.264��a7 H.265��a8 G.711��a9 G.721��a10 G.723
Mod_Array = {'FM','2FSK','GMSK','BPSK','DQPSK','QPSK','OQPSK','8PSK','16QAM','32QAM','64QAM','256QAM','16APSK','32APSK'};
Mod_Method = 'QPSK'; % ismember(Mod_Array(1),'FMd')

ChannelEncode_Array = {'None', 'CRC' ,'Conv' ,'Hamming', 'Turbo', 'TPC', 'LDPC'};
ChEncType = 'CRC';
ScEncFileName = {'huffman_2th.dat', 'ac_2th.dat', 'lz_2th.dat'};
SrEncType = 'None';

using_ChannelEncode = 0;
using_Modulation = 1;

select_Funchannelencode = 1; % �Ƿ�ִ���ŵ����뺯��
id_ChannelEncode = 1;   % �ŵ���������
run_time =  0.1;  % ��λ����
%% ���Ʋ�������
Fs = 40; % ������ ��λMHz
Fc = 70; % �ز�Ƶ��
% fc_side = (randi([0,100],1) - 5)*0.001;  %�ز�ƫ��
fc_side = 0;
fc_shift = Fc + fc_side;
rb = 10; % ��������,1, 0.1

sps = Fs/rb;
fc_fm = 8; % 20��70�ǵ�ЧLsamp��
Lsamp = Fs*1e6*run_time;  % ������

Nfft = 65536;   % ������ͼFFT�ĵ���
datalength_fun_SigGen = 65536;% ���ƺ���ÿһ�ε��Ƶ����ݳ���
SNR = 15;
%% ���ϵ��Ʋ���
%��Ϸ�ʽ
joint_type(1,1,:,:) = [1,1,2,3;1,1,3,3;1,1,4,3];
joint_type(1,2,:,:) = [1,2,5,2;1,2,6,2;1,2,7,2];
joint_type(1,3,:,:) = [1,3,2,1;1,3,3,1;1,3,4,1];

joint_type(2,1,:,:) = [2,1,5,3; 2,1,6,3; 2,1,7,3];
joint_type(2,2,:,:) = [2,2,2,2; 2,2,3,2; 2,2,4,2];
joint_type(2,3,:,:) = [2,3,5,1; 2,3,6,1; 2,3,7,1];


%% ��Դ����
Nsym = Lsamp/sps; % ������
datain = randi([0 1],Nsym,1);
% SourceDatain = Fun_SourceEncode(datain);

%% �ŵ�����
if (using_ChannelEncode == 1)
    %%
    sync_header = [0 1 0 0 0 0 1 0];
    %%
    [ChannelEnc_DataOut,ChEncFrames,FrameLength] = Fun_ChannelEncode(datain,ChEncType,id_ChannelEncode,select_Funchannelencode,sync_header);
    file_name_ChEnc_base  = ['EnCh_',ChEncType,'_', num2str(FrameLength),'_', num2str(length(sync_header)), '_' ,num2str(ChEncFrames),'_', num2str(id_ChannelEncode), '_data.dat'];
    file_name_ChEnc = ['.\EncodeData\',file_name_ChEnc_base];
    
    if (select_Funchannelencode == 1)
        fid_file_EncoedeCh = fopen(file_name_ChEnc, 'w');
        % ��������ļ�
        if(mod(length(ChannelEnc_DataOut),8) == 0)
            for m=1:length(ChannelEnc_DataOut)/8
                zz = bi2de(ChannelEnc_DataOut(m*8-7:m*8)','left-msb');
                fwrite(fid_file_EncoedeCh,zz);
            end
        end
        fclose(fid_file_EncoedeCh);
        disp('ChannelEncode  END');
    else %���Զ�ȡ�����ļ�
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
%% ���ֵ��ƺ���ļ�������
if (using_Modulation == 1)
        file_dir =  '.\Data\';
        file_basename = [Mod_Method,'_', num2str((Fc+fc_side)*1000),'_',num2str(rb*1000),'_',num2str(SNR), '_ID',num2str(1),'_',ChEncType, '_ID', ...
            num2str(1), '_', SrEncType, '_ID', num2str(1)];
        
        filename_moded = [file_dir,file_basename, '_data.dat'];
        filename_data_before_mod = [file_basename, '_data_beforemod.dat']; %����ǰ������
    
    % %     %дexcel���
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
%%  �����ź����� num2str(fc+fc_side)
%%��Ƶ�ź�������.coe�ļ�����
hQuant=quantizer('nearest',[16 15]);% ����������Ӧ16λADC

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
%% �±�Ƶ ��������ͼ
en_fun_scatterplot = 0;

if (en_fun_scatterplot == 1)
    lpFilt = designfilt('lowpassfir','PassbandFrequency',0.3, ...
        'StopbandFrequency',0.4,'PassbandRipple',0.5, ...
        'StopbandAttenuation',65,'DesignMethod','kaiserwin');
    
    %%��Ƶ+�˲�
    msg_detect_float_long_65536 = msg_detect_quant_long(1:65536);
    msg_detect_I_mix = msg_detect_float_long_65536.*cos((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs)); % ��Ƶ
    msg_detect_Q_mix = msg_detect_float_long_65536.* sin((2*pi*(Fc)*(1:length(msg_detect_float_long_65536))/Fs));
    
    msg_detect_I = filter(lpFilt,msg_detect_I_mix); % ��ͨ�˲�
    msg_detect_Q = filter(lpFilt,msg_detect_Q_mix); % ��ͨ�˲�
    
    msg_detect_IQ = msg_detect_I+1i*msg_detect_Q;
    span = 10;       % Filter span
    scatterplot(msg_detect_IQ(sps*span+1:sps:end-sps*span))
end
%% ������Ƶ/������ƣ��ṩ�±�Ƶ�ͳ�ȡ�ı�Ҫ����

% nFFT = 8192;
% [fc_est, B_est_3dB] = coarseEst(msg_detect,nFFT,fs); % ��ͨ/���Ƶ�����������Ƶ����
% fc_est = 20.2;
% B_est = 1.5*B_est_3dB; % ����Դ���Ϊ3dB�����1.5��
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

%% ���ƽ���������ͼ
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
%% ���Զ�ȡ�����ļ�
% fid_filename_freq1  = fopen(filename_freq1, 'r');
% A = fread(fid_filename_freq1,65536,'float');
% plot(A);
% fclose(fid_filename_freq1);

%% д������������ݵ��ļ�
% ��������ļ�

for m=1:length(datain)/8
    zz = bi2de(datain(m*8-7:m*8),'left-msb');
    fwrite(fid_filename_beforemod,zz);
end

if (using_Modulation == 1)
    fclose(fid_filename_beforemod);

end




