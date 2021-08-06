function move = genCMNDailySpectrograms( inFile, outFile, interactive )
%
% Produce a daily spectrograms for CMN each day.  Makes
% two plots, 2Hz, and a 0.25Hz spectrograms
%
% Dependencies are a hack here.  If an 'X' file has a 
% missing piece or a failed decompression, use the following
% rule.  If CHANNELS 1, 2, 3 are present proceed.  Else, punt.
% Adjust for the presence of the channel four and five files
%
% So for make system, use CHANNEL1 to JPG dependency.
% Also, to safeguard against accidental usage, the inFile must
% take ONE form, an absolute path.

% genCMNDailySpectrograms('/mnt/CalMagNet/cmnProducts/dataCenterOutput/txt/CMN602_Honeydew602/CHANNEL1/20060325.CMN.602.01.txt','/mnt/CalMagNet/cmnProducts/dataCenterOutput/dailyPlots/CMN602_Honeydew602/20060325.CMN.602.01.txt');
% genCMNDailySpectrograms('/mnt/CalMagNet/cmnProducts/dataCenterOutput/txt/CMN605_Julianw605/CHANNEL1/20060615.CMN.605.01.txt','/mnt/CalMagNet/cmnProducts/dataCenterOutput/dailyPlots/CMN605_Julian605/20060615.CMN.602.01.txt');

% Turn off a pesky matlab display message that slows things down.
warning('off', 'MATLAB:concatenation:integerInteraction');


axesName{1}='North-South (Hz)';
axesName{2}='East-West (Hz)';
axesName{3}='Vertical (Hz)';


useEllipticalDecimation = 1;
ELFoverlapFactor = 8;
ELFoverlapFraction = 1.0 - 1.0/ELFoverlapFactor;
ELFFFTLength = 1024;
ULFoverlapFactor = 16;
ULFoverlapFraction = 1.0 - 1.0/ULFoverlapFactor;
ULFFFTLength = 1024/4;

decFactor1 = 8;
decFactor2 = 8;

figLeft = 0.05;
figBottom = 0.075;
figWidth = 1.0-2*figLeft;
figSpacing = 0.025;
figHeight = (1.0 - 2 * figSpacing - 2 * figBottom) / 3;


if nargin <= 2
    interactive = 0;
end

% If day is short, line up anyways
padPlots = 1;

compensate = 1;  % 0 for development make sense as it is speedier

try % Fetch Colormaps for spectrograms
    [status, procDir] = system( 'echo -n $CMN_INPUT_ROOT' );
    if( length( procDir ) == 0 )
	display( 'env must contain CMN_INPUT_ROOT variable' );
	error( 'found in CalMagNet/qfpaths.bash' );
    end
    colorMapFilename = [ procDir '/spectrogramColorMaps/' 'initialSetElfUlf.mat' ];
    hz0_25colorMapArray = load( colorMapFilename, 'hz0_25colorMap' );
    hz0_25colorMapArray=hz0_25colorMapArray.hz0_25colorMap;
    hz2colorMapArray = load( colorMapFilename, 'hz2colorMap' );
    hz2colorMapArray=hz2colorMapArray.hz2colorMap;
catch
    display( 'Spectrogram Colormap load failed!!!' );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end


% 1. Compute other channel names by dissecting supplied name
slashes = strfind( inFile, '/' );
if slashes(1) ~= 1
    display( 'Must use absolute path!' );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end 
numSlashes = length(slashes);
if numSlashes < 1
    display( 'Must have path for daily plot' );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end 

fileName = inFile(slashes(numSlashes)+1:end);
dots = strfind( fileName, '.' );
numDots = length(dots);
fileRoot = fileName(1:dots(numDots-1));

caxisMinScaler = 1.4;
caxisMaxScaler = 3.0;

useAbsoluteColorsFrom605 = 1;
colorRangerFull = [ -123.5563   47.7517 ];
colorRangerZoom = [ -173.6251   47.3571 ];


colorRangerZoomNS = [ -70   -10 ];
colorRangerZoomEW = [ -75   -10 ];
colorRangerZoomV = [ -173.6251/2   -20 ];


if 0 % Use absolute path
bFile{1} = [ inFile(slashes(1):slashes(numSlashes-1)), 'CHANNEL1/', fileRoot, '01.', 'txt' ];
bFile{2} = [ inFile(slashes(1):slashes(numSlashes-1)), 'CHANNEL2/', fileRoot, '02.', 'txt' ];
bFile{3} = [ inFile(slashes(1):slashes(numSlashes-1)), 'CHANNEL3/', fileRoot, '03.', 'txt' ];
else % Use relative path
bFile{1} = [ 'CHANNEL1/', fileRoot, '01.', 'txt' ];
bFile{2} = [ 'CHANNEL2/', fileRoot, '02.', 'txt' ];
bFile{3} = [ 'CHANNEL3/', fileRoot, '03.', 'txt' ];
end


