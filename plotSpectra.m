function plotSpectra( arr, sens, inds, beg, fin, Fs )

srcKey = makeSrcKey;
src40 = findSrcKey( srcKey, '0.40' );
src22 = findSrcKey( srcKey, '0.22' );
srcBN = findSrcKey( srcKey, 'Balloon' );
srcSP = findSrcKey( srcKey, 'StrtrPstl' );
srcFC = findSrcKey( srcKey, 'frcrckr' );

exps = extractRows( arr, inds );

idxs{1} = find( exps(:,12) == src40 );
idxs{2} = find( exps(:,12) == src22 | exps(:,12) == srcSP );
idxs{3} = find( exps(:,12) == srcBN );
idxs{4} = find( exps(:,12) == srcFC );

expCounts = zeros(4,1);
expCounts(1) = numel(idxs{1});
expCounts(2) = numel(idxs{2});
expCounts(3) = numel(idxs{3});
expCounts(4) = numel(idxs{4});

[ numExps, ind ] = max( expCounts );

real40Exps = extractRows( exps, idxs{1} );
real22Exps = extractRows( exps, idxs{2} );
realBNExps = extractRows( exps, idxs{3} );
realFCExps = extractRows( exps, idxs{4} );


for e = 1 : numExps

    legIndex = 0;
	figure;

    if expCounts(1) >= e
		real40 = TimeData;
		real40.UTCref = real40Exps(e,10);
		real40.sampleRate = Fs;
		samps = loadAudioData( real40Exps, e, sens )
		real40.samples = samps{1};
		real40 = slice( real40, beg, fin );
		plot(spectrum(real40,1024));
		legIndex = legIndex + 1;
 		leg{legIndex} = sprintf('FP=%d, Dir=%d, Sensor=%d, dB=%g, src=%s, range=%g-ft.',real40Exps(e,1),real40Exps(e,2),real40Exps(e,4),real40Exps(e,11),srcKey(real40Exps(e,12)).name,real40Exps(e,14))
	end

	hold on;

    if expCounts(2) >= e
		real22 = TimeData;
		real22.UTCref = real22Exps(e,10);
		real22.sampleRate = Fs;
		samps = loadAudioData( real22Exps, e, sens )
		real22.samples = samps{1};
		real22 = slice( real22, beg, fin );
		plot(spectrum(real22,1024));
		legIndex = legIndex + 1;
 		leg{legIndex} = sprintf('FP=%d, Dir=%d, Sensor=%d, dB=%g, src=%s, range=%g-ft.',real22Exps(e,1),real22Exps(e,2),real22Exps(e,4),real22Exps(e,11),srcKey(real22Exps(e,12)).name,real22Exps(e,14))
	end

    if expCounts(3) >= e
		realBN = TimeData;
		realBN.UTCref = realBNExps(e,10);
		realBN.sampleRate = Fs;
		samps = loadAudioData( realBNExps, e, sens )
		realBN.samples = samps{1};
		realBN = slice( realBN, beg, fin );
		plot(spectrum(realBN,1024));
		legIndex = legIndex + 1;
 		leg{legIndex} = sprintf('FP=%d, Dir=%d, Sensor=%d, dB=%g, src=%s, range=%g-ft.',realBNExps(e,1),realBNExps(e,2),realBNExps(e,4),realBNExps(e,11),srcKey(realBNExps(e,12)).name,realBNExps(e,14))
	end

    if expCounts(4) >= e
		realFC = TimeData;
		realFC.UTCref = realFCExps(e,10);
		realFC.sampleRate = Fs;
		samps = loadAudioData( realFCExps, e, sens )
		realFC.samples = samps{1};
		realFC = slice( realFC, beg, fin );
		plot(spectrum(realFC,1024));
		legIndex = legIndex + 1;
 		leg{legIndex} = sprintf('FP=%d, Dir=%d, Sensor=%d, dB=%g, src=%s, range=%g-ft.',realFCExps(e,1),realFCExps(e,2),realFCExps(e,4),realFCExps(e,11),srcKey(realFCExps(e,12)).name,realFCExps(e,14))
	end

    legend(leg)

	set(gca,'XScale','log');
	set(gca,'YScale','log');
    setPlotSize();

    while 1

      [x, y, button] = ginput(1);

      if( button == 3 ) % done
      	clear leg;
      	close('all')
        break;
      end
    end
end


return
end