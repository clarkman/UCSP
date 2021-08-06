function testHpFilters( seg )

if 1
  % Orig
  passFreq = 0.1;
  filtrLen = 1373;
  tosssecs = 30;
  %passFreq = 0.05;
  %filtrLen = 2745;
  %tosssecs = 60;
else
  passFreq = 0.2;
  filtrLen = 685;
  tosssecs = 15;
end

staInfo = getStaInfo(seg.DataCommon.station);

hp=highpass(double(zeroCenter(seg)),passFreq,filtrLen);
s = hp.samples;
s = s(ceil(tosssecs*seg.sampleRate):end); %Throw away 30 secs for filter chargeup
hp.DataCommon.UTCref = hp.DataCommon.UTCref + tosssecs/86400;
hp.samples = s;

plot2( zeroCenter(seg), hp+10000 )

%seg = zeroCenter(hp);



