function nextIdx = playIncident( exps, sens, fps, selections, thisIdx )

srcKey = makeSrcKey;
fpKey = makeFpKey;

rowInds = find(exps(:,13)==selections(thisIdx));

rows = extractRows(exps,rowInds);

sz = size(rows);

numRows = sz(1);

for r = 1 : numRows

  [ data, fNames ] = loadAudioData( rows, r, sens );

  out = normAudio( data{1} );
  out = data{1};
  sensor = rows(r,4);
  fpName = fpKey(rows(r,1)).name;
  srcName = srcKey(rows(r,12)).name;
  dB_SPL = rows(r,11);
  rangeInd = find( fps(:,1) == rows(r,1) & fps(:,2) == sensor );
  rangeRow = extractRows( fps, rangeInd );
  range = rangeRow(1,3);

  close('all')
  plot(out);
  set(gca,'YLim',[-1 1]);
  title(sprintf('%s - Sensor = %d, src = %s, range = %g ft, dB SPL = %g', fpName, sensor,srcName,range,dB_SPL))
  while 1

    [x, y, button] = ginput(1);

    if( button == 3 ) % done
	  if rows(r,4) < 9000
	    soundsc(out,24000)
	  else
	    soundsc(out,48000)
	  end
      break;
    end
        
  end
end

close('all')

nextIdx = thisIdx + 1;
