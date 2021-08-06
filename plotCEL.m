function plotCEL( log, sources, ranges )

stub = 300/86400;

doLog = 1;
detrendRange = 1;

sz = size(log);
numExps = sz(1);

sensor = 1;

numGuns = length(sources);
guns = log{:,4};

valArray = zeros(numExps,4);
valArray(:,1) = datenum(log{:,2});
valArray(:,2) = log{:,6};
fps = log{:,3};

for n = 1 : numExps
	for g = 1 : numGuns
		src = sources{g};
		gun = guns{n};
		if( strcmp( sources{g}, guns{n} ) )
			display(sprintf('match!! %s | %s', src, gun ))
			valArray(n,3) = g;
			break
		end
	end
	valArray(n,4) = getRange( ranges, fps(n), sensor );
end


vals = zeros( 1, numExps );
if detrendRange
	for th = 1 : numExps
		vals(th) = undB(valArray(th,2)) * valArray(th,4);
	end
else
	vals = matched(:,2);
end

for s = 1 : numGuns
	sInds = find( valArray(:,3) == s );
	if( ~isempty(sInds) )
		matched = extractRows(valArray,sInds);
		matchedVals = extractRows(vals',sInds);
		hold on;
		if doLog
			stem(matched(:,1),matchedVals);
		else
			stem(matched(:,1),matchedVals);
		end
	end
end
legend(sources)

aa = get(gca,'YLim')
set(gca, 'XLim',[valArray(1,1)-stub,valArray(end,1)+stub])
if doLog
	%set(gca, 'YLim',[120,160])
	ylabel('dB SPL')
else
	ylabel('SPL')
end

ht = (aa(2)-aa(1))*0.8+aa(1);
yPos = [ht ht];
colr = [0.7 0.7 0.7];
wdth = 3; 
line([datenum('2016-09-14 18:55:00') datenum('2016-09-14 19:33:00')],yPos, 'Color', colr, 'LineWidth', wdth);
line([datenum('2016-09-14 19:34:00') datenum('2016-09-14 19:38:00')],yPos, 'Color', colr, 'LineWidth', wdth);
line([datenum('2016-09-14 19:39:00') datenum('2016-09-14 19:55:00')],yPos, 'Color', colr, 'LineWidth', wdth);

set(gca,'YGrid','on');
xlabel('time')
datetick('x','HH:MM')
set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )
