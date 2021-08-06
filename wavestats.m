function [ stats, sers ] = wavestats( dirName )

if dirName(end) ~= '/'
  dirName = [ dirName, '/' ];
end

var1FName = [ dirName, '*.flac' ];
fileName1 = dir( var1FName );

if isempty(fileName1)
	var1FName = [ dirName, '*.wav' ];
    fileName1 = dir( var1FName );
end

sz = size(fileName1);
numFiles = sz(1);

stats = zeros(numFiles,3)

for f = 1 : numFiles
	fName = fileName1(f).name;
	[ zone, znum, dn, friendlyNumber, serialNumber, ext ] = parseDnloadName( fName );
	td = loadWavTD( [dirName fName] )
	sers{f} = serialNumber;
	stats(f,1) = rms(td.samples)
	stats(f,2) = std(td)
	td.samples = filterA(td.samples, td.sampleRate);
	stats(f,3) = std(td)
end
