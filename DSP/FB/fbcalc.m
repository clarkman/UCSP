function fbs = fbcalc( date, network, siteID, channel, type, varargin )
%
% Version: $Id: fbcalc.m,v 0590fd253a12 2010/06/17 17:25:54 qcvs $
%
% Variables:
% 	date	- the date in a string format YYYY/MM/DD
%	network - cmn or bk
%	siteID	- site to perform calc
%	channel - channel number, integer
%	type	- 'bk', take 30 minutes of data and take fft.
%		  'qfdc', resample bk to 32 Hz and take fft of 30 minutes of data
% 
%   Optional Inputs:
%       smoothPulses - check DB table "data_products" -> "pulseCounter" for
%           pulses for given date, site, channel and remove pulses from
%           data.
%       noRawFBData - do not calculate unsmoothed FB data
%
% Description
%	Calculates filter bank power levels for BK and CMN sensor data.  Half
%	hour data is averaged every fifteen minutes.  96 averages are calculated
%	per band where the last band uses 15 minutes from the next day.  If CMN
%	data starts after midnight, the previous day data is loaded to build a 
%	complete 24 hour segment.  Data is
%	divided up into frequency bands based on UC-Berkeley published values as
%	reflected in getUCBMAFreqs.m.
%
%	A single, non overlapping PSD is taken per 30 minute data segment.  A 
%	Hanning window is applied to time series data.  Using the "type" argument,
%	one can select whether the 40 Hz BK data is resampled to 32 Hz.
%
%	If a non zero outpute file name is supplied, the data is written to the
%	specified file using writeColumnFile.
%	
%	- -1 inserted when data is none existent.
%
% Assumptions:
%	- BK files start at 08:00 UTC.
% 
% EDITED - 09 March 2010 - SLP
%   - check for consecutive data is wrong - sign error!
%   - need to correct for FB pulses
%   - cleaned up code so to follow easier
% 

funcname = 'fbcalc.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

% =========================================================================
% =========================================================================
% Constants
NOB	   = 13;	% Number of bands
TIMEDIFF   = 2;
CMN_SR     = 32;
VALID_FILE = true;

%Test to see if 700 series site
blarg=num2str(siteID);
if blarg(1)=='7'; CMN_SR=50; end

% Environmental Variables
% Check for environment variables that are needed.
[status, BKPATH] = system( 'echo -n $RDSEED_DC_OUTPUT_TXT' );
if( isempty( BKPATH ) )
    display( 'env must contain RDSEED_DC_OUTPUT_TXT variable' );
    display( 'ENVIRONMENT' );
    fbs = [ ];
    return
end
% Check for environment variables that are needed.
[status, TMP] = system( 'echo -n $BKGET_TMP' );
if( isempty( TMP ) )
    display( 'env must contain BKGET_TMP variable' );
    display( 'ENVIRONMENT' );
    fbs = [ ];
    return
end

% Process arguments
MINARGS = 5;
optargs = size(varargin,2);
stdargs = nargin - optargs;
if( stdargs < MINARGS )
    fbs = [ ];
    display(sprintf('Not enough input arguments: min - %d used - %d',MINARGS,stdargs))
    display('USAGE')
    return
end
display(sprintf('\nINPUT ARGUMENTS:'))

% Date
% Build datenum from the data string.
d = datenum( date, 'yyyy/mm/dd' );
dnum = d + 8/24;    % UTC
% [yr,mo,day,hr,minute,sec] = datevec( d );
[yr,mo,day] = datevec( d );
display( sprintf('Date: %s',date) )

% Network
network = upper(network);
display( sprintf('Network: %s',network) )

% Site
if( iscell(siteID) )
    SID = siteID{:};
else
    SID = siteID;
end

if( ischar(SID) )
    siteStr = sprintf('%s',SID);
else
    siteStr = sprintf('%d',SID);
end

