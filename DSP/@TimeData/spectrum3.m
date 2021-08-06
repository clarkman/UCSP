function out = spectrum3( d )

dtilde= Dt*fft(d-mean(d));  % Fourier Transform

dtilde = dtilde(1:Nf);

psd = (2/T)*abs(dtilde).^2;

pwr=df*cumsum(psd);

Pf=df*sum(psd);

Pt=sum(d.^2)/N;