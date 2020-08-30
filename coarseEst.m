function [Fc_est,B_est]=coarseEst(SigIn,nFFT,fs)%,bandSel
%% ��Ƶ����
% SigIn = S_Q; 
% nFFT = 8192;
% fs = fs/4;
[pxx,f] = pwelch(SigIn,nFFT,nFFT/2,nFFT,fs);
pxxSum_part = zeros(1,length(pxx));
for i = 1:length(pxx)
    pxxSum_part(i) = sum(pxx(1:i));
end
fc_ind_est = find(abs(pxxSum_part - pxxSum_part(end)/2) == min(abs(pxxSum_part - pxxSum_part(end)/2))); % �����ԳƵ�
Fc_est = f(fc_ind_est);
%% �������
% ����������
% for i = 1:min(length(pxx)-fc_ind_est,fc_ind_est-1)
%     pxxSum_fc_part(i) = sum(pxx(fc_ind_est-i:fc_ind_est+i));
% end
% switch bandSel
%     case '90%'
%         B_ind_est =  find(abs(pxxSum_fc_part - pxxSum_part(end)*0.9) == min(abs(pxxSum_fc_part - pxxSum_part(end)*0.9)));
%     case '99%'
%         B_ind_est =  find(abs(pxxSum_fc_part - pxxSum_part(end)*0.99) == min(abs(pxxSum_fc_part - pxxSum_part(end)*0.99)));
%     case '99.5%'
%         B_ind_est =  find(abs(pxxSum_fc_part - pxxSum_part(end)*0.995) == min(abs(pxxSum_fc_part - pxxSum_part(end)*0.99)));
% end
% B_est = B_ind_est*2*fs/nFFT;

% ���ȷ�����
pxx_Smooth = medfilt1(pxx,256);   %����ƽ��
% pxx_Smooth = pxx;   %����ƽ��
% figure;plot(f,10*log10(pxx_Smooth))
a_max = pxx_Smooth(fc_ind_est); % ����Ƶ��Ƶ��ֵ��Ϊ����ֵ������Ƶ�����ֵ����ΪƵ�׾�����ƽ̹
pxx_th = 0.5*a_max;

%����3dB����
for n1 = 1:length(pxx_Smooth)
    if pxx_Smooth(n1) > pxx_th;
        break;
    end
end
for n2 = length(pxx_Smooth):-1:1
   if pxx_Smooth(n2) >pxx_th;
       break;
   end
end
B_est =f(n2) - f(n1); %���ƵĴ���