% Get Station Name
% Old method - new function called getStationInfo in streams/CalMagNet!
%siteCell = getStationInfoSLP({network},1,1,'SID',siteID,'NAME');
%siteName = siteCell{1};


% New method - only works for CMN network!
% Returns structure with:
% sid, file_name, status, first_data_start, recent_data, latitude, longitude
% Use getStationName.m to get siteName
siteInfo = getStationInfo(siteStr);
siteFN = siteInfo.file_name;
siteName = getStationName(siteFN);

display(sprintf('Site: %s - %s',siteName,siteStr))


% Channel
display( sprintf('Channel: %d',channel) )

% Type
display( sprintf('Type: %s',type) )

% Optional Arguments
display(sprintf('\nOPTIONAL ARGUMENTS:'))
smoothPulses = false;
noRawFBData = false;

k = 1;
while( k <= optargs )
    if( strcmpi(varargin{k}, 'smoothPulses') )
        smoothPulses = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'noRawFBData') )
        noRawFBData = true;
        display(sprintf('%s option active',varargin{k}))
    else
        display(sprintf('Optional argument %s cannot be interpreted. Argument is ignored.', varargin{k}))
    end
    
    k = k + 1;
end
display(' ')

% =========================================================================
% =========================================================================
display(' ')
display('FUNCTION BODY:')

% Intialize return variable in case we need to return earlier than expected.
fbs = ones( NOB+1+1, 96 ) * (-1);
% Set the correct time for the first column, needed for plotting and sanity checks.
fbs(1,:) = (1:96)/96 + d;
% FB data for pulse corrected data
fbsSmooth = fbs;

