function checkConsistency( tds, sensors, chs )

sz = size(tds);
if length(sz) ~= 3
  error('Malformed data array')
end
numExps = sz(1);
numSens = sz(2);
numChns = sz(3);

% Check for sensor in proper cols
for s = 1 : numSens
  sens = sensors{s};
  for d = 1 : numExps
    for c = 1 : numChns
      td = tds{d,s,c}
      chan = parseCh( chs{c} );
      if isempty(td)
      	continue
      end
      if ~strcmp( chan, td.channel )
        error( 'Channel out of place' );
      end
      if ~strcmp( sens, td.station )
        error( 'Sensor out of place' );
      end
    end
  end
end

for d = 1 : numExps
  td = tds{d,1,1};
  utc = td.UTCref;
  for s = 1 : numSens
  	for c = 1 : numChns
  		thisTd = tds{d,s,c};
  		if isempty(thisTd)
  			warning( sprintf( 'Skipping: %d, %d, %d', d, s, c ) );
  			continue
  		end
  		if thisTd.UTCref ~= utc;
  			error( sprintf( 'Time mismatch at %d, %d, %d', d, s, c ) );
  		end
  	end
  end
end