stationName = inFile(slashes(numSlashes-2)+4:slashes(numSlashes-1)-4);
stationName(4) = ' ';
fileDate = fileRoot(1:end-9);

[stationNum, count] = sscanf( stationName(1:3), '%d' );

if( stationNum < 600 )
    compensate = 0;
    stationName = inFile(slashes(numSlashes-2)+4:slashes(numSlashes-1)-1);
    stationName(4) = ' ';
    useEllipticalDecimation = 0;
    dtee = 0;
else
    dtee = 1;
end

% 2. Compute output file name
slashes = strfind( outFile, '/' );
if slashes(1) ~= 1
    display( 'Must use absolute path!' );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end 
numSlashes = length(slashes);
if numSlashes < 1
    display( 'Must have path for daily plot' );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end 

fileName = outFile(slashes(numSlashes)+1:end);
dots = strfind( fileName, '.' );
numDots = length(dots);
fileRoot = fileName(1:dots(numDots-1));

if dtee
    elfDir = 'dailySgrams5Hz';
    ELFoutputFileName = [ outFile(slashes(1):slashes(numSlashes-2)), elfDir, outFile(slashes(numSlashes-1):slashes(numSlashes)), fileRoot, 'jpg' ]
    ulfDir = 'dailySgramsPt16Hz';
    ULFoutputFileName = [ outFile(slashes(1):slashes(numSlashes-2)), ulfDir, outFile(slashes(numSlashes-1):slashes(numSlashes)), fileRoot, 'jpg' ]
else
    elfDir = 'hz20.0';
    ELFoutputFileName = [ outFile(slashes(1):slashes(numSlashes-2)), elfDir, outFile(slashes(numSlashes-1):slashes(numSlashes)), fileRoot, 'jpg' ];
end


% 3. Load Data Objects for plotting
try
    for ith = 1 : 3 % Mandatory
        bObj{ith} = TimeData( bFile{ith}, 'cmn', 'Means' );
    end
catch
    display( 'Magnetometer daily plot load failed!!!' );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end

%plot( bObj{1} )

daFullRange =  2^24;
daHalfRange =  2^23;
daPlotRange =  2^18;
daBegTime = bObj{1}.UTCref;
daEndTime = daBegTime + ( length(bObj{1}) / bObj{1}.sampleRate ) / 86400;

mTick = round(daBegTime) + 1/3; % Nearest midnight
xTicks = [mTick+1/24, mTick+2/24, mTick+3/24, mTick+4/24, mTick+5/24, mTick+6/24, mTick+7/24, mTick+8/24, mTick+9/24, mTick+10/24, mTick+11/24, mTick+12/24, mTick+13/24, mTick+14/24, mTick+15/24, mTick+16/24, mTick+17/24, mTick+18/24, mTick+19/24, mTick+20/24, mTick+21/24, mTick+22/24, mTick+23/24,]; % Nearest midnight
xTickLabels = ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23']; % Nearest midnight
xLims = [mTick+1/4, mTick+1/2, mTick+3/4];


