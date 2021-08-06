function [ m, testStrs, gunStrs, ammoStrs, xducerStrs ] = populateAnalysisMatrix2()

codeVersion = 2;

% Version 2 for 2nd Chabot test

%testGetters();
testStrs = loadTestStrs();
gunStrs = loadGunStrs();
ammoStrs = loadAmmoStrs();
xducerStrs = getChannelCodes();
xducerSets = loadXducerSets();
%xducerSets = loadXducerSets( { '2016-02-11', '2016-02-18' } );
labjackStrs = loadLabjackStrs();

wavFiles = dir('*.wav');

sz=size(wavFiles);
numWavFiles = sz(1);

numActualWavFiles = 0;
for f = 1 : numWavFiles
	k = strfind(wavFiles(f).name,'-');
  if numel(k) < 12
    % Make room for new four channel files.
    continue
  end
  numActualWavFiles = numActualWavFiles + 1;
  rawFiles{numActualWavFiles} = wavFiles(f).name(1:k(12)-1);
end

rawExpNames = unique(rawFiles);
sz=size(rawExpNames);
numRawFiles = sz(2);

mTmp=zeros(numRawFiles,14);

for r = 1 : numRawFiles
  rawFileName = rawExpNames{r};
  rawFileNameLen = size(rawFileName);
  k = strfind(rawFileName,'-');
  numChans = sscanf(rawFileName(k(1)+1:k(2)-1),'%d');
  clear hitNames;
  hits = 0;
  for f = 1 : numWavFiles
    %rawFileName
    %wavFiles(f).name
  	if strncmp( rawFileName, wavFiles(f).name, rawFileNameLen(2) )
      hitName = wavFiles(f).name;
      if( strcmp( hitName(end-4:end), 'a.wav' ) || ... 
          strcmp( hitName(end-4:end), 'b.wav' ) || ... 
          strcmp( hitName(end-4:end), 'c.wav' ) )
        %sdisplay( [ 'Skipping ', hitName ] )
        continue
      end
  	  hits = hits + 1;
  	  hitNames{hits} = hitName;
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
  % ChabotGCFilt19-4-none-blank-2016-02-18-12-36-14-31.6-a-Knowles-Lo.wav
  mTmp(r,1) = getTestCode(testStrs,fullTestName(1:n));
  mTmp(r,2) = sscanf(fullTestName(n+1:k(1)-1), '%d');
  mTmp(r,3) = numChans;
  mTmp(r,4) = sscanf(rawFileName(k(10)+1:k(11)-1),'%f');
  mTmp(r,5) = getGunCode(gunStrs,rawFileName(k(2)+1:k(3)-1));
  mTmp(r,6) = getAmmoCode(ammoStrs,rawFileName(k(3)+1:k(4)-1));

  for h = 1 : hits
    xducer = hitNames{h};
    k = strfind(xducer,'-');
    xducerSet{h} = xducer(k(12)+1:end-4);
  end

  sz = size(xducerSets);
  numLoadedXducerSets = 5;
  xducers = xducerSets{1};
  for x = 1 : numLoadedXducerSets
    sz = size(xducers);
    numXducerSetRows = sz(1);
    numXducerSetCols = sz(2);
    for row = 1 : numXducerSetRows
      colMatch = zeros(1,4);
      numMatched = 0;
  	  for col = 1 : numXducerSetCols
        xducerSetCol = xducers(row,col);
        for h = 1 : hits
        	foundWav = xducerSet{h};
          if( strcmp( foundWav, 'PbS-Hi-Gain' ) && strcmp( 'PbS-Lo-Gain', xducerSetCol ) )
            numMatched = numMatched + 1;
            colMatch(col) = h;
        	elseif( strcmp( foundWav, xducerSetCol ) )
        	  numMatched = numMatched + 1;
        	  colMatch(col) = h;
        	end
        end
      end
      if numMatched == numXducerSetCols
        break
      end
    end
  end
  if(numMatched ~= 4)
    r
    numMatched
    rawFileName
    error('Kaboom')
  end

  mTmp(r,7) = x;
  mTmp(r,8) = getXducerCode( xducerStrs, xducerSet{colMatch(1)} );
  mTmp(r,9) = getXducerCode( xducerStrs, xducerSet{colMatch(2)} );
  mTmp(r,10) = getXducerCode( xducerStrs, xducerSet{colMatch(3)} );
  mTmp(r,11) = getXducerCode( xducerStrs, xducerSet{colMatch(4)} );

  %f = dir( makeRawName( mTmp(r,:), testStrs, gunStrs, ammoStrs, xducerStrs ) )
  %mTmp(r,12) = datenum(f.date);
  %datestr(datenum(rawFileName(k(4)+1:k(11)-1),'yyyy-mm-dd-HH-MM-SS'))
  mTmp(r,12) = datenum(rawFileName(k(4)+1:k(11)-1),'yyyy-mm-dd-HH-MM-SS');
    
  mTmp(r,13) = getLabjackCode( labjackStrs, rawFileName(k(11)+1:k(12)-1) );

  mTmp(r,14) = codeVersion;

end

m = mTmp;
%size(m)