% Load environment variables
[fbDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    return
end

% Out File
outDirRaw = fbDir;
success = verifyEnvironment(outDirRaw);
outDirRaw = sprintf('%s/%s',outDirRaw,siteFN);
success = success && verifyEnvironment(outDirRaw);
outDirRaw = sprintf('%s/CHANNEL%d',outDirRaw,channel);
success = success && verifyEnvironment(outDirRaw);
outFileRaw = sprintf('%s/%d%02d%02d.%s.%s.%02d.fb',outDirRaw,yr,mo,day,network,siteStr,channel);
display( sprintf('Out File Raw: %s',outFileRaw) )

outDirSmooth = sprintf('%s/smoothedData',fbDir);
success = success && verifyEnvironment(outDirSmooth);
outDirSmooth = sprintf('%s/%s',outDirSmooth,siteFN);
success = success && verifyEnvironment(outDirSmooth);
outDirSmooth = sprintf('%s/CHANNEL%d',outDirSmooth,channel);
success = success && verifyEnvironment(outDirSmooth);
outFileSmooth = sprintf('%s/%d%02d%02d.%s.%s.%02d.fb',outDirSmooth,yr,mo,day,network,siteStr,channel);
display( sprintf('Out File Smooth: %s',outFileSmooth) )

% Environment Check
if( ~success )
    display('Environment Error - directories do not exist and cannot be created')
    display('ENVIRONMENT')
    return
end

% Load in data based on network
if( strcmpi( network, 'CMN' ) )
	sr = CMN_SR;
	fftl = sr * 60 * 30; % samples/sec * sec/min * min/half hr = samples/half hr
	
    % Load in current day.  There are two options
	% 	1) The data starts prior to midnight, ie the day before, or
	% 	2) The data starts after midnight.
	% 	3) The data starts on midnight.  Does this ever happen?
	% We want an entire 24 hour period, plus 15 minutes hanging off the end of 
	% of the day for the last FB calculation.

    % Load data for day
    try
        filename= sprintf('CHANNEL%d/%d%02d%02d.%s.%s.%02d.txt',channel,yr,mo,day,network,siteStr,channel);
        disp(sprintf('Input Filename: %s',filename))
        cmd = sprintf( 'o1=TimeData(''%s'',''%s'',''Means'');',filename,lower(network) );
        eval(cmd);
        diff = (o1.UTCref - 8/24) - d; %#ok<NODEF>
        display(sprintf('Time of first sample relative to midnight: %f',diff))

        % If 1), prior to midnight
        if ( diff < 0 )
            display('Object is before midnight')
            % Trim samples so that we start at midnight.
            nots = floor( abs(diff) * 24*60*60*o1.sampleRate );
            disp(sprintf('Trimming number of samples from object: %d',nots));
            % tmp = slice( o1, nots, o1.sampleCount );
            % o1  = tmp;
            o1s = o1.samples;
            o1.samples = o1s(nots+1:end,1);
            dt = o1.UTCref + nots/o1.sampleRate/(24*60*60);
            o1.UTCref = dt;

        % else 2), after midnight, load previos day and prepend.
        elseif ( diff > 0 )
            display('Object is after midnight')

            % Calculate number of samples needed to add from previous day
            noas = floor( abs(diff) * 24*60*60*o1.sampleRate );
            disp(sprintf('Adding number of samples to object from previous day: %d',noas))

            % Calc previous day
            d0 = d - 1;
            [yr,mo,day] = datevec( d0 );

            % Load previous day.
            try
                filename= sprintf('CHANNEL%d/%d%02d%02d.%s.%s.%02d.txt',channel,yr,mo,day,network,siteStr,channel);
                disp(sprintf('Previous Day Input Filename: %s',filename))
                cmd = sprintf( 'o0=TimeData(''%s'',''%s'',''Means'');',filename,lower(network) );
                eval(cmd);

                % Check end time to make sure that we have consecutive blocks of data.
                % Calculate end time of day.
                et0 = o0.UTCref + o0.sampleCount/o0.sampleRate/(24*60*60);
                sampDelta = 24*60*60*(o1.UTCref - et0);
                disp(sprintf('Time Difference between first sample of current day and last sample of previous day: %f sec',sampDelta))
                disp(sprintf('Sampling Rate for Current Day: %f Hz', o1.sampleRate))
                if( sampDelta > TIMEDIFF/o1.sampleRate )
                    display('Missing a block')
                    % Some data is missing.  So let's just add mean values from o1 for filler.
                    noms = floor(sampDelta*o1.sampleRate - 1);
                    s = median(o1.samples) * ones(noms,1);
                    % Remaining samples
                    nors = noas - noms;
                    o0s = o0.samples;
                    r = o0s( (o0.sampleCount-nors+1):o0.sampleCount,1 );
                    o1s = o1.samples;
                    o1.samples = [r;s;o1s];
                    t = o1.UTCref - noas/o1.sampleRate/(24*60*60);
                    o1.UTCref = t;
                elseif( sampDelta <= 0 )
                    display('Overlapping data')
                    % Do not add data that is overlapping
                    noos = floor(-sampDelta*o1.sampleRate + 1);
                    o0s = o0.samples;
                    s = o0s( (o0.sampleCount-noos-noas+1):(o0.sampleCount-noos),1 );
                    o1s = o1.samples;
                    o1.samples = [s;o1s];
                    t = o1.UTCref - noas/o1.sampleRate/(24*60*60);
                    o1.UTCref = t;
                else
                    display('Concurrent data');
                    % tmp = slice( o0, o0.sampleCount - noas+1, o0.sampleCount );
                    % s = tmp.samples;
                    o0s = o0.samples;
                    s = o0s( (o0.sampleCount-noas+1):o0.sampleCount,1 );
                    o1s = o1.samples;
                    o1.samples = [s;o1s];
                    t = o1.UTCref - noas/o1.sampleRate/(24*60*60);
                    o1.UTCref = t;
                end
            catch
                display('Previous day not found, loading in mean values');
                s = median(o1.samples)*ones(noas,1);
                o1s = o1.samples;
                o1.samples = [s;o1s];
                t = o1.UTCref - noas/o1.sampleRate/(24*60*60);
                o1.UTCref = t;
            end

        % If 3) we're good to go and don't need to do anything.
        else
            display('Object is dead on midnight')
            display('No data adjustment needed')
        end

        % Ok, we took care of the front end.  Now we have to do the back end.  What a pain!
        % Now we need to load in the next 15 minutes of data from the next day to use in the
        % last FB index.
        %	1) Load in the next day.  If it does not exist, punt and move on.
        %	2) Check that end time of our current day is close to the start time of the
        %	   next day.  Punt if it is not.
        %	3) Append enough data to give us 15 minutes.

        % Increment date to get the next day.
        d2 = d + 1;
        [yr,mo,day] = datevec( d2 );

        % Read in the next day
        try
            filename= sprintf('CHANNEL%d/%d%02d%02d.%s.%s.%02d.txt',channel,yr,mo,day,network,siteStr,channel);
            disp(sprintf('Next Day Input Filename: %s',filename))
            cmd = sprintf( 'o2=TimeData(''%s'',''%s'',''Means'');',filename,lower(network) );
            eval(cmd);

            % Number of samples to add
            noas = floor(o2.sampleRate*15*60);
            display(sprintf('Number of samples to append to data: %d',noas))

            et1 = o1.UTCref + o1.sampleCount/o1.sampleRate/(24*60*60);
            sampDelta = 24*60*60*(o2.UTCref - et1);
            disp(sprintf('Time Difference between first sample of next day and last sample of current day: %f sec',sampDelta))
            disp(sprintf('Sampling Rate for Next Day: %f Hz', o2.sampleRate))
            if( sampDelta > TIMEDIFF/o2.sampleRate )
                display('Missing a block')
                % Some data is missing.  So let's just add mean values from o1 for filler.
                noms = floor(sampDelta*o2.sampleRate - 1);
                s = median(o1.samples) * ones(noms,1);
                % Remaining samples
                nors = noas - noms;
                o2s = o2.samples;
                r = o2s( 1:nors,1 );
                o1s = o1.samples;
                o1.samples = [o1s;s;r];
            elseif( sampDelta <= 0 )
                display('Overlapping data')
                % Do not add data that is overlapping
                noos = floor(-sampDelta*o2.sampleRate + 1);
                o2s = o2.samples;
                s = o2s( (1+noos):(noos+noas),1 );
                o1s = o1.samples;
                o1.samples = [o1s;s];
            else
                display('Concurrent data');
                % tmp = slice( o0, o0.sampleCount - noas+1, o0.sampleCount );
                % s = tmp.samples;
                o2s = o2.samples;
                s = o2s( 1:noas,1 );
                o1s = o1.samples;
                o1.samples = [o1s;s];
            end
        catch
            disp('Following day does not exist.');
            disp('Appending median data')
            noas = floor(o1.sampleRate*15*60);
            disp(sprintf('Number of samples to add: %d',noas))
            s = median(o1.samples) * ones(noas,1);
            o1s = o1.samples;
            o1.samples = [o1s;s];
        end
    catch
        display(sprintf('File not found for Date: %s, Site: %s, Channel: %d',date,siteStr,channel))
        VALID_FILE = false;
    end

	%
	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EDIT TO WORK WITH BK NETWORK!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif( strcmpi( network, 'BK' ) )

	% BK constants
	sr = 40;

	% Load current day's data.
	try
		filename= sprintf('BK_%s_BT%d_%d_%02d_%02d.txt', site, channel, yr, mo, day );
		fullname= sprintf('%s/%s/BT%d/%s.gz', BKPATH, site, channel, filename );
		system( [ 'cp ', fullname, ' ', TMP ] );
		system( [ 'gzip -fd  ', TMP, filename, '.gz' ] );
		str = ['o1=TimeData(''',TMP, filename,''',''bk'');'];
		eval(str);
		system( [ 'rm -f ', TMP, filename ] );
	catch
		display('File not found')
		VALID_FILE = false;
	end

	% If we have less than a full day, stop, and we'll use what we have.
	% If we have more than a full day, we'll trim to a day, load the next day
	% and get the extra 15 minutes of data needed for the final FB index.
	nos = 24*60*60*sr;

	if ( o1.sampleCount > nos ) %#ok<NODEF>
		
		% Trim the data to midnight because we get more than a day's worth of data.
		tmp = slice( o1, 1, nos );
		o1  = tmp;

		% Increment date to get the next day.
		d = d + 1;
		[yr,mo,day] = datevec( d );

		% Read in the next day
		try
			filename= sprintf('BK_%s_BT%d_%d_%02d_%02d.txt', site, channel, yr, mo, day );
			fullname= sprintf('%s/%s/BT%d/%s.gz', BKPATH, site, channel, filename );
			system( [ 'cp ', fullname, ' ', TMP ] );
			system( [ 'gzip -fd  ', TMP, filename, '.gz' ] );
			str = ['o2=TimeData(''',TMP, filename,''',''bk'');'];
			eval(str);
			system( [ 'rm -f ', TMP, filename ] );

			% Check length of following day.  If less than 15 minutes of data, forget it.
			% If greater than 30 minutes, append the data and trim it to 1 day + 30 minutes.
			if ( o2.sampleCount > 15*60*sr )
				tmp = cat( o1, o2 ); 				% Concat the files.
				o1 = slice( tmp, 1, 24*60*60*sr + 15*60*sr );	% Trim the data to 24.25 hours
			end
		catch
			disp('Following day doesnt exist');
		end
	end

	% Resample BK data from 40 Hz to 32 Hz.
	if ( strcmp( type,  'qfdc' ) == 1 )
		sr = CMN_SR;
		t = o1.samples;
		t2 = resample(t, 4, 5);
		o1.samples = t2;
	end

	fftl = sr * 60 * 30; % samples/sec * sec/min * min/half hr = samples/half hr
end

if( VALID_FILE )
    % SMOOTH PULSES HERE!!!
    if( smoothPulses )
        o1smooth = o1;
        sD = o1smooth.UTCref;
        eD = dnum + 1 + 15/(60*24); % next day plus 15 mins
        smoothSamps = o1smooth.samples;
        
        % get pulses
        try
            pulses = getPulses('startTime',datestr(sD,'yyyy/mm/dd HH:MM:SS'),'endTime',datestr(eD,'yyyy/mm/dd HH:MM:SS'), ...
                'network',network,'station',siteStr,'channel',channel);
            display(sprintf('Pulses retrieved for day %s',date))
        catch
            pulses = [ ];
            display(sprintf('No pulses found for day %s',date))
        end
        
        for iPulse = 1:size(pulses,1)
            % Pulse start and end time
            pST = pulses(iPulse,5);
            pET = pulses(iPulse,6);
            % Pulse time in seconds from midnight
            pSTsec = 86400 * (pST - dnum);
            pETsec = 86400 * (pET - dnum);
            % First sample time in seconds from midnight
            s1sec = 86400 * (o1smooth.UTCref - dnum);
            % Indices of samples bounding pulse
            pSI = floor(o1smooth.sampleRate*(pSTsec - s1sec)) + 1;
            pEI = ceil(o1smooth.sampleRate*(pETsec - s1sec)) + 1;
            disp(sprintf('Smoothing pulse %d of %d - Sample Indices %d through %d',iPulse,size(pulses,1),pSI,pEI))

            % Get data points for times before and after pulse
            if( pSI <= 1 )
                try
                    % Calc previous day
                    d0 = dnum - 1;
                    [yr,mo,day] = datevec( d0 );

                    % Load previous day.
                    filename= sprintf('CHANNEL%d/%d%02d%02d.%s.%s.%02d.txt',channel,yr,mo,day,network,siteStr,channel);
                    disp(sprintf('Previous Day Input Filename: %s',filename))
                    cmd = sprintf( 'o0=TimeData(''%s'',''%s'',''Means'');',filename,lower(network) );
                    eval(cmd);
                    tempSamps = o0.samples;
                    s0sec = 86400 * (o0.UTCref - d0);
                    pSI0 = floor(o0.sampleRate*(pSTsec + 86400 - s0sec)) + 1;
                    aData = tempSamps(pSI0-1,1);
                catch
                    display('Previous day not found, using median value');
                    aData = median(smoothSamps);
                end
            else
                aData = smoothSamps(pSI-1,1);
            end

            if( pEI >= o1smooth.sampleCount )
                try
                    % Calc previous day
                    d2 = dnum + 1;
                    [yr,mo,day] = datevec( d2 );

                    % Load previous day.
                    filename= sprintf('CHANNEL%d/%d%02d%02d.%s.%s.%02d.txt',channel,yr,mo,day,network,siteStr,channel);
                    disp(sprintf('Previous Day Input Filename: %s',filename))
                    cmd = sprintf( 'o2=TimeData(''%s'',''%s'',''Means'');',filename,lower(network) );
                    eval(cmd);
                    tempSamps = o2.samples;
                    s2sec = 86400 * (o2.UTCref - d2);
                    pEI2 = ceil(o2.sampleRate*(pETsec - 86400 - s2sec)) + 1;
                    bData = tempSamps(pEI2+1,1);
                catch
                    display('Previous day not found, using median value');
                    bData = median(smoothSamps);
                end
            else
                bData = smoothSamps(pEI+1,1);
            end

            % Smooth data
            if( isnan(aData) ), ai = NaN; else ai = aData; end % if( ai <= 0 ), ai = NaN; end,
            if( isnan(bData) ), bi = NaN; else bi = bData; end % if( bi <= 0 ), bi = NaN; end, 
            for idata = pSI:pEI
                if( (idata <= 0) || (idata > o1smooth.sampleCount) )
                elseif( isnan(ai) && isnan(bi) )
                    smoothSamps(idata,1) = 0;
                elseif( isnan(ai) )
                    smoothSamps(idata,1) = bi;
                elseif( isnan(bi) )
                    smoothSamps(idata,1) = ai;
                else
                    dInd = (pEI+1) - (pSI-1);
                    aWeight = (pEI+1) - idata;
                    bWeight = idata - (pSI-1);
                    smoothSamps(idata,1) = aWeight/dInd * ai + bWeight/dInd * bi;
                end
            end
        end % for iPulse
        
        o1smooth.samples = smoothSamps;
    end % if( smoothPulses )
    
    % Weighting for Hann window - 30 min window
    window = hanning(fftl);

    % Calculate number of chunks (noc) to calculate per band.
    % tNoc = o1.sampleCount / (30*60*sr); % number of windows
    tNoc = o1.sampleCount / (30*60*sr); % number of windows = (samples/day) / (samples/30min) = (# 30 min chunks/day)
    tNocf = floor( tNoc );
    diff = tNoc - tNocf;
    if( diff >= 0.5)
        noc = tNocf * 2;
        display(sprintf('option 1: NOC = 2*tNOCf = %d', noc))
    else
        noc = tNocf * 2 - 1;
        display(sprintf('option 2: NOC = 2*tNOCf - 1 = %d', noc))
    end

    % Sanity check, noc should be an integer.
    if( (noc - floor(noc)) ~= 0 )
        display( 'Number of chunks is not an integer' );
        display( 'FAILURE' );
        return
    end



    % Go through the chunks and calculate
    display( sprintf('Number of chunks: %d',noc ) )

    % Loop through each chunk
    for li = 1:noc
        %for li = 1:1
        ss = 1 + (li-1)*fftl/2;		% Starting sample of chunk, li = 1 + (Chunk Number - 1) * (Window Length) / 2
        es = ss + fftl - 1; 		% Ending sample of chunk, li = Starting Sample + Window Length - 1
        display( sprintf('Chunk: %d of %d, Samples: %d - %d', li, noc, ss, es) )

        if( ~noRawFBData )
            % Calculate PSD, convert to pT^2/Hz
            try
                p = psd2( o1, fftl, ss, window, 0) * 1e12 * 1e12; % psd2 returns in units T^2/Hz
            catch
                display('Failed to calculate PSD')
                display('FAILURE')
                return
            end
            %figure,loglog(p)

            % Loop through FB bands, sum, and average
            for lj = 1:NOB

                % Load in frequency band ranges
                [f1, f2] = getUCBMAFreqs( lj );
                fr	 = sr / fftl;

                %  Find corresponding FFT bins.
                lb = floor( f1 / fr )+1;
                ub = floor(  f2 / fr );

                % Sum power in band and find average;
                val = sum( p(lb:ub) ) / ( ub - lb + 1 );

                fbs( lj+1, li ) = val;

                % SLP
                if( lj == 1 )
                    LB = lb;
                end
                if( lj == NOB )
                    UB = ub;
                end

                %display( ['Band information: ', sprintf('%d %d %d %e', lj, lb, ub, val) ] );

            end

            % Band NOB+1 - SLP
            val = sum( p(LB:UB) ) / ( UB - LB + 1 );
            fbs( NOB+1+1, li ) = val;
        end
        
        % Get smoothed FB data
        if( smoothPulses )
            % Calculate PSD, convert to pT^2/Hz
            try
                p = psd2( o1smooth, fftl, ss, window, 0) * 1e12 * 1e12; % psd2 returns in units T^2/Hz
            catch
                display('Failed to calculate smoothed PSD')
                display('FAILURE')
                return
            end
            %figure,loglog(p)

            % Loop through FB bands, sum, and average
            for lj = 1:NOB

                % Load in frequency band ranges
                [f1, f2] = getUCBMAFreqs( lj );
                fr	 = sr / fftl;

                %  Find corresponding FFT bins.
                lb = floor( f1 / fr )+1;
                ub = floor(  f2 / fr );

                % Sum power in band and find average;
                val = sum( p(lb:ub) ) / ( ub - lb + 1 );

                fbsSmooth( lj+1, li ) = val;

                % SLP
                if( lj == 1 )
                    LB = lb;
                end
                if( lj == NOB )
                    UB = ub;
                end

                %display( ['Band information: ', sprintf('%d %d %d %e', lj, lb, ub, val) ] );

            end

            % Band NOB+1 - SLP
            val = sum( p(LB:UB) ) / ( UB - LB + 1 );
            fbsSmooth( NOB+1+1, li ) = val;
        end % if( smoothPulses )

        % Write time stamp
        %fbs( 1, li ) = d + (1/noc)*(li+0);
        % This is now done at top during init of fbs.
    end
end % if VALID_FILE,

% Write output file
if( ~noRawFBData )
    success = writeColumnFile( outFileRaw, fbs', ...
        {'time', 'ma1', 'ma2', 'ma3', ...
        'ma4', 'ma5', 'ma6', 'ma7', ...
        'ma8', 'ma9', 'ma10', 'ma11', ...
        'ma12', 'ma13', 'all'}, '%f' );
    if ( success == 0 )
        display('Error writing FB file')
        display('BAD_WRITE')
        return
    end
end

% Write Smooth File
if( smoothPulses )
    success = writeColumnFile( outFileSmooth, fbsSmooth', ...
        {'time', 'ma1', 'ma2', 'ma3', ...
        'ma4', 'ma5', 'ma6', 'ma7', ...
        'ma8', 'ma9', 'ma10', 'ma11', ...
        'ma12', 'ma13', 'all'}, '%f' );
    if ( success == 0 )
        display('Error writing FB file')
        display('BAD_WRITE')
        return
    end
end % if( smoothPulses )

fend = now;
delta = (fend - fstart)*86400;
display(sprintf('%s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))
display('SUCCESS')
return
