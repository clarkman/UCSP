function [ tdArray, testNums ] = loadSSTExperiment( sensors, chs )

if nargin < 2
  chs = {''};
  numChs = -1;
else
  numSensors = length(sensors);
end
if nargin < 1
  sensors = {''};
  numSensors = -1;
else
  numChs = length(chs);
end

numSensors = 6;

subDirStr = ls;
subDirs = cellstr(strsplit(subDirStr,'\n')');
numSubDirs = length(subDirs)-1;
tdArray = cell( numSubDirs, numSensors, numChs );
testNums = zeros( 1, numSubDirs );
for d = 1 : numSubDirs
	if isempty(subDirs{d})
		continue
	end
	testNums(d) = parseTestNum( subDirs{d} )
	tds = loadSSTDownload( subDirs{d}, sensors, chs );
	for s = 1 : numSensors
		for c = 1 : numChs
	        tdArray{d,s,c} = tds{s,c};
	    end
    end
end

%numSubDirs = length(  ) 