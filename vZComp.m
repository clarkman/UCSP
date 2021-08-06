function tdOut = vZComp( tdIn )

% Amplitude (±) of counts when 1Vp-p is applied.
baseCorr = 0.6681;
baseVol = 2;

% XXX Clark, unfortunately volume settings are not linear. 
% From waveforms:
volArr  = [ 0.0578, 0.0578, 0.1156, 0.1156, 0.2315, 0.2313, 0.4629, 0.6549, 0.9268 ];
% From pwelch:
% Without trimming off startup rush at beginning of recording:
% volArr = [ 0.0353, 0.0353, 0.0705, 0.0705, 0.0705, 0.1411, 0.2823, 0.3993, 0.5650 ];
% With trimming off 0.2 secs of startup:
% volArr = [ 0.0352, 0.0352, 0.0703, 0.0703, 0.1407, 0.1407, 0.2815, 0.3982, 0.5635 ];

% Normalize so that baseCorr (taken at Vol=2 and 1Vp-p) can be used:
volArr = volArr ./ volArr(3)
% Now create correction array
volArr = volArr .* (baseCorr)

% Convetion is to use VolX (Vol0 thru Vol8) in all WAV file names
titl = tdIn.title;
volClause = strfind( titl, 'Vol' );
level = sscanf(titl(volClause+3),'%d');

tdOut = tdIn;
% Volume is zero based, so +1
tdOut.samples = tdIn.samples ./ volArr(level+1);
tdOut.valueUnit = 'Volts';
