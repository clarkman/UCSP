function outObj = psd( obj, fftlen, usageCode )
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
fComp = 0; tComp = 0; Volts = 0; Welch = 0; % fComp, tComp, & Volts are mutually exclusive
fs = obj.sampleRate;
freqRes = fs / fftlen;
wind = blackman(fftlen);
outUnits = obj.valueUnit;



% Step 2:  Arg checks ...
objLength = length( obj );
if( mod(fftlen,2) )
    error( 'Odd number of points' );
end
if ( objLength == 0 )
    error( [' TimeData object for ', obj.DataCommon.source, ' has no samples!'] );
end
if ( objLength < fftlen )
    error( [' TimeData object for ', obj.DataCommon.source, ' is shorter than FFT length!'] );
end
if( nargin == 1 )
    fftlen = objLength;
elseif( nargin == 2 ) 
    if( objLength > fftlen )
        daSamps = slice( obj, 1, fftlen );
    elseif( objLength == fftlen )
        daSamps = obj;
    else % time series less than fft length
        error( 'Data series too short' );
    end
else
    % Usage codes interpretation:
    if( ~isempty( strfind( usageCode, 'fComp' ) ) ), fComp = 1;, end;
    if( ~isempty( strfind( usageCode, 'tComp' ) ) ), tComp = 1;, end;
    if( ~isempty( strfind( usageCode, 'Volts' ) ) ), Volts = 1;, end;
    if( ~isempty( strfind( usageCode, 'Welch' ) ) ), Welch = 1;, end;
    % fComp, tComp, and Volts are mutually exclusive.
    if( (fComp && tComp) || (fComp && Volts) || (tComp && Volts) )
        error( 'Usage:  Can only choose one: fComp, tComp, or Volts' );
    end
    
    daSamps = obj;
end



% Step 3:  Detrend (removes DC) ...
%if( ~fComp )
%    daSamps.samples = detrend( daSamps.samples, 'linear' ); % - Detrend data with a line.
%end



% Step 4:  Compute time domain compensated series ...
if( tComp )
    if( length( daSamps ) < 2 * fftlen )
        error( 'Time series not long enough for convolution to be applied' );
    end
    if ( strcmp( 'BK', daSamps.DataCommon.network ) )
        xferFunc = xferFuncLoad( daSamps, fftlen, 0 ); % Loads in as Volts/Tesla
        xferFunc(:,1) = xferFunc(:,1) ./ 1e09; % Convert to Volts/Gamma
    else
        xferFunc = qf1005XferFunc( daSamps, fftlen, 0, floor(daSamps.sampleRate/2) );
    end
    daSamps=impulseConv( daSamps, xferFunc );
end



% Step 5: Or convert to voltage series ...
if( Volts )
    if( strcmp( daSamps.DataCommon.network, 'CMN' ) )
        % XXX Clark must apply gain in loader for this to work!!!
        switch( daSamps.DataCommon.channel )
            case {'CHANNEL1','CHANNEL2','CHANNEL3'}
                scale2Volts = 40.0/(2^24); % Differential
            case {'CHANNEL4','CHANNEL5'}
                scale2Volts = 20.0/(2^24); % Single-ended
            otherwise
                error( 'Channel scale not found' );
        end
    elseif( strcmp( daSamps.DataCommon.network, 'BK' ) )
        scale2Volts = 40.0/(2^24);
    else
        error('Only set up for CMN & BK so far!');
    end
    daSamps = daSamps .* scale2Volts;
    
    outUnits = 'Volts';
end



% Step 6: Compute PSD values ...
if( fComp )

    % Call Jamie/Jacob routine.  Does truncation & compensation
    absfftBins = psd2( obj,fftlen,1,fftlen,wind,0,0)
    absfftBins = absfftBins .* 1.0e18;  % Convert from T^2 to Gammas^2
    outUnits = 'Gammas';

elseif( ~Welch )

    % Truncate time series
    if( tComp )
        daSamps = slice( daSamps, fftlen/2+1, 3/2*fftlen );
    else
        daSamps = slice( daSamps, 1, fftlen );
    end

    % Compute exact energy loss due to windowing ...
    preWindowSum = sqrt( sum( daSamps.samples .* daSamps.samples ) );
    daSamps.samples = daSamps.samples .* wind;
    aftWindowSum = sqrt( sum( daSamps.samples .* daSamps.samples ) );
    lossRatio = aftWindowSum / preWindowSum;

    % Compute FFT, correct for windowing, and normalize ...
    fftBins = fft( daSamps.samples, fftlen );  % Produces a+bi complex numbers
    fftBins = fftBins ./ lossRatio; % Correct 
    fftBins = fftBins ./ fftlen; % Normalize FFT

    % psd = 1 / df / ws * abs(fd).^2 * 2;        % - Square to get power, divide by bandwidth,
    absfftBins = (( abs( fftBins * 2 ) ) .^ 2 ) / freqRes;

    if( tComp )
        outUnits = 'Gammas';
    end
else

    error( 'Welch nyet!!' );

end



% Step lucky number 7:  Create Frequency Data Object ...
outObj = FrequencyData( obj.DataCommon, absfftBins(1:(fftlen/2)), freqRes );
outObj.valueType = 'Spectral Density'
outObj.valueUnit = [ outUnits '^2/Hz' ];


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

