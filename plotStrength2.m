function plotStrength2( spool, incidents, sources, sensorIDs, sensorNames, chCodes, chNames, plotType, plotCol, chLims, expMat )

numSensors = length(sensorIDs);
numChs = length(chCodes);

expTimes = datenum(expMat{:,2})
begT = min(expTimes)-(5*60)/86400;
finT = max(expTimes)-(5*60)/86400;
sz = size(expMat)
numExps = sz(1);
abcissa = zeros(numExps,2);
abcissa(:,1) = expTimes;
abcissa(:,2) = expTimes;

defY = 10e10;
ordinae = zeros(numExps,2);
ordinae(:,1) = 0.0001;
ordinae(:,2) = defY

sensorOrder = [1, 5, 2, 4, 3];
chOrder = [4, 1, 2, 3];

for c = 1 : numChs
	cc = chOrder(c);
	chCode = chCodes(cc);
	chIdxs = find( spool(:,4) == chCode );
	chPulses = extractRows( spool, chIdxs );

%	figure;
	for s = 1 : numSensors
		sens = sensorOrder(s);
		sensIdxs = find(chPulses(:,3)==sensorIDs(sens));
		sensorPulses = extractRows( chPulses, sensIdxs );
		numChPulses = length( sensIdxs );
		%sprintf( '%s, %s has %d pulses', sensorNames{sens}, chNames{c}, numChPulses )
		p = s+(c-1)*numSensors;
		subplot(numChs,numSensors,p)
		%subplot(numChs,1,c)
		line( abcissa', ordinae', 'Color', [0.8 0.8 0.6] )
		%return
		hold on;
		switch plotType
			case 'hist'
				histogram(sensorPulses(:,plotCol),20);
				fTag = 'pulseHistSharpness';
			case 'stem'
				stem(sensorPulses(:,1),sensorPulses(:,plotCol),'Marker','none')
				fTag = 'pulseStemPeakF';
			otherwise
    			error( [ 'Unknown signal type: ', sigDir ] )
		end 
		hold off
		%set(gca,'YLim', [0.1, chLims(c)])
		%set(gca,'YScale', 'log')
		% strength set(gca,'YLim', [20, chLims(cc)])
		%set(gca,'YLim', [3, chLims(cc)])
		%set(gca,'YLim', [-chLims(c), chLims(c)])
		if s == 1
			ylabel(chNames{cc})
		else
			set(gca,'YTickLabel',{''})
		end
		
		if c == 1
			title(sensorNames{sens})
		end
		set(gca,'YGrid', 'on')
		datetick('x','HH:MM')
		set(gca,'XLim', [ begT, finT ])
	end
	set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )
end
%print( gcf,'-djpeg100', [ 'Sep14NPDCACY/', sensorNames{s}, fTag, '.jpg' ] );



% for s = 1 : 5
% 	sensIdxs = find(spool(:,3)==sensorIDs(s));
% 	sensorPulses = extractRows( spool, sensIdxs );
% %	figure;
% 	for c = 1 : numChs
% 		chCode = chCodes(c);
% 		chIdxs = find( sensorPulses(:,4) == chCode );
% 		chPulses = extractRows( sensorPulses, chIdxs );
% 		numChPulses = length( chIdxs );
% 		sprintf( '%s, %s has %d pulses', sensorNames{s}, chNames{c}, numChPulses )
% 		p = c+(s-1)*numSensors
% 		subplot(numChs,numSensors,p)
% 		%subplot(numChs,1,c)
% 		switch plotType
% 			case 'hist'
% 				histogram(chPulses(:,5),20);
% 				fTag = '_pulseHist';
% 			case 'piezo'
% 				col = 2;
% 				% Only Rev4 & RevA sensors have piezo ...
% 				casellas=find( exps(:,11) > 0 & exps(:,4) < 9000 & exps(:,3) ~= -9999 );
% 			case 'accel'
% 				col = 3;
% 				% Only RevA sensors have piezo ...  (XXX Clark, not sure about 500, but it works for NMHS)
% 				casellas=find( exps(:,11) > 0 & exps(:,4) < 9000 & exps(:,4) > 500 & exps(:,3) ~= -9999 );
% 			otherwise
%     			error( [ 'Unknown signal type: ', sigDir ] )
% 		end 

% 		%stem(chPulses(:,1),chPulses(:,5))
% 		ylabel(chNames{c})
% 		if c == 1
% 			title(sensorNames{s})
% 		end
% 	end
% 	set(gcf, 'OuterPosition', [ 400 500 1200 900 ] )
% 	print( gcf,'-djpeg100', [ 'Sep14NPDCACY/', sensorNames{s}, fTag, '.jpg' ] );
% end