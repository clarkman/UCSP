function dns = timeVector( tdObj )

startT = tdObj.DataCommon.UTCref;
numSamps = tdObj.sampleCount;
sampPeriod = 1 / tdObj.sampleRate;
sampPeriod = sampPeriod / 86400;

dns = zeros( numSamps, 1 );

for tt = 0 : numSamps - 1
   dns(tt+1) = startT + tt * sampPeriod;
end

if( length(tdObj) ~= length(dns) )
  error( 'Count mismatch' );
end