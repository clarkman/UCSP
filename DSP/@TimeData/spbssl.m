function besselfilter(obj)

% SPA0711:  Design 6th order lowpass Bessel filter.
iband=1; fl=1000; fh=0; T=0.0001; L=6; pscl=1;
fln=fl*T;
fhn=fh*T;
[d,c]=spbssl(L,pscl);
[b,a]=spfblt(d,c,iband,fln,fhn);
freq=[0:200]*0.5/200;
amp=abs(spgain(b,a,freq));
fprintf('B(z) coef.:');...
fprintf('%7.4f',b(1:7));...
fprintf('\nA(z) coef.:');...
fprintf('%7.4f',a(1:7));
fprintf('\n')
plot([0:200]*5/200,amp,'w'); grid;...
      title('Figure 7.19');...
      xlabel('Frequency (kHz)');...
      ylabel('Magnitude');
end




function [d,c]=spbssl(L,pscl)
% [d,c]=spbssl(L,pscl)
% Generates analog filter coefficients for Lth order normalized
% lowpass Bessel filter.  See Section 7.5.  Response at 1 rad/s
% equals response of unscaled H(s) at pscl rad/s. 
% Inputs:
%    L    = Order of normalized low-pass analog filter.
%    pscl = Controls frequency scaling such that response at 1
%           rad/s equals that of unscaled H(s) at pscl rad/s.
% Outputs:  
%    d      = D(s) coefficient row vector.
%    c      = C(s) coefficient row vector.

if (L<=0 | pscl<=0)
   error('SPBSSL: Called with L and/or pscl not valid.');
end
for k=0:L
   denom=(2^(L-k))*spbfct(k,k)*spbfct(L-k,L-k);
   c(k+1)=(pscl^k)*spbfct(2*L-k,2*L-k)/denom;
end
d(1)=c(1);
return



function [b,a]=spfblt(d,c,iband,f1,f2)
% [b,a]=spfblt(d,c,iband,f1,f2)
% Converts normalized LP analog H(s) to digital H(Z).
% d,c=weights of analog H(s)=D(s)/C(s); iband (1-4)=band;
% f1,f2=low,high cutoff freqs. in Hz-s.  See Sect. 7.2.
%
%  Analog transfer function     Digital  transfer function
%         d(M)*s^M+...+d(0)            b(1)+...+b(M+1)*z^(-M)
%  H(s) = -----------------     H(z) = ----------------------
%         c(M)*s^M+...+c(0)              1+...+a(M+1)*z^(-M)
%
% Inputs:
%    d      = D(s) coefficient row vector.
%    c      = C(s) coefficient row vector.
%    iband  = 1  Lowpass  -- f1=normalized cutoff in Hz-s.
%             2  Highpass -- f1=normalized cutoff in Hz-s.
%             3  Bandpass -- f1=low cutoff; f2=high cutoff.
%             4  Bandstop -- f1=low cutoff; f2=high cutoff.
% Outputs:  
%    b      = B(z) coefficient row vector.
%    a      = A(z) coefficient row vector with a(1)=1.

if(length(c) < length(d)),
   c=[c, zeros(1,length(d)-length(c))];
elseif(length(d) < length(c)),
   d=[d, zeros(1,length(c)-length(d))];
end
Ln=length(c)-1;
work=zeros(Ln+1,Ln+1);
if (iband<1)|(iband>4)
   error('SPFBLT: iband is not in the range [1,4].');
end
if (f1<=0)|(f1>0.5)|((iband>=3)&((f1>=f2)|(f2>0.5)))
   error('SPFBLT: f1 and/or f2 is not valid.');
end
i=Ln;
ierror=1;
while i>=0,
   if (c(i+1)~=0)|(d(i+1)~=0)
      ierror=0;
      m=i;
      break
   end
   i=i-1;
end
if ierror==1
   error('SPFBLT: c and d weights are all zeros.');
end
w1=tan(pi*f1);
L=m;
if iband>2
   L=2*m;
   w2=tan(pi*f2);
   w=w2-w1;
   w02=w1*w2;
end

% Substitution of 1/s to generate highpass (HP,BS).
if (iband==2)|(iband==4),
   for mm=0:m/2,
      tmp=d(mm+1);
      d(mm+1)=d(m-mm+1);
      d(m-mm+1)=tmp;
      tmp=c(mm+1);
      c(mm+1)=c(m-mm+1);
      c(m-mm+1)=tmp;
   end
end

% Scaling s/w1 for lowpass, highpass.
if (iband==1)|(iband==2),
   d(1:m+1)=d(1:m+1)./((w1*ones(1,m+1)).^(1:m+1));
   c(1:m+1)=c(1:m+1)./((w1*ones(1,m+1)).^(1:m+1));
end

% Substitute (s^2+w0^2)/(w*s) for bandpass, bandstop.
if (iband==3)|(iband==4),
   work(1:L+1,1)=0*ones(L+1,1);
   work(1:L+1,2)=0*ones(L+1,1);
   for mm=0:m,
      tmpd=d(mm+1)*(w^(m-mm));
      tmpc=c(mm+1)*(w^(m-mm));
      for k=0:mm,
         Ls=m+mm-2*k;
         tmp=spbfct(mm,mm)/(spbfct(k,k)*spbfct(mm-k,mm-k));
         work(Ls+1,1)=work(Ls+1,1)+tmpd*(w02^k)*tmp;
         work(Ls+1,2)=work(Ls+1,2)+tmpc*(w02^k)*tmp;
      end
   end
   d(1:L+1)=work(1:L+1,1);
   c(1:L+1)=work(1:L+1,2);
end

% Substitute (z-1)/(z+1).
[b,a]=spbiln(d,c);
return
