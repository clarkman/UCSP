function [ data, fNames ] = loadPiezoData( ex, idx, sens )

dataPath = '../LFT2';
srcKey = makeSrcKey;

% display( [ 'Loading data for: ', srcKey(ex(idx,12)).name ])
% ex(idx,:)

sensId = ex(idx,4);
fileNum = ex(idx,5);

sz = numel(sens);
numSensors = sz(1);

for s = 1 : numSensors
  if sens(s).sensId == sensId
  	break
  end
end

sensHex = upper(sens(s).sensHex);

piezoFile = [ dataPath, '/', sensHex, '-', sprintf('%d',fileNum), '-piezo.wav'];

numLoads = 1;
piezofid = fopen( piezoFile );
if piezofid == -1
  warning( [ 'no piezo: ', piezoFile ] );
  data = {};
  fNames = {};
  return
end
fclose(piezofid);

piezoData = audioread(piezoFile);

data = cell(numLoads,1);
data{1} = piezoData;
fNames = cell(numLoads,1);
fNames{1} = piezoFile;

