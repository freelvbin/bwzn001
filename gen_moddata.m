%%
clear;
close all;
%% 参数初始化
% c1 FM、c2 2FSK、c3 GMSK、c4 BPSK、c5 QPSK、c6 DQPSK、c7 OQPSK、c8 8PSK、c9 16QAM、c10 32QAM、c11 64QAM、c12 256QAM、c13 16APSK、c14 32APSK
% b1循环码、b2卷积码、b3汉明码、b4 Turbo、b5 LDPC、b7 TPC等；
% a1霍夫曼、a2算术、a3 L-Z、a4 ADPCM、a5 MPEG-2、a6 H.264、a7 H.265、a8 G.711、a9 G.721、a10 G.723
Mod_Array = {'FM','2FSK','GMSK','BPSK','DQPSK','QPSK','OQPSK','8PSK','16QAM','32QAM','64QAM','256QAM','16APSK','32APSK'};
mod_type = 'QPSK'; % ismember(Mod_Array(1),'FMd')

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
rb = [0.1,1,10]; % 符号速率,1,2,3
fc_fm = 8; % 20和70是等效Lsamp的
Lsamp = Fs*1e6*run_time;  % 样点数

Nfft = 65536;   % 各种谱图FFT的点数
datalength_fun_SigGen = 65536;% 调制函数每一次调制的数据长度
SNR = 45;
%% 联合调制参数

%组合方式
joint_type(1,1,:,:) = [1,1,2,3; 1,1,3,3; 1,1,4,3];
joint_type(1,2,:,:) = [1,2,5,2; 1,2,6,2; 1,2,7,2];
joint_type(1,3,:,:) = [1,3,2,1; 1,3,3,1; 1,3,4,1];

joint_type(2,1,:,:) = [2,1,5,3; 2,1,6,3; 2,1,7,3];
joint_type(2,2,:,:) = [2,2,2,2; 2,2,3,2; 2,2,4,2];
joint_type(2,3,:,:) = [2,3,5,1; 2,3,6,1; 2,3,7,1];

joint_type(3,1,:,:) = [3,4,2,3; 3,4,3,3; 3,4,4,3];
joint_type(3,2,:,:) = [3,5,5,2; 3,5,6,2; 3,5,7,2];
joint_type(3,3,:,:) = [3,6,2,1; 3,6,3,1; 3,6,4,1];


joint_type(4,1,:,:) = [4,5,5,3; 4,5,6,3; 4,5,7,3];
joint_type(4,2,:,:) = [4,6,2,2; 4,6,3,2; 4,6,4,2];
joint_type(4,3,:,:) = [4,1,5,1; 4,1,6,1; 4,1,7,1];

joint_type(5,1,:,:) = [5,6,6,3; 5,6,7,3;  5,6,8,3];
joint_type(5,2,:,:) = [5,1,9,2; 5,1,10,2; 5,1,11,2];
joint_type(5,3,:,:) = [5,2,5,1; 5,2,6,1;  5,2,2,1];

joint_type(6,1,:,:) = [6,1,8,3;  6,1,9,3;  6,1,10,3];
joint_type(6,2,:,:) = [6,2,11,2; 6,2,12,2; 6,2,13,2];
joint_type(6,3,:,:) = [6,3,14,1; 6,3,5,1;  6,3,6,1];

joint_type(7,1,:,:) = [7,3,9,3; 7,3,10,3; 7,3,11,3];
joint_type(7,2,:,:) = [7,4,12,2; 7,4,13,2; 7,4,14,2];
joint_type(7,3,:,:) = [7,5,5,1; 7,5,6,1; 7,5,7,1];

joint_type(8,1,:,:) = [8,6,10,3; 8,6,11,3; 8,6,12,3];
joint_type(8,2,:,:) = [8,1,13,2; 8,1,14,2; 8,1,2,2];
joint_type(8,3,:,:) = [8,2,3,1;  8,2,4,1;  8,2,5,1];

joint_type(9,1,:,:) = [9,2,11,3; 9,2,12,3; 9,2,13,3];
joint_type(9,2,:,:) = [9,3,14,2; 9,3,2,2;  9,3,3,2];
joint_type(9,3,:,:) = [9,4,4,1;  9,4,5,1;  9,4,6,1];

joint_type(10,1,:,:) = [10,5,12,3; 10,5,13,3; 10,5,14,3];
joint_type(10,2,:,:) = [10,6,2,2;  10,6,3,2;  10,6,4,2];
joint_type(10,3,:,:) = [10,1,5,1;  10,1,6,1;  10,1,7,1];

