function [DataOut,ChEncFrames,pktlength_mp] = Fun_ChannelEncode(SourceDatain,TypeChannelEncode,id,pkt_num_channel, RunEn,sync_header)

% DataOut = SourceDatain;
if TypeChannelEncode == "CRC"
    %     crcGen = comm.CRCGenerator('z4+z3+z2+z+1');
    if(id == 1)
        crcGen = comm.CRCGenerator('z8 + z7 + z6 + z4 + z3 + z2 +1');
        crcDet = comm.CRCDetector('z8 + z7 + z6 + z4 + z3 + z2 +1');
        pktlength_src = 64;
        pktlength_mp = pktlength_src +8;
    elseif(id == 2)
        crcGen = comm.CRCGenerator('z^16 + z^15 + z^2 + 1');
        crcDet = comm.CRCDetector('z^16 + z^15 + z^2 + 1');
        pktlength_src = 128;
        pktlength_mp = pktlength_src+ 2 * 8;
    else
        crcGen = comm.CRCGenerator('z^24 + z^23 + z^14 + z^12 + z^8 + 1');
        crcDet = comm.CRCDetector('z^24 + z^23 + z^14 + z^12 + z^8 + 1');
        pktlength_src = 192;
        pktlength_mp = pktlength_src+ 3 * 8;
    end
    length_syncheader = length(sync_header);
    ChEncFrames = (length(SourceDatain)/pktlength_src);
%     ChEncFrames = floor(length(SourceDatain)/pktlength_src);

    encData = zeros(ChEncFrames*pktlength_mp,1);
    frmError = zeros(1,ChEncFrames);
    if(RunEn == 1)
        for m = 1:ChEncFrames
            crcdatain = SourceDatain((m-1)*pktlength_src+1:m*pktlength_src);
            crcdataout = step(crcGen,crcdatain);                % iAppend CRC bits
            %         modData = pskmod(encData,2);                % BPSK modulate
            %         rxSig = awgn(modData,5);                    % AWGN channel, SNR = 5 dB
            %         demodData = pskdemod(rxSig,2);              % BPSK demodulate
            encData((m-1)*pktlength_mp + 1: m*pktlength_mp) = crcdataout;
