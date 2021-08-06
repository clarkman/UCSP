function outObj = psd( obj, fftlen, compensate, overLap )
%
%
% Compute and return the psd.  Accepts usage codes
% that control transfer function compensation & computation
% Input time series is always detrended by fitting a line.
%
% If nargin == 1 or 2, then time series is truncated to fftlen
% samples, and no compensation is applied.
% 
% If nargin == 3, then the following monikers control the action:
%
% 'fComp' = Truncate to fftlen, compensate for xfer function (TF) in freq domain. 
% 'tComp' = Compensate for TF using time domain convolution, then truncate to 
%           fftlen.  Time series must be at least 2x fftlen long.
% 'Volts' = Convert to volts, do not compensate, truncate to fftlen.
% 'Welch' = Do not truncate or compensate. Use Welch's method (Matlab function)
%
% Also accepted are the following combinations:
% 
% 'fComp|Welch' = Do not truncate. Compute energy using Welch overlaps, compensate 
%                 for xfer function (TF) in freq domain. 
% 'tComp|Welch' = Do not truncate. Compensate for TF using time domain convolution,
%                 then compute energy using Welch overlaps. 
% 'Volts|Welch' = Do not truncate. Convert to volts, then compute energy using 
%                 Welch overlaps. 
%
% NOTES:
%
% 1) For all but frequency domain TF compensation, the energy lost to windowing is 
% is calculated by computing RMS before and after windowing.  The loss factor is 
% then used to produce an "energy conserving" result.
%
% 2) For frequency domain TF compensation, the energy lost to windowing is 
% is calculated by computing the area under window.  The window factor is 
% then used to produce an "energy conserving" result.
%
% 3) Uses Blackman windowing
%




% Step 1:  Compute important parameters ...
fs = obj.sampleRate;
freqRes = fs / fftlen;
wind = blackman(fftlen);
ws   = sum(wind.^2)/fftlen;

outUnits = obj.valueUnit;




% Step 2:  Arg Checks ...
objLength = length( obj );
if ( objLength == 0 )
    error( [' TimeData object for ', obj.DataCommon.source, ' has no samples!'] );
end
if ( objLength < fftlen )
    error( [' TimeData object for ', obj.DataCommon.source, ' is shorter than FFT length!'] );
end
if( nargin == 1 )
    fftlen = 1024;
    compensate = 0;
    warning( [ 'Default FFT length of ' sprintf( '%d', fftlen ) ' used!' ] );
end
if( nargin <= 2 )
    compensate = 0;
end
if( nargin <= 3 )
    overLap = 8;
end
if( mod(fftlen,2) )
    error( 'Odd number of points' );
end
if( overLap < 1 )
    error( 'Zero or negative overlapFactor' );
end




% Step 3: Load Transfer Function
if compensate
    if ( strcmp( 'BK', obj.DataCommon.network ) )
	xfer1 = xferFuncLoad( obj, fftlen, 0);		% Load transfer function
	tf1= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi);	% Convert TF to a usable format
	tf1=tf1(2:fftlen/2+1);                            % 0
	%tf1(1) = tf1(2)/100; % XXX Clark
    elseif ( strcmp( 'CMN', obj.DataCommon.network ) )

        if 1
            xfer1=loadTransferFunction( obj, fftlen )';
        else
            xfer1 = qf1005XferFunc( obj, fftlen, 0, fs/2 );
        end
	tf= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi);
	tf = tf * 2^24 / 40;
	tf = tf * 1e9;
	tf1 = tf(1:fftlen/2);
	%tf1(1) = tf1(2)/100; % XXX Clark
        plot(abs(tf1));
    else
	display('Error, wrong network');
    end
end




% Step 4:  Count data & slice
sliceOffset = floor( fftlen/overLap )
numSlices = floor( (objLength-fftlen) / sliceOffset ) + 1;

samps1 = obj.samples;

samps2 = detrend( samps1(1:fftlen), 'linear' ); % - Detrend data with a line.
samps3 = samps2 .* wind;
fftResult = fft( samps3, fftlen );               % - Take FFT of data.

if( numSlices > 1 ) % Only if more slices
    for ith = 1 : numSlices-1
        samps2 = detrend( samps1(ith*sliceOffset:ith*sliceOffset+fftlen-1), 'linear' ); % - Detrend data with a line.
        samps3 = samps2 .* wind;
        fftOut = fft( samps3, fftlen );         % - Take FFT of data.
        fftResult = fftResult + fftOut;
    end
    fftResult = fftResult ./ numSlices;
end


fb = fftResult(1:fftlen/2);                     % - Trim to take first half fo FFT, rest is a mirror.
fc = fb ./ tf1;                                 % - TF compensate.
fd = fc / fftlen;                               % - Normalize the FFT.

% Calc PSD
psd = 1 / freqRes / ws * abs(fd) .^ 2 * 2;      % - Square to get power, divide by bandwidth,
	                                        %   double it to get second half of FFT that
	                                        %   was thrown away.

% Check Parseval's equations
if 0
    p1 = sum( abs(d2).^2 ) / fftlen
    %p2 = sum( 2*(abs(fd.*tf1')).^2 )
    p2 = sum( psd * df .* abs(tf1').^2 )
end



% Step lucky number 7:  Create Frequency Data Object ...
outObj = FrequencyData( obj.DataCommon, psd, freqRes );
outObj.valueType = 'Spectral Density'
outObj.valueUnit = 'T/rootHz';


return

% Test plot

timeDataObj = segTime( ch1605_1008, 600, 15000 );
fftlength = 1024
freqRes=timeDataObj.sampleRate/fftlength;
xAxial=0:freqRes:(timeDataObj.sampleRate/2); xAxial = xAxial(1:end-1);
begSample = 2*9600
finSample = begSample + fftlength - 1;

hold on; plot(sqrt(psd(timeDataObj,fftlength,'fComp')),'Color', [0.6 0 0]); hold off;
hold on; plot(sqrt(psd(timeDataObj,fftlength,'Volts')),'Color',[0 0 0]); hold off;
%hold on; plot(sqrt(psd(slice(timeDataObj,begSample-fftlength/2+1,begSample+3/2*fftlength),fftlength,'tComp'))); hold off;
%hold on; plot(sqrt(psd(slice(timeDataObj,begSample,begSample+2*fftlength-1),fftlength,'tComp'))); hold off;
%hold on; plot(xAxial,sqrt(psd2(ch1605_1008,fftlength,begSample,finSample,blackman(fftlength),0,0))*1.0e9,'Color',[0 0.6 0]); hold off;
legend( 'Volts', 'fComp', 'tComp', 'psd2' )
set( gca, 'XLim', [0.01 20] )
set(gca,'XScale','log'); 
set(gca,'YScale','log'); 
set( gca, 'YLim', [1.0e-5 1] )
ylabel('Spectral Density, gammas/rootHz');