folder_name_ch = 'D:\LBWork\BWZN\XHFX\Data\信道编码\back\';
folder_namew  =  'D:\LBWork\BWZN\XHFX\Data\调制数据\';
%% 仿真参数
PA_FILE_LENGTH = 500e6; % unit：B
data_write_length = ceil(PA_FILE_LENGTH/2);
%% main code start 
hQuant=quantizer('nearest',[16 15]);% 量化器，对应16位ADC
fprintf('**** 开始调制数据生成：\n');
tic
for m = 1: 10 %source code
    srccode_type =  m;
    fprintf('信源编码类型是： %d, %s\n',srccode_type, ScEnc_Arr{m});
    for n = 1:3 % 每个信源对应三类信道
        chcode_type  = joint_type(m,n,1,2);
%         chcode_type = 6;
        filename_SrEnc_ChEnc =  ScEnc_Arr{m} + "_"+ ChEnc_Arr{chcode_type} + ".dat";
        filename_chcode = folder_name_ch + filename_SrEnc_ChEnc;
        fprintf('信道编码类型是： %d, %s\n',chcode_type, ChEnc_Arr{chcode_type});
        for c = 1:3 % 每一类信道又对应三类调制方式  
            fc_side = (randi([0,100],1) - 5)*0.001;  %载波偏移
            Mod_Method_num = joint_type(m,n,c,3);
            mod_type = Mod_Array{Mod_Method_num};
            mod_type = '256QAM'; 
%             if( mod_type == "16APSK" ||mod_type == "32APSK"||mod_type == "16QAM"||mod_type == "64QAM"||mod_type == "256QAM")
            if(mod_type == "64QAM"||mod_type == "256QAM")                
                speed_ratetype = joint_type(m,n,c,4);
                speed_ratetype = 3;
                fprintf('调制类型是： %d ：%s\n',Mod_Method_num,mod_type );
                fprintf('速率类型是： %d\n',speed_ratetype );
                fprintf('m是：%d, n是：%d, c是：%d\n',m,n,c);

    %             filenamew = ['a' , num2str(m) , '_b' , num2str(n), '_c' , num2str(c) , '_'];
                filenamew = [ScEnc_Arr{m} , '_' ,ChEnc_Arr{chcode_type}, '_' , mod_type , '_N', '_' ];
                sps = Fs/rb(speed_ratetype);

                %% 各种调制后的文件名生成
                file_basename_0 = [num2str((Fc+fc_side)*1000),'_',num2str(rb(speed_ratetype)*1000),'_',num2str(SNR)];
                filename_moded = [folder_namew,filenamew,file_basename_0, '_mod.dat'];
                filename_data_before_mod = [folder_namew,filenamew, file_basename_0, '_beforemod.dat']; %调制前的数据

    %             fid_filename_beforemod = fopen(filename_data_before_mod, 'w');
                fid_filename_moded = fopen(filename_moded, 'w');
                 %调制数据生成           
                file_chcode =  fopen(filename_chcode, 'r');
                fprintf('打开信道编码数据文件： %s\n',filename_chcode);
                fprintf('写入调制数据文件： %s\n',filename_moded);
                if (speed_ratetype == 1)
                    file_readlength0 = 2e4;
                elseif (speed_ratetype == 2)
                    file_readlength0 = 2e5;
                else
                    file_readlength0 = 2e6;
                end

                if(mod_type== "8PSK" || mod_type == "64QAM")
                    file_readlength = file_readlength0*3 ;
                else
                    file_readlength = file_readlength0;
                end

                count = file_readlength;
                PhaseIn = 0;
                m1 = 0;
                cnt_data_write_length = 0;
                while (count == file_readlength && (cnt_data_write_length <= data_write_length))
                    [SourceData, count] = fread(file_chcode, file_readlength,'*ubit1','ieee-be');

                    SourceData = double(SourceData);
                    Lsamp = count;
                    [msg_detect_float,PhaseOut]  = fun_SigGen(SourceData, mod_type, rb(speed_ratetype), (Fc+fc_side), fc_fm, Fs, Lsamp, SNR, PhaseIn);
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

                fclose(file_chcode);
                fclose(fid_filename_moded);
    %             fclose(fid_filename_beforemod);
                fprintf('%d MB调制数据文件生成结束\n',PA_FILE_LENGTH/1e6);
                fprintf('-----------------------------------------------------------------------------\n');
            end
        end
       
    end
end
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




