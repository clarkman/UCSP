function [ data, fNames ] = loadData( ex, idx, sens )

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

audioFile = [ dataPath, '/', sensHex, '-', sprintf('%d',fileNum), '-audio.wav'];
piezoFile = [ dataPath, '/', sensHex, '-', sprintf('%d',fileNum), '-piezo.wav'];
accelFile = [ dataPath, '/', sensHex, '-', sprintf('%d',fileNum), '-infrared.wav'];

numLoads = 3;
audiofid = fopen( audioFile );
if audiofid == -1
  error( [ 'no audio: ', audioFile ] );
end
fclose(audiofid);
piezofid = fopen( piezoFile );
if piezofid == -1
  error( [ 'no piezo: ', piezoFile ] );
end
fclose(piezofid);
accelfid = fopen( accelFile );
if accelfid == -1
  numLoads = 2;
else
  fclose(accelfid);
end

audioData = audioread(audioFile);
piezoData = audioread(piezoFile);
if numLoads == 3
  accelData = audioread(accelFile);
end

data = cell(numLoads,1);
data{1} = audioData;
data{2} = piezoData;
fNames = cell(numLoads,1);
fNames{1} = audioFile;
fNames{2} = piezoFile;
if numLoads == 3
  data{3} = accelData;
  fNames{3} = accelFile;
end

