% % c1 FM、c2 2FSK、c3 GMSK、c4 BPSK、c5 QPSK、c6 DQPSK、c7 OQPSK、c8 8PSK、c9 16QAM、c10 32QAM、c11 64QAM、c12 256QAM、c13 16APSK、c14 32APSK
% b1循环码、b2卷积码、b3汉明码、b4 Turbo、b5 LDPC、b6 TPC等；
% a1霍夫曼、a2算术、a3 L-Z、a4 ADPCM、a5 MPEG-2、a6 H.264、a7 H.265、a8 G.711、a9 G.721、a10 G.723
clear;clc;
base_pathr = 'D:\LBWork\BWZN\XHFX\信源编码\';
base_pathw = 'D:\LBWork\BWZN\XHFX\信道编码\';

length_channel_ar(1,:) = [64, 128, 192];
length_channel_ar(2,:) = [72, 144, 72];
length_channel_ar(3,:) = [11, 11, 11];
length_channel_ar(4,:) = [64, 64, 64];
length_channel_ar(5,:) = [16200, 21600, 25900];
length_channel_ar(6,:) = [231, 180, 180];

pkt_num_channel_ar(1,:)= [400, 200, 128]; %b1循环码
pkt_num_channel_ar(2,:)= [384, 192, 96];   % b2卷积码
pkt_num_channel_ar(3,:)= [2560, 2624, 2688]; % b3汉明码
pkt_num_channel_ar(4,:)= [400, 400, 400]; %b4 Turbo
pkt_num_channel_ar(5,:)= [1, 1, 1]; % b5 LDPC
pkt_num_channel_ar(6,:)= [128, 144, 160];      % b6 TPC

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

ChannelEncode_Array = {'CRC' ,'Conv' ,'Hamming', 'Turbo','LDPC', 'TPC'};
ChEncType = 'CRC';
select_Funchannelencode = 1; % 是否执行信道编码函数
sync_header = [0 1 0 0 0 0 1 0];  % 同步头 0x42
readlength = (25900*2)*8; % 文件每次读取的长度
id_b1_childtype = 1; % b1 下面的子类

len_data_buff = readlength*2;

%% 

folder_name_2th = "D:\LBWork\BWZN\XHFX\Data\信源编码\data_2th\";
folder_namew  =  "D:\LBWork\BWZN\XHFX\Data\信道编码\";
tic
for m = 1: 10 %source code
%     name_datafile_r =Filename_a1(m);
    for n = 1:3 % channel code
        pkt_num_channel = pkt_num_channel_ar(joint_type(m,n,1,2),id_b1_childtype); %该信道编码对应的每一包的帧数量
        length_frame_ch = length_channel_ar(joint_type(m,n,1,2),id_b1_childtype);
        
        Fun_Ch_datain_length = floor(readlength/(length_frame_ch * pkt_num_channel)) * (length_frame_ch * pkt_num_channel); % 每次送入信道编码的数据长度，需为包长度的整数倍
        name_datafile_r = [ 'a' , num2str(m), '_2th',  '.dat'];
        name_datafile_w = [ 'a' , num2str(m), '_', 'b', num2str(n), '.dat'];
        fprintf('file load: %s\n',name_datafile_r)
        
        file_namer = folder_name_2th + name_datafile_r;
        file_namew = folder_namew + name_datafile_w;
        
        file_source =  fopen(file_namer, 'r');
        file_channel =  fopen(file_namew, 'w');
        ChEncType = ChannelEncode_Array{1,joint_type(m,n,1,2)};
        

        fprintf('Start: m is %d, n is %d\n',m,n)% disp(['eee',num2str(a)])
        fprintf('信源编码类型  is %d\n',m)% disp(['eee',num2str(a)])
        fprintf('信道编码类型  is %s\n',ChEncType)% disp(['eee',num2str(a)])
        fprintf('信道编码对应的每一包的帧数量  is %d\n',pkt_num_channel)% disp(['eee',num2str(a)])
        fprintf('信道编码包中的帧长度  is %d\n',length_frame_ch)% disp(['eee',num2str(a)])

        count = readlength;
        cnt_fread = 0;
        data_read_base = 1:1:readlength;
        data_buff = zeros(len_data_buff, 1);
        buff_idx = 0;         %buff的有效数据的最后一位
        buff_len = 0;         %buff的有效数据的长度

        
        while (count ~= 0) 
%             tic
            if (buff_idx < Fun_Ch_datain_length) % 小于一次待处理的长度就再读取一次
                [data_read, count] = fread(file_source,readlength, '*ubit1','ieee-be');
                data_read = double(data_read);

                data_buff(buff_idx+1 : buff_idx + count) = data_read; % 填充新的数据进入buffer                
                buff_idx = buff_idx + count;
            end
            datain = data_buff(1: Fun_Ch_datain_length); % 新的待编码的数据块

            data_buff(1:len_data_buff-Fun_Ch_datain_length) = data_buff(Fun_Ch_datain_length+1:end); % buffer 剩下的数据移到最前方
            buff_idx = buff_idx - Fun_Ch_datain_length; % 
              
            [ChannelEnc_DataOut,ChEncFrames,FrameLength] = Fun_ChannelEncode(datain,ChEncType,id_b1_childtype,pkt_num_channel,select_Funchannelencode,sync_header);
            
            count_w = fwrite(file_channel, ChannelEnc_DataOut, '*ubit1','ieee-be');
%             toc
            
        end
        
        
        fclose(file_source);
        fclose(file_channel);    
        fprintf('END: m is %d, n is %d\n',m,n)% disp(['eee',num2str(a)])
        
        toc
    end
end
toc
load handel
sound(y,Fs)


% [ChannelEnc_DataOut,ChEncFrames,FrameLength] = Fun_ChannelEncode(datain,ChEncType,id_ChannelEncode,select_Funchannelencode,sync_header);
