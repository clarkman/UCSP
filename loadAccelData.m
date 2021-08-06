function [ data, fNames ] = loadAccelData( ex, idx, sens, ch )

dataPath = '../LFT2';
srcKey = makeSrcKey;

% display( [ 'Loading data for: ', srcKey(ex(idx,12)).name ])
% ex(idx,:)

% Arg, no values saved for traceability in INI file.
% XXX Clark gain must be assumed.
% +/- 2 Gs over a signal range of +/- 1 wav units
wav2Gs = 2;

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

accelFile = [ dataPath, '/', sensHex, '-', sprintf('%d',fileNum), '-infrared.wav'];
accelfid = fopen( accelFile );
if accelfid == -1
  warning( [ 'no acclerometer data: ', accelFile ] );
  idx
  data = {};
  fNames = {};
  return
else
  fclose(accelfid);
end

accelData = audioread(accelFile);

if nargin < 4
  data{1} = accelData;
else
  data{1} = accelData(:,ch+1);
end
fNames{1} = accelFile;
