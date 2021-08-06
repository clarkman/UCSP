function tdObj = factoryTimeData( samps, sampRate, utc )

tdObj = TimeData;
tdObj.sampleRate = sampRate;
tdObj.samples = samps;

if nargin > 3
  tdObj.UTCref = utc; % datenum
end

