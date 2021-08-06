function out = spectrum( obj, fftlen, calOvrlp )
%
% Compute and return the power spectral density, and corresponding 
%   frequency vector, in power (dB) per Hz, based on the given FFT length.
%

if (length(obj.samples) == 0)
    error([' TimeData object for ', obj.DataCommon.source, ' has no samples']);
end

fs = obj.sampleRate;
freqRes = fs / fftlen;

if nargin > 2
  quo = floor( length(obj)/fftlen ) - 1;
  rmm = rem( length(obj), fftlen );
  padr = floor( (quo*fftlen+rmm) / 8 );
else
  padr = fftlen/2;
end
	

%[samps freqs] = pwelch(obj.samples, window(@bartlett,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@barthannwin,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@blackman,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@blackmanharris,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@bohmanwin,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@flattopwin,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@hamming,fftlen), fftlen/2, fftlen, fs);
[samps freqs] = pwelch(obj.samples, window(@blackman,fftlen), padr, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@kaiser,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@nuttallwin,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@parzenwin,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@rectwin,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@tukeywin,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = pwelch(obj.samples, window(@triang,fftlen), fftlen/2, fftlen, fs);
%[samps freqs] = periodogram(obj.samples, '', fftlen, fs);
%[samps freqs] = pmcov(obj.samples, 256, fftlen, fs);
%[samps freqs] = pmusic(obj.samples, 1, fftlen, fs);
%[samps freqs] = pmtm(obj.samples, 8, fftlen, fs);
%[samps freqs] = peig(obj.samples,512, fftlen, fs);
% XXX Clark Orig
%[samps freqs] = pwelch(obj.samples, fftlen, fftlen/2, fftlen, fs);

out.title = obj.DataCommon.title;

rootHz = 0;
if rootHz
  out = FrequencyData(obj.DataCommon, sqrt(samps), freqRes);
  out.valueType = [ obj.valueType '/rootHz' ];
else
  out = FrequencyData(obj.DataCommon, samps, freqRes);
  out.valueType = [ obj.valueType '^2/Hz' ];
  % psdPwr = sum(out.samples) * freqRes
  % sigPwr = sum(obj.samples.^2)/length(obj)
end
out.valueUnit = 'lin';

