function [a,b] = besselfilter(obj)

% SPA0711:  Design 6th order lowpass Bessel filter.
iband=1; fl=0.1; fh=0; T=1/32; L=12; pscl=1;
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
plot([0:200]*5/200,amp,'k'); grid;...
      title('Figure 7.19');...
      xlabel('Frequency (kHz)');...
      ylabel('Magnitude');

set( gca, 'XScale', 'log' );


