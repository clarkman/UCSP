function plotIncidentSpectra( exps, sens, beg, fin, Fs )

srcKey = makeSrcKey;

% All ...
% figure;
% plot(ar2(:,14),ar2(:,11),'Marker','o','LineStyle','none')
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'All Casella measurements')

voltsCorr = sqrt(2);

src40 = findSrcKey( srcKey, '0.40' );
src22 = findSrcKey( srcKey, '0.22' );
srcBN = findSrcKey( srcKey, 'Balloon' );
srcSP = findSrcKey( srcKey, 'StrtrPstl' );
srcFC = findSrcKey( srcKey, 'frcrckr' );

casellas=find( exps(:,11) > 0 );
numCasellas = numel(casellas);
display(sprintf('A total of %d Casella Measurements made',numCasellas))
casExps = extractRows( exps, casellas );

casIdxs = unique(casExps(:,13))

numCasIdxs = numel(casIdxs)

for c = 1 : numCasIdxs

	cInds = find( casExps(:,13) == casIdxs & casExps(:,3) ~= -9999 )
	numSensors = numel(cInds);
	if ~numHits
	    continue
	end
	
	cExps = extractRows(casExps,cInds);

    idx40 = find( cExps(:,12) == src40 );
    num40s = numel(idx40);
    if ~num40s
    	%PLot dummy
    elseif num40s == 1
    	exp40 = extractRows(cExps,idx40);
		real40 = TimeData;
		real40.UTCref = exp40(e,10);
		real40.sampleRate = Fs;
		samps = loadAudioData( exp40, e, sens )
		real40.samples = samps{1};
		real40 = slice( real40, beg, fin );
        plot(spectrum(real40,1024));
    else
    	error('.40 caliber mismatch!')
    end
    	
end

