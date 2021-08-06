function plotThree(tds,titl,tLeft,toffs)

% plot(tds{1},tds{2},tds{3})
% return


segSecs = 8;
if nargin > 3 %Trim
  numTDs = numel(tds);
  if numel(toffs) ~= numTDs
  	error('gripe')
  end
  for t = 1 : numTDs
  	tOff = toffs(t)
  	if tOff < 0
  	  error('Negative time offsets not allowed')
  	end
  	td = tds{t}
    sampRate = td.sampleRate
  	if tLeft == 0
      numSampsToDiscard = 1;
  	else
      numSampsToDiscard = tLeft + sampRate * tOff;
    end
    segLen = segSecs * sampRate;
    samps = td.samples;
    samps = samps(numSampsToDiscard:numSampsToDiscard+segLen);
    td.samples = samps;
    tds{t} = td;
  end
end


stds = [ std(tds{1}) std(tds{2}) std(tds{3}) ];
[ vx, indx ] = max(stds);
[ vn, indn ] = min(stds);
for t = 1 : 3
  if( t == indx || t == indn )
  	continue
  end
  indm = t;
end

corder = get(gca,'ColorOrder');     % use the standard color ordering matrix
ncolors = size(corder);
ncolors = ncolors(1,1);

%ord = [ indx, indm, indn ];
ord = [ 1, 2, 3 ];

for ith = 1 : 3
  wh = ord(ith);
  tObj = tds{wh};
  xVec = timeVector(tObj) * 86400;
  hold on;
    plot( xVec, tObj.samples, 'Color', corder(wh,:) );
  hold off;
end

signals={'2630000','2520000','2100000'}

legend({signals{ord(1)},signals{ord(2)},signals{ord(3)}});

title(titl)
