function [fbs] = fbcalc_raw( date, network, site, channel, type, bandType, outFileName )
%
% Version: $Id: fbcalc2.m,v 24b094f28d9f 2007/06/02 00:07:09 jwc $
%
% Variables:
% 	date	- the date in a string format YYYY/MM/DD
%	network - cmn or bk
%	site	- site to perform calc, a string
%	channel - channel number, integer
%	outFileName - If non '0', write output to the name file
%	type	- 'bk', take 30 minutes of data and take fft.
%		  'qfdc', resample bk to 32 Hz and take fft of 30 minutes of data
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

% Check for environment variables that are needed.
[status, BKPATH] = system( 'echo -n $RDSEED_DC_OUTPUT_TXT' );
if( length( BKPATH ) == 0 )
    	display( 'env must contain RDSEED_DC_OUTPUT_TXT variable' );
	return
end

% Check for environment variables that are needed.
[status, TMP] = system( 'echo -n $BKGET_TMP' );
if( length( TMP ) == 0 )
    	display( 'env must contain BKGET_TMP variable' );
	return
end

%NOB	= 13;	% Number of bands
switch( bandType )
	case {'UCB'},
		display('Calcing UCB bands.');
		[ NOB, t1 ] = getUCBMAFreqs( 0 );
	case {'upper'},
		display('Calcing upper bands.');
		[ NOB, t1 ] = getFBUpperFreqs( 0 );
end
TIMEDIFF= 2;
CMN_SR = 32;

% Build datenum from the data string.
d = datenum( date, 'yyyy/mm/dd' ); 	
[yr,mo,day,hr,minute,sec] = datevec( d );

