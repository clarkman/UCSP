function [ data, fNames ] = loadAudioData( ex, idx, sens )

dataPath = '../LFT2';
srcKey = makeSrcKey;

% display( [ 'Loading data for: ', srcKey(ex(idx,12)).name ])

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

numLoads = 1;
audiofid = fopen( audioFile );
if audiofid == -1
  warning( [ 'no audio: ', audioFile ] );
  idx
  data = {};
  fNames = {};
  return
end
fclose(audiofid);

audioData = audioread(audioFile);

data = cell(numLoads,1);
data{1} = audioData;
fNames = cell(numLoads,1);
fNames{1} = audioFile;

