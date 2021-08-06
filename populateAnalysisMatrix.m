function [ m, testStrs, gunStrs, ammoStrs, xducerStrs ] = populateAnalysisMatrix()

codeVersion = 1;

%testGetters();
testStrs = loadTestStrs();
gunStrs = loadGunStrs();
ammoStrs = loadAmmoStrs();
xducerStrs = getChannelCodes();
xducerSets = loadXducerSets();

wavFiles = dir('*.wav');

sz=size(wavFiles);
numWavFiles = sz(1);

for f = 1 : numWavFiles
	k = strfind(wavFiles(f).name,'-');
	rawFiles{f} = wavFiles(f).name(1:k(5)-1);
end

rawExpNames = unique(rawFiles);
sz=size(rawExpNames);
numRawFiles = sz(2);

mTmp=zeros(numRawFiles,14);

for r = 1 : numRawFiles
  rawFileName = rawExpNames{r}
  rawFileNameLen = size(rawFileName);
  k = strfind(rawFileName,'-');
  numChans = sscanf(rawFileName(k(1)+1:k(2)-1),'%d');
  clear hitNames;
  hits = 0;
  for f = 1 : numWavFiles
  	if strncmp( rawFileName, wavFiles(f).name, rawFileNameLen(2) )
  	  hits = hits + 1;
  	  hitNames{hits} = wavFiles(f).name;
  	end
  end
  sz = size(hitNames);
  if sz(2) ~= numChans
  	error('Channel mismatch!')
  end
  % Seq, test, numChs, rangeFt, gun, ammo, ch1, ch2, ch3, ch4
  fullTestName = rawFileName(1:k(1)-1);
  fullTestNameLen = numel(fullTestName);
  for n = fullTestNameLen : -1 : 1
  	if( isempty( sscanf(fullTestName(n),'%d') ) )
  	  break
  	end
  end
  mTmp(r,1) = getTestCode(testStrs,fullTestName(1:n));
  mTmp(r,2) = sscanf(fullTestName(n+1:k(1)-1), '%d');
  mTmp(r,3) = numChans;
  mTmp(r,4) = sscanf(rawFileName(k(2)+1:k(3)-1),'%d');
  mTmp(r,5) = getGunCode(gunStrs,rawFileName(k(3)+1:k(4)-1));
  mTmp(r,6) = getAmmoCode(ammoStrs,rawFileName(k(4)+1:end));

  for h = 1 : hits
    xducer = hitNames{h};
    k = strfind(xducer,'-');
    xducerSet{h} = xducer(k(5)+1:end-4);
  end
  sz = size(xducerSets);
  numLoadedXducerSets = sz(1);
  for x = 1 : numLoadedXducerSets
    numLoadedXducerCols = sz(2); % XXX Clark, not finished
    colMatch = zeros(1,4);
    numMatched = 0;
  	for col = 1 : numLoadedXducerCols
      xducerSetCol = xducerSets{x,col};
      for h = 1 : hits
      	foundWav = xducerSet{h};
      	if( strcmp( foundWav, xducerSetCol ) )
      	  numMatched = numMatched + 1;
      	  colMatch(col) = h;
      	end
      end
    end
    if numMatched == numLoadedXducerCols
      break
    end

  end
  if(numMatched ~= 4)
  	error('Badadd')
  end
  mTmp(r,7) = x;
  mTmp(r,8) = getXducerCode( xducerStrs, xducerSet{colMatch(1)} );
  mTmp(r,9) = getXducerCode( xducerStrs, xducerSet{colMatch(2)} );
  mTmp(r,10) = getXducerCode( xducerStrs, xducerSet{colMatch(3)} );
  mTmp(r,11) = getXducerCode( xducerStrs, xducerSet{colMatch(4)} );

  f = dir( makeRawName( mTmp(r,:), testStrs, gunStrs, ammoStrs, xducerStrs ) );
  mTmp(r,12) = datenum(f.date);

  mTmp(r,13) = 1;
  mTmp(r,14) = codeVersion;

end

m = mTmp;
%size(m)