minStartTimeDiff = 1.0/86400;
%try

    % 4. Error Check Data Objects
    if bObj{1}.sampleRate ~= bObj{2}.sampleRate || bObj{2}.sampleRate ~= bObj{3}.sampleRate
	display('sample rate mismatch');
        exit;
    end
    if( abs(bObj{1}.UTCref - bObj{2}.UTCref) > minStartTimeDiff || abs(bObj{2}.UTCref - bObj{3}.UTCref) > minStartTimeDiff )
	display('start time mismatch');
        exit;
    end
    if length(bObj{1}) ~= length(bObj{2}) || length(bObj{2}) ~= length(bObj{3}) 
	display('sample count mismatch');
        exit;
    end
    if length(bObj{1}) < 1000000 
	display('sample count too small');
        exit;
    end

    if( padPlots )
    
        begT = bObj{1}.UTCref;
        endT = bObj{1}.UTCref + ( length(bObj{1}) / bObj{1}.sampleRate ) / 86400;
        
        if( (endT - begT) < 286.8/288 ) % Do something
           
           % Pad beginning separately from end, so both can be done.
            padSensor = 5.1/1440;
       
            nominalStart = floor( begT ) + 1/3; % Never earlier
            nominalFinish = ceil( begT ) + 1/3; % Never later
            
           % Do beginning first
            if( (begT - nominalStart) > padSensor ) % 5 minutes & pad
                numBegPadSamples = floor( (begT - nominalStart) * 86400 * bObj{1}.sampleRate );
                pad = ones( numBegPadSamples, 1 );
                pad = pad .* daHalfRange; % Scale to real value
                
                samps = bObj{1}.samples;                
                bObj{1}.samples = [ pad', samps' ]';
                samps = bObj{2}.samples;                
                bObj{2}.samples = [ pad', samps' ]';
                samps = bObj{3}.samples;                
                bObj{3}.samples = [ pad', samps' ]';
            end
            
           % Now do end
            %if( (nominalFinish + padSensor - endT) > padSensor ) % 5 minutes & pad
            if( (nominalFinish - endT) > 0 ) % 5 minutes & pad              
                numEndPadSamples = floor( (nominalFinish - endT) * 86400 * bObj{1}.sampleRate );
                pad = ones( numEndPadSamples, 1 );
                pad = pad .* daHalfRange; % Scale to real value
                
                samps = bObj{1}.samples;                
                bObj{1}.samples = [ samps', pad' ]';
                samps = bObj{2}.samples;                
                bObj{2}.samples = [ samps', pad' ]';
                samps = bObj{3}.samples;                
                bObj{3}.samples = [ samps', pad' ]';
            end
            
        end
            
    end

    % 5. Compensate response 
    for ith = 1 : 3
        bObj{ith} = removeDC( bObj{ith} );

	if compensate	
		display( [ 'Compensating series #' sprintf( '%d', ith ) ] );

		xferFunc=loadTransferFunction( bObj{ith}, 8192 )';
		display( 'Transfer Func loaded' );
		xferFunc = smoothedQF1005XferFunc( 8192 );
		display( 'Transfer Func smoothed' );
		compensatedSeries{ith}=impulseConv( bObj{ith}, xferFunc );
		display( 'Transfer Func convolved' );
		compensatedSeries{ith} = removeDC( compensatedSeries{ith} );
		display( 'compensated...' );
	else
	    compensatedSeries{ith} = bObj{ith} * (40.0/(2^24));  % Quicker for development
	end

    end 
    
    clear bObj;
    
%catch
if 0
    display( [ 'Transfer Function Compensation for: ', inFile, ' failed!!!' ] );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end



try

	figure;

	for ith = 1 : 3 % PLot 3 axes of ELF plot

		if dtee
		    if 1
			%compSeriesDecElf{ith} = decimateElliptical( compensatedSeries{ith}, decFactor1 );
			compSeriesDecElf{ith} = resample( compensatedSeries{ith}, 5, 16 ) * 1000;
		    else 
			compSeriesDecElf{ith} = decimate( compensatedSeries{ith}, decFactor1 );
		    end
		else
		    compSeriesDecElf{ith} = compensatedSeries{ith};
		end

		subplot( 3, 1, ith );
		spectData = log10( spectrogram( compSeriesDecElf{ith}, ELFFFTLength, ELFoverlapFraction ) );
		%spectData = log10( sqrt( spectrogram( compSeriesDecElf{ith}, ELFFFTLength, ELFoverlapFraction ) ) );
		spectSize = size(spectData.samples);
		tAxis=getTAxis(spectData);
		fAxis=getFAxis(spectData);

		imagesc( tAxis, fAxis, spectData.samples );
		axis xy;
		ylabel( axesName{ith} );
		set(gca,'XTick',xTicks);
		%set(gca,'XTickLabel', { '', '', '', '', '', '6AM', '', '', '', '', '', '12PM', '', '', '', '', '', '6PM', '', '', '', '', '' } );
		set(gca,'XTickLabel','');
		yLims = get( gca, 'YLim' );
		line( [xLims(1) xLims(1)], [yLims(1), yLims(2)], 'LineStyle', ':' ); 
		line( [xLims(2) xLims(2)], [yLims(1), yLims(2)], 'LineStyle', ':' ); 
		line( [xLims(3) xLims(3)], [yLims(1), yLims(2)], 'LineStyle', ':' );
			
		%colormap(hz2colorMapArray);
		%set(gca,'CLim', [-3 1])
		set(gca,'CLim', [-2 4])
		if interactive
			colorbar
			set(colorbar,'YTickLabel', {'0.01', '0.1', '1pT', '10', '100', '1nT', '10'} )
		end

		if( ith == 1 )
		    if dtee
			title( [ '0.0 - 5.0 Hz Spectrograms for: ', stationName, '/' fileDate ]);
		    else
			title( [ '20.0 Hz Spectrograms for: ', stationName, '/' fileDate ]);
		    end
		end

		if( ith == 3 )
		    xlabel( [ 'Units: Hours PST | ', sprintf( 'Frequency Resolution: %g Hz | ', spectData.freqResolution ), sprintf( 'Time Resolution: %g Secs | ', spectData.timeEnd/spectSize(2)), sprintf( 'Pixel Dims: %d Wide x %d High', spectSize(2), spectSize(1) ) ] );
		end
		2-(ith-1) * (figHeight + figSpacing)
		set(gca,'Position', [figLeft, figBottom + (2-(ith-1)) * (figHeight + figSpacing), figWidth, figHeight]);
	end
    
        if ~interactive
		orient portrait;
		print( gcf,'-djpeg80', '-noui', ELFoutputFileName );
		cmd = [ '!convert -resize 760x440! -quality 80 ' ELFoutputFileName ' ' ELFoutputFileName ];
		eval( cmd )
	end
	