% Load in data based on network
if ( strcmp( network, 'cmn' ) || strcmp( network, 'CMN' ) )
	display('cmn')
	sr = CMN_SR;
	fftl = sr * 30*60;
	% Load in current day.  There are two options
	% 	1) The data starts prior to midnight, ie the day before, or
	% 	2) The data starts after midnight.
	% 	3) The data starts on midnight.  Does this ever happen?
	% We want an entire 24 hour period, plus 15 minutes hanging off the end of 
	% of the day for the last FB calculation.

	% Load data for day
	try
	filename= sprintf('CHANNEL%d/%d%02d%02d.CMN.%s.%02d.txt',channel,yr,mo,day,site,channel);
	disp(filename);
	str = ['o1=TimeData(''',filename,''',''cmn'',''Means'');'];
	eval(str);
	diff = (o1.UTCref - 1/3) - d
	catch
		display('File not found')
		return
	end

	% If 1), prior to midnight
	if ( diff < 0 )
		display([ 'Object is before midnight: ' , site] );
		% Trim samples so that we start at midnight.
		nots = floor( abs(diff) * 24*60*60*o1.sampleRate )
		disp(sprintf('Trimming number of samples from object: %d',nots));
		tmp = slice( o1, nots, o1.sampleCount );
		o1  = tmp;

	% else 2), after midnight, load previos day and prepend.
	elseif ( diff > 0 )

		display('Object is after midnight');

		% Calculate number of samples needed to add from previous day
		noas = floor( abs(diff) * 24*60*60*o1.sampleRate )

		% Calc previous day
		d2 = d - 1; 
		[yr,mo,day,hr,minute,sec] = datevec( d2 );

		% Load previous day.
		try
		filename= sprintf('CHANNEL%d/%d%02d%02d.CMN.%s.%02d.txt',channel,yr,mo,day,site,channel);
		disp(filename);
		str = ['o0=TimeData(''',filename,''',''cmn'',''Means'');'];
		eval(str);

		% Check end time to make sure that we have consecutive blocks of data.
		% Calculate end time of day.
		eet = o0.UTCref + o0.sampleCount/o0.sampleRate/(24*60*60)	
		sprintf('%.10f',eet - o1.UTCref)
		if ( (eet - o1.UTCref) > TIMEDIFF/o1.sampleRate )
			display('Missing a block')
			% Can't use data before.  So let's just add mean values from o1 for filler.
			s = ones(noas,1)*mean(o1.samples);
			o1s = o1.samples;
			o1.samples = [s o1s];
		else
			display('Prepending data');
			tmp = slice( o0, o0.sampleCount - noas+1, o0.sampleCount );
			s = tmp.samples;
			o1s = o1.samples;
			tmps = [s' o1s']';
			o1.samples = tmps;
			t = o1.UTCref - (noas-1)/(24*3600*o1.sampleRate);
			o1.UTCref = t;
		end
		catch
			display('Previous day not found, loading in meadian values');
			s = ones(1,noas)*mean(o1.samples);
			o1s = o1.samples;
			tmps = [s o1s']';
			o1.samples = tmps;
			t = o1.UTCref - (noas)/(24*3600*o1.sampleRate);
			o1.UTCref = t;
		end

	% If 3) we're good to go and don't need to do anything.
	else
		display('Time is dead on midnght')
	end

	% Ok, we took care of the front end.  Now we have to do the back end.  What a pain!
	% Now we need to load in the next 15 minutes of data from the next day to use in the
	% last FB index.
	%	1) Load in the next day.  If it does not exist, punt and move on.
	%	2) Check that end time of our current day is close to the start time of the
	%	   next day.  Punt if it is not.
	%	3) Append enough data to give us 15 minutes.

	% Increment date to get the next day.
	d = d + 1;
	[yr,mo,day,hr,minute,sec] = datevec( d );

	% Read in the next day
	try
		filename= sprintf('CHANNEL%d/%d%02d%02d.CMN.%s.%02d.txt',channel,yr,mo,day,site,channel);
		disp(filename);
		str = ['o2=TimeData(''',filename,''',''cmn'',''Means'');'];
		eval(str);

		eet = o1.UTCref + o1.sampleCount/o1.sampleRate/(24*60*60)	
		if ( (eet - o2.UTCref) < TIMEDIFF/o2.sampleRate )
			display('Timing is good, continue')
			if ( o2.sampleCount > 15*60*sr )
				disp('Appending data')
				tmp = cat( o1, o2 ); 				% Concat the files.
				o1 = slice( tmp, 1, 24*60*60*sr + 15*60*sr );	% Trim the data to 24.25 hours
			end
		else
			disp('Time mismatch between consecutive days')
		end
	catch
		disp('Following day doesnt exist');
	end

	%
	%
elseif ( strcmp( network, 'bk' ) || strcmp( network, 'BK' ) )

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
		return
	end

	% If we have less than a full day, stop, and we'll use what we have.
	% If we have more than a full day, we'll trim to a day, load the next day
	% and get the extra 15 minutes of data needed for the final FB index.
	nos = 24*60*60*sr;

	if ( o1.sampleCount > nos )
		
		% Trim the data to midnight because we get more than a day's worth of data.
		tmp = slice( o1, 1, nos );
		o1  = tmp;

		% Increment date to get the next day.
		d = d + 1;
		[yr,mo,day,hr,minute,sec] = datevec( d );

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

	fftl	= sr * 30 * 60;
end

% Intialize return variable in case we need to return earlier than expected.
fbs = ones( NOB+1, 96 ) * (-1);
% Set the correct time for the first column, needed for plotting and sanity checks.
fbs(1,:) = (1:96)/96 + d;


window = hanning(fftl);

% Calculate number of chunks (noc) to calculate per band.
tNoc = o1.sampleCount / (30*60*sr);
tNocf = floor( tNoc );
diff = tNoc - tNocf;
if ( diff >= 0.5)
	display('option 1')
	noc = tNocf * 2;
else
	display('option 2')
	noc = tNocf * 2 - 1;
end

% Sanity check, noc should be an integer.
if ( (noc - floor(noc)) ~= 0 )
	error( 'Number of chunks should be an integer' );
end



% Go through the chunks and calculate
display( ['Number of chunks: ', sprintf('%d',noc) ] );

for li = 1:noc
%for li = 1:1
	ss = 1 + (li-1)*fftl/2;		% Starting sample of chunk, li.
	es = ss + fftl-1; 		% Ending sample of chunk, li.
	display( ['Chunk: ', sprintf('%d of %d %d,  %d %d', li, noc, ss, es) ] );

	% Calculate PSD, convert to pt^2/Hz
	try
		p = psd2( o1, fftl, ss, window, 0) * 1e12 * 1e12;
	catch
		display('Failed to calculate PSD')
		return
	end
	%figure,loglog(p)

	% Loop through FB bands, sum, and average
	for lj = 1:NOB
		% Load in frequency band ranges
		switch( bandType )
			case {'UCB'},
				[ f1, f2 ] = getUCBMAFreqs( lj );
			case {'upper'},
				[ f1, f2 ] = getFBUpperFreqs( lj );
		end

		fr	 = sr / fftl;

		%  Find corresponding FFT bins.
		lb = floor( f1 / fr )+1;
		ub = floor(  f2 / fr );

		% Sum power in band and find average;
		val = sum( p(lb:ub) ) / ( ub - lb + 1 );

		fbs( lj+1, li ) = p(lj);

		%display( ['Band information: ', sprintf('%d %d %d %e', lj, lb, ub, val) ] );

	end
	% Write time stamp
	%fbs( 1, li ) = d + (1/noc)*(li+0);
	% This is now done at top during init of fbs.
end

% Write output file
if ( outFileName ~= 0 )
	s1{1} = 'time';
	for li=1:(NOB),
		cmd = sprintf( 's1{li+1} = ''fb%d'';',li );
		eval( cmd );
	end
	success = writeColumnFile( outFileName, fbs', s1, '%f' );
%	success = writeColumnFile( outFileName, fbs', ...
%			{'time', 'ma1', 'ma2', 'ma3', ...
%			  'ma4', 'ma5', 'ma6', 'ma7', ... 
%			  'ma8', 'ma9', 'ma10', 'ma11', ... 
%			  'ma12', 'ma13'}, '%f' );
	if ( success == 0 )
		error('Error writing FB file')
	end
end


return 
