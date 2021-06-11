function [InSig,PhaseOut] = fun_SigGen(datain,modtype,rb,fc,fc_fm,fs,Lsamp,SNR ,PhaseIn )
%%
warning ('off','all')
%% parameters
Mod_Method = modtype;
rb_side = rb/10; % 符号速率
% fm = rb; % 模拟基带信号带宽
fm_fm = rb/24; % FM信号模拟基带信号带宽 rb/12
a = 0.5; % AM 信号调制指数
Belt_f = 5; % FM信号调制指数

sps = fs/rb;      % 过采样率
Nsamp_side = fs/rb_side;      % 过采样率
alpha = 0.3; % 成型因子

% t = (0:1/fs:Lsamp/fs-1/fs)';
span = 10;       % Filter span
% theta = rand*pi*2;

%%
sourcedata = datain;
switch Mod_Method
    case 'FM'
%         AnalogSig_fm = RandAnSig(Lsamp,fm_fm,fs); % 产生的信号本身即是幅度归一化的
        fdev = Belt_f*fm_fm/max(abs(datain)); % 频率偏移常数Kf
        msg_mod = fmmod(datain,fc_fm,fs,fdev);
    case '2FSK'
        freq_sep = rb; % FSK频率间隔
        msg_mod = fskmod(sourcedata,2,freq_sep,sps,fs,'discont');%
    case 'MSK'
        msg_mod = mskmod(sourcedata,sps,[],pi/2);
    case 'GMSK'
        gmskMod = comm.GMSKModulator('BitInput',true,'PulseLength',1, ...
            'SamplesPerSymbol',sps);
    case 'BPSK'
        msg_mod = pskmod(sourcedata,2,pi/2);
        %         msg_mod = modulate(modem.pskmod('M',2), randi([0 1],Nsym,1));
    case 'QPSK'
        qpskModulator = comm.QPSKModulator('BitInput',true);
        msg_mod = qpskModulator(sourcedata);
    case 'DQPSK'       
        dqpskmod = comm.DQPSKModulator('BitInput',true);
        msg_mod = dqpskmod(sourcedata);
    case 'OQPSK'
%         oqpskmod = comm.OQPSKModulator('BitInput',true);
%         msg_mod = oqpskmod(sourcedata);
        modulator = comm.OQPSKModulator('BitInput',true,'SamplesPerSymbol',sps,'PulseShape','Root raised cosine');
        msg_mod = modulator(sourcedata);
    case '8PSK'%,'PhaseOffset',pi/4
        pskModulator = comm.PSKModulator('BitInput',true);
        msg_mod = pskModulator(sourcedata);
    case '16QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,16,'InputType','bit','UnitAveragePower',true);
    case '32QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,32,'InputType','bit','UnitAveragePower',true);
    case '64QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,64,'InputType','bit','UnitAveragePower',true);
    case '256QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,256,'InputType','bit','UnitAveragePower',true);
    case '16APSK'%,'PhaseOffset',pi/4
        M = [8 8];
        radii = [0.5 1.5];
        msg_mod = apskmod(sourcedata,M,radii,'InputType','bit');
    case '32APSK'%,'PhaseOffset',pi/4
        M = [4 12 16];
        radii = [0.8 1.2 1.8];
        msg_mod = apskmod(sourcedata,M,radii,'InputType','bit');
end

%% Shaping and AWGN Channel
if (strcmp(Mod_Method,'CW')||strcmp(Mod_Method,'AM')||strcmp(Mod_Method,'DSB')||strcmp(Mod_Method,'SSB')...
        ||strcmp(Mod_Method,'FM')||strcmp(Mod_Method,'MSK')||strcmp(Mod_Method,'2FSK')||strcmp(Mod_Method,'4FSK')...
        ||strcmp(Mod_Method,'FQPSK')||strcmp(Mod_Method,'FM-FM')||strcmp(Mod_Method,'PCM-FSK-PM')||strcmp(Mod_Method,'PCM-FM')) == 1
    msg_mod_shape = msg_mod;
elseif strcmp(Mod_Method,'OQPSK') == 1
%     msg_mod_shape_t = rcosflt(msg_mod,1,sps/4,'fir/sqrt',alpha); %
%     msg_mod_shape = msg_mod_shape_t(sps/2+1:end-sps);
    msg_mod_shape = msg_mod;
elseif strcmp(Mod_Method,'GMSK') == 1
        msg_mod_shape = gmskMod(sourcedata);