%             [~,frmError(m)] = step(crcDet,crcdataout);  % Detect CRC errors
        end
        Frame_data_len = pktlength_mp*pkt_num_channel;
        pktlength_mp = Frame_data_len + length_syncheader;
        pkt_nums = ChEncFrames/pkt_num_channel;
        encData_out = zeros(pkt_nums*pktlength_mp,1);
        for m = 1:pkt_nums
            crcdata = encData((m-1)*Frame_data_len+1: m*Frame_data_len);
            encData_out((m-1)*pktlength_mp + 1: m*pktlength_mp) = [sync_header, crcdata'];
        end
    end
    DataOut = encData_out;
%     disp('CRC END');
elseif TypeChannelEncode == "Conv"
    %     trellis = poly2trellis(5, [37 33], 37);
%     %% generate crc data for SourceDataIn
%     if(id == 1)
%         crcGen = comm.CRCGenerator('z8 + z7 + z6 + z4 + z3 + z2 +1');
%         pktlength_src = 64;
%         FrameLength = pktlength_src+8;
%     elseif(id == 2)
%         crcGen = comm.CRCGenerator('z^16 + z^15 + z^2 + 1');
%         pktlength_src = 128;
%         FrameLength = pktlength_src+ 2 * 8;
%     end
%     ChEncFrames = floor(length(SourceDatain)/pktlength_src);
%     for m = 1:ChEncFrames
%         crcdatain = SourceDatain((m-1)*pktlength_src+1:m*pktlength_src);
%         crcdataout = step(crcGen,crcdatain);                % iAppend CRC bits
%         encData((m-1)*FrameLength + 1: m*FrameLength) = crcdataout;
%         %             [~,frmError(m)] = step(crcDet,crcdataout);  % Detect CRC errors
%     end
%     SourceDatain =  encData;   
        
    if(id == 1)
        trellis = poly2trellis(7,[171 133]);
        framelength_msg = 72;
        rate = 1/2;
    else
        trellis = poly2trellis([5 4],[23 35 0; 0 5 13]);
        framelength_msg = 144;
        rate = 2/3;
    end
    
%     ChEncFrames = floor(length(SourceDatain)/framelength_msg);
%     num_packets = floor(ChEncFrames/pkt_num_channel);
    ChEncFrames = (length(SourceDatain)/framelength_msg);
    num_packets = (ChEncFrames/pkt_num_channel);    
    pktlength_mp = framelength_msg/(rate);
    encData = (convenc(SourceDatain,trellis))';
    length_packets_nosync = framelength_msg/(rate)*pkt_num_channel;
    length_packets_sync = (framelength_msg/(rate))*pkt_num_channel + length(sync_header);
    DataOut_sync = zeros(1,length_packets_sync*num_packets);
    for m = 1:num_packets
        DataOut_sync((m-1)*length_packets_sync+1 : m*length_packets_sync) = [sync_header, encData((m-1)*length_packets_nosync + 1:m*length_packets_nosync)];
    end
%     if (RunEn == 1)
%         decodedData = vitdec(DataOut_nosync,trellis,34,'trunc','hard');
%     end
    DataOut = DataOut_sync;
%     disp('Conv END');
%     find(decodedData~= SourceDatain)
elseif TypeChannelEncode == "Hamming"
    n = 15;                % Code length
    k = 11;                % Message length    

    pktlength_mp = n;
%     ChEncFrames = floor(length(SourceDatain)/k);
    ChEncFrames = (length(SourceDatain)/k);

    decData = zeros(1,ChEncFrames*n);
    if(RunEn == 1)
        for m = 1:ChEncFrames
            msgdata = SourceDatain((m-1)*k+1:m*k);
            encData((m-1)*n+1:m*n) = encode(msgdata,n,k,'hamming/binary');
        end
        %gen packet with num_frame;
        num_packets = (ChEncFrames/pkt_num_channel);
%         num_packets = floor(ChEncFrames/pkt_num_channel);

        length_packets_nosync = pkt_num_channel*n;
        length_packets_sync = length_packets_nosync + length(sync_header);
        data_packet = zeros(1,num_packets*length_packets_sync);
        for m = 1:num_packets
            data_packet((m-1)*length_packets_sync+1:m*length_packets_sync) = [sync_header,encData((m-1)*length_packets_nosync+1:m*length_packets_nosync)];
        end
        DataOut = data_packet;

    end
%     disp('Hamming END');
elseif TypeChannelEncode == "Turbo"
    rng(10,'twister');
    pktlength_src = 64;
    intrlvrInd = randperm(pktlength_src);
    turboEnc = comm.TurboEncoder('InterleaverIndicesSource','Input port');
    turboDec = comm.TurboDecoder('InterleaverIndicesSource','Input port', ...
        'NumIterations',4);
    rate = pktlength_src/(3*pktlength_src+4*3);
    % The default is the result of poly2trellis(4, [13 15], 13).
    % Generate random binary data
    %     data = randi([0 1],pktLen,1);
    % Interleaver indices
    ChEncFrames = (length(SourceDatain)/pktlength_src);    
%     ChEncFrames = floor(length(SourceDatain)/pktlength_src);
    pktlength_mp = 3*pktlength_src+4*3;
    if(RunEn == 1)
        encData = zeros(1,ChEncFrames*pktlength_mp);
        for m = 1: ChEncFrames
            data_frame = SourceDatain((m-1)*pktlength_src+1 :m*pktlength_src);
            % Turbo encode the data
            encodedData = turboEnc(data_frame,intrlvrInd);
            % Turbo decode the demodulated signal. Because the bit mapping from the
            % demodulator is opposite that expected by the turbo decoder, the
            % decoder input must use the inverse of demodulated signal.
%             encodedData2 = 2*encodedData -1;
%             rxBits = turboDec(encodedData2,intrlvrInd);
%             % Calculate the error statistics
%             errorRate = comm.ErrorRate;
%             errorStats = errorRate(data_frame,rxBits);
            
            encData((m-1)*pktlength_mp + 1: m*pktlength_mp) = encodedData';
        end
        
        %gen packet with num_frame;
        num_packets = (ChEncFrames/pkt_num_channel);        
%         num_packets = floor(ChEncFrames/pkt_num_channel);
        length_packets_nosync = pkt_num_channel*pktlength_mp;
        length_packets_sync = length_packets_nosync + length(sync_header);
        data_packet = zeros(1,num_packets*length_packets_sync);
        for m = 1:num_packets
            data_packet((m-1)*length_packets_sync+1:m*length_packets_sync) = [sync_header,encData((m-1)*length_packets_nosync+1:m*length_packets_nosync)];
        end
        DataOut = data_packet;        
        
    end
%     disp('Turbo END');
elseif TypeChannelEncode == "TPC"
    %     Decode Using Full-Length TPC Codes
    N = [32;16];
    K = [21;11];
    messageLength = prod(K);
    pktlength_mp = prod(N);
    ChEncFrames = (length(SourceDatain)/messageLength);    
%     ChEncFrames = floor(length(SourceDatain)/messageLength);
    if(RunEn == 1)
        encData = zeros(1,ChEncFrames*pktlength_mp);
        for m= 1:ChEncFrames
            msg = SourceDatain((m-1)*messageLength+1 :m*messageLength);
            encodedData = tpcenc(msg,N,K);
            encData((m-1)*pktlength_mp + 1: m*pktlength_mp) = encodedData';
%             llr = 2*encodedData -1;
%             decoded = tpcdec(llr,N,K,[],iterations);
%             numerr = biterr(msg,decoded);
        end
        
         %gen packet with num_frame;
        num_packets = (ChEncFrames/pkt_num_channel);         
%         num_packets = floor(ChEncFrames/pkt_num_channel);
        length_packets_nosync = pkt_num_channel*pktlength_mp;
        length_packets_sync = length_packets_nosync + length(sync_header);
        data_packet = zeros(1,num_packets*length_packets_sync);
        for m = 1:num_packets
            data_packet((m-1)*length_packets_sync+1:m*length_packets_sync) = [sync_header,encData((m-1)*length_packets_nosync+1:m*length_packets_nosync)];
        end
        DataOut = data_packet;         
        
        
    end
%     disp('TPC END');
    
elseif TypeChannelEncode == "LDPC"
    %     Parity-check matrix
    % Specify the parity-check matrix as a binary valued sparse matrix P with dimension (N ¨C K) by N, where N > K > 0. The last N?K columns in the parity check matrix must be an invertible matrix in GF(2). Alternatively, you can specify a two-column, non-sparse integer index matrix I that defines the row and column indices of the 1s in the parity-check matrix, such that P = sparse(I(:,1), I(:,2), 1).
    % This property accepts numeric data types. When you set this property to a sparse matrix, it also accepts a logical data type. The upper bound for the value of N is 231-1.
    % The default is the sparse parity-check matrix of the half-rate LDPC code from the DVB-S.2 standard, which is the result of dvbs2ldpc(1/2).
    % To generate code, set this property to a non-sparse index matrix. For instance, you can obtain the index matrix for the DVB-S.2 standard from dvbs2ldpc(R, 'indices') with the second input argument explicitly specified to indices, where R represents the code rate.
    if(id == 1)
        rate = 1/4;
    elseif(id == 2)
        rate = 1/3;
    elseif(id == 3)
        rate = 2/5;
    elseif(id == 4)
        rate = 1/2;
    elseif(id == 5)        
        rate = 3/5;
    end
    
    p = dvbs2ldpc(rate);
    pktlength_src = 64800*rate;
    pktlength_mp = 64800;
    length_packets_sync = pktlength_mp + length(sync_header);
    ldpcEnc = comm.LDPCEncoder(p);
    ldpcDec = comm.LDPCDecoder(p);
    hError = comm.ErrorRate;
     
    ChEncFrames = (length(SourceDatain)/pktlength_src);
%     ChEncFrames = floor(length(SourceDatain)/pktlength_src);
    
    DataOut = zeros(1,ChEncFrames*length_packets_sync);
    if(RunEn == 1)
        for i = 1:ChEncFrames
    %         msgdata = randi([0 1],framelength_msg,1);   % Generate binary data
            msgdata = SourceDatain((i-1)*pktlength_src+1: i*pktlength_src);
            encData = step(ldpcEnc, msgdata);                % Apply LDPC encoding
            DataOut((i-1)*length_packets_sync+1:i*length_packets_sync) = [sync_header, encData'];
        end   
%         DataOut = encData; 
    %     rxData = step(ldpcDec, encData)+0;           % Decode LDPC
    %     errorStats     = step(hError, msgdata, rxData);
    end
%     disp('LDPC END');

end
