function sig = randLSB()

lsb = 2.0/2^24;
numbins=512

numSamps = 8*48000;
sig = zeros(1,numSamps);
for s = 1 : numSamps
	sig(1,s) = lsb*floor(random('unif',0,numbins));
end
%plot(hist(sig))
td=TimeData;
td.UTCref=now;
td.sampleRate=48000;
td.samples=sig';

plot(spectrum(td,4096))