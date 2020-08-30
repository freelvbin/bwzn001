function [InSig,data_scatterplot,PhaseOut] = fun_SigGen(datain,modtype,rb,fc,fc_fm,fs,Lsamp,SNR ,PhaseIn )
%%
warning ('off','all')
%% parameters
Mod_Method = modtype;
rb_side = rb/10; % ��������
% fm = rb; % ģ������źŴ���
fm_fm = rb/24; % FM�ź�ģ������źŴ��� rb/12
a = 0.5; % AM �źŵ���ָ��
Belt_f = 5; % FM�źŵ���ָ��

sps = fs/rb;      % ��������
Nsamp_side = fs/rb_side;      % ��������
alpha = 0.2; % ��������

% t = (0:1/fs:Lsamp/fs-1/fs)';
span = 10;       % Filter span
% theta = rand*pi*2;

%%
sourcedata = datain;
switch Mod_Method
    case 'FM'
        AnalogSig_fm = RandAnSig(Lsamp,fm_fm,fs); % �������źű����Ƿ��ȹ�һ����
        fdev = Belt_f*fm_fm/max(abs(AnalogSig_fm)); % Ƶ��ƫ�Ƴ���Kf
        msg_mod = fmmod(AnalogSig_fm,fc_fm,fs,fdev);
    case '2FSK'
        freq_sep = rb; % FSKƵ�ʼ��
        msg_mod = fskmod(sourcedata,2,freq_sep,sps,fs,'discont');%
    case 'MSK'
        msg_mod = mskmod(sourcedata,sps,[],pi/2);
    case 'GMSK'
        gmskMod = comm.GMSKModulator('BitInput',true,'PulseLength',1, ...
            'SamplesPerSymbol',sps);
        msg_mod = gmskMod(sourcedata);
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
        oqpskmod = comm.OQPSKModulator('BitInput',true);
        msg_mod = oqpskmod(sourcedata);
        %         msg_mod = modulate(modem.pskmod('M',4), randi([0 3],Nsym+1,1)); %����QPSK������ӳ�䣬���ͺ���ƫ�ư������
    case '8PSK'%,'PhaseOffset',pi/4
        pskModulator = comm.PSKModulator('BitInput',true);
        msg_mod = pskModulator(sourcedata);
    case '16QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,16,'InputType','bit','UnitAveragePower',true);
    case '32QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,32,'InputType','bit','UnitAveragePower',true);
    case '64QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,32,'InputType','bit','UnitAveragePower',true);
    case '256QAM'%,'PhaseOffset',pi/4
        msg_mod = qammod(sourcedata,256,'InputType','bit','UnitAveragePower',true);
    case '16APSK'%,'PhaseOffset',pi/4
        radii = [0.5 1.5];
        msg_mod = apskmod(sourcedata,16,radii,'InputType','bit');
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
    msg_mod_shape_t = rcosflt(msg_mod,1,sps/4,'fir/sqrt',alpha); %
    %     msg_mod_shape_t = msg_mod_shape_t(3*Nsamp+1:end-3*Nsamp);
    %     msg_mod_shape = [real(msg_mod_shape_t);zeros(Nsamp/2,1)]+1i*[zeros(Nsamp/2,1);imag(msg_mod_shape_t)];% IQƫ�ư����������
    msg_mod_shape = msg_mod_shape_t(sps/2+1:end-sps);
elseif strcmp(Mod_Method,'UQPSK1')||strcmp(Mod_Method,'UQPSK2') ||strcmp(Mod_Method,'UQPSK3') ||strcmp(Mod_Method,'UQPSK4') == 1
    msg_mod_shape_I = rcosflt(msg_mod_I,1,sps/belt_rate,'fir/sqrt',alpha); %
    msg_mod_shape_I = msg_mod_shape_I(3*sps/belt_rate+1:end-3*sps/belt_rate);
    msg_mod_shape_Q = rcosflt(msg_mod_Q,1,sps,'fir/sqrt',alpha); %
    msg_mod_shape_Q = msg_mod_shape_Q(3*sps+1:end-3*sps);
    msg_mod_shape = msg_mod_shape_I + 1j*msg_mod_shape_Q;
elseif strcmp(Mod_Method,'PCM-BPSK-PM')||strcmp(Mod_Method,'PCM-QPSK-PM') == 1
    msg_mod_shape = rcosflt(msg_mod,1,Nsamp_side,'fir/sqrt',alpha); %
    msg_mod_shape = msg_mod_shape(3*Nsamp_side+1:end-3*Nsamp_side);
else
    
    rrcFilter = rcosdesign(alpha, span, sps);
    msg_mod_shape = upfirdn(msg_mod, rrcFilter, sps);
    msg_mod_shape = msg_mod_shape(23+1:end-23);
end
%�ز�
if (strcmp(Mod_Method,'AM')||strcmp(Mod_Method,'DSB')||strcmp(Mod_Method,'SSB')||strcmp(Mod_Method,'FM')...
        ||strcmp(Mod_Method,'CW')||strcmp(Mod_Method,'FM-FM')) == 1
    msg_mod_carrier = msg_mod_shape; % MSK
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

rxSig = awgn(msg_mod_shape,SNR,'measured');
data_scatterplot = sqrt(sps)*rxSig(sps*span+1:sps:end-sps*span);

%% �±�Ƶ ��������ͼ
lpFilt = designfilt('lowpassfir','PassbandFrequency',0.3, ...
         'StopbandFrequency',0.4,'PassbandRipple',0.5, ...
         'StopbandAttenuation',65,'DesignMethod','kaiserwin');
     
% % ��Ƶ+�˲�
msg_detect_I_mix = InSig.*cos((2*pi*fc*(1:length(InSig))'/fs)); % ��Ƶ
msg_detect_Q_mix = InSig.* sin((2*pi*fc*(1:length(InSig))'/fs));

msg_detect_I = filter(lpFilt,msg_detect_I_mix); % ��ͨ�˲�
msg_detect_Q = filter(lpFilt,msg_detect_Q_mix); % ��ͨ�˲�

msg_detect_IQ = msg_detect_I+1i*msg_detect_Q;

% scatterplot(msg_detect_IQ(sps*span+floor(sps/2):sps:end-sps*span))
scatterplot(msg_detect_IQ(floor(sps/2):sps:end))

end