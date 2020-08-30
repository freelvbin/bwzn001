function x = RandAnSig(Lsamp,fm,fs)
u= wgn(Lsamp,1,0);
x(1,:)=u(1,:);
syms s
r = solve(s^2-2*s*cos(2*pi*(fm/2/fs))+1==2*(s-1)^2);
r = min(double(r));
for i = 2:Lsamp
    x(i,:)=r*x(i-1,:)+u(i,:);
end
fmflt = fir1(48,fm/(fs/2));
x = filter(fmflt,1,x);
x = x/max(abs(x));
