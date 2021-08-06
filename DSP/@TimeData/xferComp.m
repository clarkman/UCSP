function outObj = xferComp( inObj, fftlen, xferFunc )

% Prepare FFT ____________________________________________________________________

% We'd like to remove that true ADC offset counts, but
% we don't know what it is.  We know it's not 2^23, and
% we know that since we punted on calibration, this data
% we have has a mystery mean.  Just kill it.  XXX Clark.
avgObj = removeDC(inObj);
samps = avgObj.samples;
clear avgObj;

% To volts first.  QF sanity gained here.
pre=samps(3)
samps = samps(1:fftlen) * (40/(2^24));
post=samps(3)

% Truths about our FFT 
freqRes = inObj.sampleRate / fftlen;
duration = fftlen / inObj.sampleRate;

% For the rectangular-windowed version, Parseval's equality 
% must apply.  If we window the data, the ratio resulting
% can be treated as an inequality that revals how much of
% a scalar to apply to correct for the window.
window = 1;
if( window )
    % The prodigial son
    blak = blackman(fftlen);
    fftBins = fft( (samps .* blak), fftlen );
else
    fftBins = fft( samps, fftlen );
end

if( length(fftBins) ~= fftlen )
    error('Size mismatch');
end


% Now we compute the error introduced by the window via
% Parseval's method.

% Step 1 is to compute the RMS energy in the signal (no DC)
sum = 0;
for sth = 1 : fftlen
    sum = sum + samps(sth)^2;
end

% Step 2 is to compute the energy in the spectrum via the
% "modified" frequency spectrum.  Here we must adjust the
% zeroth and Nyquist bins scales, see S. Smith, et al.
fftSum = 0;
fftBins(1) = fftBins(1) / sqrt(2.0);
fftBins(fftlen/2+1) = fftBins(fftlen/2+1) / sqrt(2.0);
for sth = 1 : fftlen / 2 +1
    fftSum = fftSum + (abs(fftBins(sth)))^2;
end
% Scale for bandwidth
fftSum = fftSum * 2 / fftlen;

% Step 3 corrects the energy levels to account for the loss
% associated with windowing
if( window )
    if( fftSum > sum ), error( 'Ooops, spectrum is whacked' ), end;
    windowLoss = fftSum / sum
    fftSum = fftSum / windowLoss;
    fftBins = fftBins / windowLoss;
end

% Step 4 Proof of Parseval's relation:
if( abs( sum - fftSum ) > 0.001 )
    error('xfer Error');
end

% FFT is ready ___________________________________________________________________



% Apply compensation in the frequency domain _____________________________________

len = length(xferFunc)


%figure;
plotObj = FrequencyData( inObj.DataCommon, 2.0*abs(fftBins(1:len)) / (len/inObj.sampleRate), freqRes );
plotObj.valueType = 'Gammas/Hz^1/2';
plotObj.valueUnit = 'dB';


plot( plotObj, 'Color', [0.6 0 0] );
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log'); 

for binth = 2 : len
    rad = xferFunc(binth,3) * pi/180.0;
    impulseFreq = complex( xferFunc(binth,2) * cos(rad), xferFunc(binth,2) * sin(rad) );
   % impulseFreq
    if( isreal(impulseFreq) ), error( 'Ooops, xfer func not complex!!!' ), end;
    %if( isreal(fftBins(binth)) ), error( [ 'Ooops, fftBins(binth) not complex!!! ith=' sprintf('%d %g %g',binth,real(fftBins(binth)),imag(fftBins(binth))) ] ), end;
    fftBins(binth) = fftBins(binth) / impulseFreq;
end


frObj = FrequencyData( inObj.DataCommon, 2.0*abs(fftBins(1:len)) / (len/inObj.sampleRate), freqRes );
frObj.valueType = 'Gammas/Hz^1/2';
frObj.valueUnit = 'dB';

ffs=[20,10,5,1,0.1,0.07,0.04,0.01,0.001];
fms=[0.0008,0.0008,0.0009,0.002,0.01,0.02,0.44,1.4,50];
fns=[0.000022,0.000022,0.000028,0.0001,0.001,0.0017,0.003,0.017,0.2];

hold on;
plot( frObj );
set(gca, 'XScale', 'log'); set(gca, 'YScale', 'log'); 
hold off;

hold on;
plot( ffs, fms, 'Color', [0.6, 0, 0] );
hold off;

hold on;
plot( ffs, fns, 'Color', [0, 0.6, 0] );
hold off;

figure;
plObj = inObj;
%plObj.samples = inObj.samples(1:fftlen)

%plObj.samples = inObj.samples
%outObj = plObj;

plot( removeDC(plObj * (40/(2^24)) -20) );
%plot( removeDC(plObj * (40/(2^24)) -20), 'Color', [0 0.618 0] );
hold on;
isamps = abs( ifft( fftBins ) );
%isamps = abs( ifft( fftBins ) ) ./ blak;
plObj.samples = isamps;
plObj
plot( removeDC(plObj) );

outObj = plObj;

hold off;

%impulseNegFreqs = conj(impulseFreq(length(impulseFreq):-1:1));
%impulseNegFreqs = impulseFreq(length(impulseFreq):-1:1);

%lenNeg = length(impulseNegFreqs)
%impulseNegFreqs(1)
%impulseNegFreqs(end)
%impulseFreq(end)
%impulseFreq(1)
%lenPos = length(impulseFreq)

return;

freqSignal = [ impulseNegFreqs(1:len-1), impulseFreq(2:len) ]';


length(freqSignal)

if( length(freqSignal) ~= fftlen )
    error('Size mismatch');
end

%figure; plot( freqSignal );
%figure; plot( real(freqSignal) );
%figure; plot( imag(freqSignal) );
%figure; plot( abs(freqSignal) );
%figure; plot( real(freqSignal), imag(freqSignal) );

figure; plot( abs(ifft(freqSignal)) );