catch
    display( [ 'ELF Range Spectrograms for: ', inFile, ' failed!!!' ] );

    if interactive
        return
    else
        display( 'FAILURE' );
        exit
    end
end



if( dtee )

    try

        figure;

	for ith = 1 : 3 % PLot 3 axes of ULF plot

		if 1
			%compSeriesDecUlf{ith} = decimateElliptical( compSeriesDecElf{ith}, decFactor2 );
			obbj = decimate( decimate( decimate( compensatedSeries{ith}, 4 ), 5 ), 4 ) * 1000;
			%obbj = decimateElliptical( decimateElliptical( decimateElliptical( compensatedSeries{ith}, 4 ), 5 ), 5 )
			compSeriesDecUlf{ith} = obbj;
		else 
			compSeriesDecUlf{ith} = decimate( decimate( decimate( compensatedSeries{ith}, 4 ), 5 ), 4 );
		end

		subplot( 3, 1, ith );
		spectData = log10( spectrogram( compSeriesDecUlf{ith}, ULFFFTLength, ULFoverlapFraction ) );
		%spectData = log10( sqrt( spectrogram( compSeriesDecUlf{ith}, ULFFFTLength, ULFoverlapFraction ) ) );
		spectSize = size(spectData.samples);
		tAxis=getTAxis(spectData);
		fAxis=getFAxis(spectData);

		imagesc( tAxis, fAxis, spectData.samples );
		axis xy;
		ylabel( axesName{ith} );
		set(gca,'XTick',xTicks);
		%set(gca,'XTickLabel', { '', '', '', '', '', '6AM', '', '', '', '', '', '12PM', '', '', '', '', '', '6PM', '', '', '', '', '' } );
		set(gca,'XTickLabel','');
		yLims = get( gca, 'YLim' );
		line( [xLims(1) xLims(1)], [yLims(1), yLims(2)], 'LineStyle', ':' ); 
		line( [xLims(2) xLims(2)], [yLims(1), yLims(2)], 'LineStyle', ':' ); 
		line( [xLims(3) xLims(3)], [yLims(1), yLims(2)], 'LineStyle', ':' ); 

		%colormap(hz0_25colorMapArray);
		set(gca,'CLim', [-2 5])
		if interactive
			colorbar
			set(colorbar,'YTickLabel', {'0.01', '0.1', '1pT', '10', '100', '1nT', '10', '100'} )
		end

		if( ith == 1 )
			title( [ '0.0 - 0.16 Hz Spectrograms for: ', stationName, '/' fileDate ]);
		end

		if( ith == 3 )
			xlabel( [ 'Units: Hours PST | ', sprintf( 'Frequency Resolution: %g Hz | ', spectData.freqResolution ), sprintf( 'Time Resolution: %g Secs | ', spectData.timeEnd/spectSize(2)), sprintf( 'Pixel Dims: %d Wide x %d High', spectSize(2), spectSize(1) ) ] );
		end

		set(gca,'YLim', [0 0.16]);
		set(gca,'Position', [figLeft, figBottom + (2-(ith-1)) * (figHeight + figSpacing), figWidth, figHeight]);

        end  

        if ~interactive
		orient portrait;
 		print( gcf,'-djpeg80', '-noui', ULFoutputFileName );
		cmd = [ '!convert -resize 760x440! -quality 80 ' ULFoutputFileName ' ' ULFoutputFileName ];
		eval( cmd );
	end

    catch

        display( [ 'ULF Range Spectrograms for: ', inFile, ' failed!!!' ] );
        if interactive
            return
        else
            display( 'FAILURE' );
            exit
        end
    end

end 
    

if interactive
    return
else
    close all;
    display( 'SUCCESS' );

    exit
end
