%generate data_2th datafile
% 0x56 + sync_count(8b) + data(96bit)
% SrEncType = a1霍夫曼、a2算术、a3 L-Z、a4 ADPCM、a5 MPEG-2、a6 H.264、a7 H.265、a8 G.711、a9 G.721、a10 G.723

% 
clear;
filenames_source = ["huffman.dat"  "lz.dat"  "ac.dat" "8k.adpcm" "nedzq.mpeg2.m2v" "nedzq.h264" "nedzq.h265" "8k.711u.pcm" "8k.721.pcm" "8k.723.24.pcm"];
base_pathr = "D:\LBWork\BWZN\XHFX\Data\信源编码\";
base_pathw = "D:\LBWork\BWZN\XHFX\Data\信源编码\data_2th\";

for m = 1:length(filenames_source)
    filename_data2th = base_pathw + "a"+ num2str(m) + "_2th.dat";
    filenames_r = base_pathr + filenames_source(m);
 
    DataOut = gen_data_2th_0(filenames_r, filename_data2th );
end

% load handel
% sound(y,Fs)

function DataOut = gen_data_2th_0(filenames_r,filename_data2th)

    file_data_r =  fopen(filenames_r, 'r');
    file_data_w =  fopen(filename_data2th, 'w');   
    
    data2_pktlen = (96/8);
    data2_frmlen = data2_pktlen+2;
    [data_read, data_read_cnt] = fread(file_data_r);
    fclose(file_data_r);


    len_data = length(data_read);
    pkt_num = ceil(len_data/(96/8));
    data_mux = zeros(1,pkt_num * data2_frmlen);

    for i = 1:(pkt_num-1)
        data_mux(data2_frmlen*(i-1)+1) = 86;
        data_mux(data2_frmlen*(i-1)+2) = mod(i,255);
        data_mux(data2_frmlen*(i-1)+3:data2_frmlen*i) = data_read(data2_pktlen*(i-1)+1:data2_pktlen*i);
    end
    tail_last_pkt = mod(len_data,(96/8));
    if (tail_last_pkt ~= 0)
        data_mux(data2_frmlen*(pkt_num-1)+1) = 86;
        data_mux(data2_frmlen*(pkt_num-1)+2) = pkt_num;
        data_mux(data2_frmlen*(pkt_num-1)+3:data2_frmlen*(pkt_num-1)+2+tail_last_pkt) = data_read(data2_pktlen*(pkt_num-1)+1:data2_pktlen*(pkt_num-1)+tail_last_pkt);
        data_mux(data2_frmlen*(pkt_num-1)+3+tail_last_pkt:end) = 0;
    end
    DataOut = data_mux;
    len_data_mux = length(data_mux);
    
    loop_times = ceil(50e6/len_data_mux);
    for k = 1:loop_times
        fwrite(file_data_w, data_mux); 
    end

    fclose(file_data_w);    
end
