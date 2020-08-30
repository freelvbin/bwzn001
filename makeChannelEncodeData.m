clear;
ChannelEncode_Array = {'None', 'CRC' ,'Conv' ,'Hamming', 'Turbo', 'TPC', 'LDPC'};
ChEncType = 'TPC';
Nsym = 1e6;
id_ChannelEncode = 3;

datain = randi([0 1],Nsym,1);
sync_header = [0 1 0 0 0 0 1 0];

%%
[ChannelEnc_DataOut,ChEncFrames,FrameLength] = Fun_ChannelEncode(datain,ChEncType,id_ChannelEncode,1,sync_header);
file_name_ChEnc_base  = ['EnCh_',ChEncType,'_', num2str(FrameLength),'_', num2str(length(sync_header)), '_' ,num2str(ChEncFrames),'_', num2str(id_ChannelEncode), '_data.dat'];
file_name_ChEnc = ['.\EncodeData\',file_name_ChEnc_base];

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