elseif strcmp(Mod_Method,'256QAM') == 1
    txfilter2 = comm.RaisedCosineTransmitFilter('RolloffFactor',0.9, ...
        'FilterSpanInSymbols',span,'OutputSamplesPerSymbol',sps);
    msg_mod_shape = txfilter2(msg_mod);
else  
    rrcFilter = rcosdesign(alpha, span, sps);
    msg_mod_shape = upfirdn(msg_mod, rrcFilter, sps);
    cutpoint = length(rrcFilter) - sps;
    leftstart = floor(cutpoint/2);
    rightendpoint = length(msg_mod_shape) - (cutpoint - leftstart);
    msg_mod_shape = msg_mod_shape(leftstart+1:rightendpoint);
end
%载波
if (strcmp(Mod_Method,'AM')||strcmp(Mod_Method,'DSB')||strcmp(Mod_Method,'SSB')||strcmp(Mod_Method,'FM')...
        ||strcmp(Mod_Method,'CW')||strcmp(Mod_Method,'FM-FM')) == 1
    msg_mod_carrier = msg_mod_shape; % MSK
    PhaseOut = 0;
else
    msg_mod_carrier = msg_mod_shape.*exp(1j*(2*pi*(fc)*(1:length(msg_mod_shape))/fs + PhaseIn))';
    PhaseOut = 2*pi* fc*length(msg_mod_shape)/fs;
end

% k = log2(M);        % Bits/symbol
% EbNo = 20;
% snr = EbNo + 10*log10(k) - 10*log10(sps);

msg_trans = real(msg_mod_carrier);
msg_detect = awgn(msg_trans,SNR,'measured');
InSig = msg_detect/max(abs(msg_detect));

% InSig = msg_mod_carrier;
InSig = hilbert(InSig);
% rxSig = awgn(msg_mod_shape,SNR,'measured');
% data_scatterplot = sqrt(sps)*rxSig(sps*span+1:sps:end-sps*span);

%% 下变频 产生星座图
lpFilt = designfilt('lowpassfir','PassbandFrequency',0.3, ...
         'StopbandFrequency',0.4,'PassbandRipple',0.5, ...
         'StopbandAttenuation',65,'DesignMethod','kaiserwin');

     
msg_detect_IQMix = InSig.*exp(-1*j*(2*pi*(fc)*(1:length(msg_mod_shape))/fs))';
% % 混频+滤波
% msg_detect_I_mix = InSig.*cos((2*pi*fc*(1:length(InSig))'/fs)); % 混频
% msg_detect_Q_mix = InSig.* sin((2*pi*fc*(1:length(InSig))'/fs));
% msg_detect_IQMix = msg_detect_I_mix + 1i * msg_detect_Q_mix;

pwelch(msg_detect_IQMix)
title('下变频频谱')
scatterplot(msg_detect_IQMix(floor(sps/2):sps:end))
 title('下变频数据星座图（中间点）')
scatterplot(msg_detect_IQMix(floor(sps/2)+1:sps:end))
 title('下变频数据星座图（中间点+1）')
scatterplot(msg_detect_IQMix(floor(sps/2)+2:sps:end))
 title('下变频数据星座图（中间点+2）')
scatterplot(msg_detect_IQMix(floor(sps/2)+3:sps:end))
 title('下变频数据星座图（中间点+3）')

 msg_detect_I_mix = real(msg_detect_IQMix);
 msg_detect_Q_mix = imag(msg_detect_IQMix);
msg_detect_I = filter(lpFilt,msg_detect_I_mix); % 低通滤波
msg_detect_Q = filter(lpFilt,msg_detect_Q_mix); % 低通滤波

msg_detect_IQ = msg_detect_I+1i*msg_detect_Q;

% scatterplot(msg_detect_IQ(sps*span+floor(sps/2):sps:end-sps*span))
% scatterplot(msg_detect_IQ(floor(sps/2):sps:end))
%  title('下变频数据星座图（中间点）')
% scatterplot(msg_detect_IQ(floor(sps/2)+1:sps:end))
%  title('下变频数据星座图（中间点+1）')
% scatterplot(msg_detect_IQ(floor(sps/2)+2:sps:end))
%  title('下变频数据星座图（中间点+2）')
% scatterplot(msg_detect_IQ(floor(sps/2)+3:sps:end))
%  title('下变频数据星座图（中间点+3）')

tic

end