function plotPulseInterrivalTimes(pulses,pulseType,plotType,titl,srar)

pIdxs = find( pulses(:,9) == pulseType );
display( sprintf('found %d pulses', numel(pIdxs) ) );
numPulses = numel(pIdxs);
pSet = pulses(pIdxs,:);

%numel(unique(pulses(:,1)))
sensors = sort(unique(pSet(:,1)));
numSensors = numel( sensors );

display( sprintf('pulses cover datetimes : %s -to- %s', datestr(pSet(1,2)), datestr(pSet(end,2)) ) )

if nargin < 5
	srar=1;
end

switch plotType
	case 1 % Strength vs Time
		plot( pSet(:,2), pSet(:,3) )
		datetick('x',6);
		set(gca,'XLim',[pSet(1,2),pSet(end,2)]);
		xlabel('PulseDateTime')
		ylabel('strength')
		axPos = [ 0.05 0.05 0.9 0.9 ]
		outerPos = [ 400 500 1280 1024 ];
		title([ titl, ', ', sprintf( '%d pulses on %d sensors, ', numPulses, numSensors ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
	case 2 % Interarrival summary
		vals = zeros(numSensors,5);
		for s = 1 : numSensors
			sensor = sensors(s);
			pIdxs = find( pSet(:,1) == sensor );
			sensorPulses = pSet(pIdxs,:);
			numSensorPulses = numel(pIdxs);
			display(sprintf('Found %d pulses for sensor %d', numSensorPulses, sensor))
			vals(s,1) = min(sensorPulses(:,3));
			vals(s,2) = max(sensorPulses(:,3));
			vals(s,3) = mean(sensorPulses(:,3));
			vals(s,4) = median(sensorPulses(:,3));
			vals(s,5) = numSensorPulses;
		end
		stem(vals(:,1),'Marker','^');
		hold on;
		stem(vals(:,2),'Marker','v')			
		stem(vals(:,3),'Marker','o')			
		stem(vals(:,4),'Marker','x')
		set(gca,'YLim',[15 2000])
		ssids = linspace(1,numSensors,numSensors);
		xlbl = cellstr(sprintf('%d\n',sensors));
		for s = 1 : numSensors
			text(ssids(s),vals(s,2),sprintf('  %d',vals(s,5)),'HorizontalAlignment','left','VerticalAlignment','middle','Rotation',90,'FontSize',12)
		end
		set(gca,'XTick',ssids);
        set(gca,'XTickLabel',xlbl,'XTickLabelRotation',90);
		set(gca,'XLim',[0 numSensors+1])
		set(gca,'XGrid','on')
		set(gca,'YScale','log')
		set(gca,'YGrid','on')
		xlabel('Sensor Friendly Number')
		ylabel('strength')
		axPos = [ 0.05 0.075 0.9 0.9-0.025 ];
		outerPos = [ 400 500 1280 1024 ];
		legend({'min','max','mean','median'})
		vals(:,5)
		if( sum(vals(:,5)) ~= numPulses )
			warning('funky whopped')
		end
		title([ titl, ', ', sprintf( '%d pulses on %d sensors, ', numPulses, numSensors ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
	case 3 % Interarrival summary
		vals = zeros(numSensors,1);
		for s = 1 : numSensors
			sensor = sensors(s);
			pIdxs = find( pSet(:,1) == sensor );
			sensorPulses = pSet(pIdxs,:);
			numSensorPulses = numel(pIdxs);
			display(sprintf('Found %d pulses for sensor %d', numSensorPulses, sensor))
			vals(s,1) = numSensorPulses;
		end
		stem(vals(:,1),'Marker','o');
		ssids = linspace(1,numSensors,numSensors);
		xlbl = cellstr(sprintf('%d\n',sensors));
		set(gca,'XTick',ssids);
        set(gca,'XTickLabel',xlbl,'XTickLabelRotation',90);
		set(gca,'XLim',[0 numSensors+1])
		set(gca,'XGrid','on')
		set(gca,'YScale','log')
		set(gca,'YGrid','on')
		xlabel('Sensor Friendly Number')
		ylabel('strength')
		axPos = [ 0.05 0.075 0.9 0.9-0.025 ];
		outerPos = [ 400 500 1280 1024 ];
		title([ titl, ', ', sprintf( '%d pulses on %d sensors, ', numPulses, numSensors ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
		set(gca,'YTickLabel',{'1','10','100','1000','10000','100000'})
	case 4 % Interarrival times
		vals = zeros(numSensors,5);
		for s = 1 : numSensors
			sensor = sensors(s);
			pIdxs = find( pSet(:,1) == sensor );
			if numel(pIdxs) < 2
				continue
			end
			sensorPulses = pSet(pIdxs,:);
			numSensorPulses = numel(pIdxs);
			interArrs = (sensorPulses(2:end,2)-sensorPulses(1:end-1,2))*86400;
			vals(s,1) = min(interArrs);
			vals(s,2) = max(interArrs);
			vals(s,3) = mean(interArrs);
			vals(s,4) = median(interArrs);
			vals(s,5) = numSensorPulses;
		end
		stem(vals(:,1),'Marker','^');
		hold on;
		stem(vals(:,2),'Marker','v')			
		stem(vals(:,3),'Marker','o')			
		stem(vals(:,4),'Marker','x')
		%set(gca,'YLim',[15 2000])
		ssids = linspace(1,numSensors,numSensors);
		xlbl = cellstr(sprintf('%d\n',sensors));
		for s = 1 : numSensors
			text(ssids(s),vals(s,2),sprintf('  %d',vals(s,5)),'HorizontalAlignment','left','VerticalAlignment','middle','Rotation',90,'FontSize',12)
		end
		set(gca,'XTick',ssids);
        set(gca,'XTickLabel',xlbl,'XTickLabelRotation',90);
		set(gca,'XLim',[0 numSensors+1])
		set(gca,'XGrid','on')
		set(gca,'YScale','log')
		set(gca,'YGrid','on')
		xlabel('Sensor Friendly Number')
		ylabel('seconds')
		axPos = [ 0.075 0.075 0.9-0.025 0.9-0.025 ];
		outerPos = [ 400 500 1280 1024 ];
		legend({'min','max','mean','median'})
		title([ titl, ', ', sprintf( '%d pulses on %d sensors, ', numPulses, numSensors ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
		set(gca,'YTickLabel',{'0.001','0.01','0.1','1','10','100','1000','10000','100000','1000000'})
	case 5 % Strength vs Hour of day
%		for p = 1 : numPulses
		clockTicks = linspace(0,2*pi,25); 
		clockTicks = clockTicks(1:24);
		clockRad = 1120;
		textRad = clockRad * 1.025;
		for c = 1 : 24
			line([ 0 clockRad*sin(clockTicks(c)) ], [ 0 clockRad*cos(clockTicks(c)) ],'Color','k')
			clockRot = -(clockTicks(c)*180/pi-90)
			text( textRad*sin(clockTicks(c)), textRad*cos(clockTicks(c)), sprintf('%02d',c-1),'Rotation',clockRot)
		end
		pDay = (pSet(:,2)-floor(pSet(:,2))) * 2 * pi;
		%for p = 1 : 1000
		for p = 1 : numPulses
			%pDay = (pSet(p,2)-floor(pSet(p,2))) * 2 * pi;
			x = sin(pDay(p)) * pSet(p,3);
			y = cos(pDay(p)) * pSet(p,3);
			line( [0 x], [ 0, y ] )
		end
		xlabel('strength')
		ylabel('strength')
		set(gca,'XLim',[-1200 1200])
		set(gca,'YLim',[-1200 1200])
		axPos = [ 0.05 0.05 0.9 0.9 ]
		outerPos = [ 400 500 1024 1024 ];
		title([ titl, ', ', sprintf( '%d pulses on %d sensors, ', numPulses, numSensors ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
	case 6 % Counts vs Hour of day
%		for p = 1 : numPulses
		clockTicks = linspace(0,2*pi,25); 
		clockTicks = clockTicks(1:24);
		clockRad = 1900;
		textRad = clockRad * 1.015;
		for c = 1 : 24
			line([ 0 clockRad*sin(clockTicks(c)) ], [ 0 clockRad*cos(clockTicks(c)) ],'Color','k')
			clockRot = -(clockTicks(c)*180/pi-90)
			text( textRad*sin(clockTicks(c)), textRad*cos(clockTicks(c)), sprintf('%02d',c-1),'Rotation',clockRot)
		end
		pDay = (pSet(:,2)-floor(pSet(:,2))) * 2 * pi;
		% Fifteen minute slices
		numSlices = 4*24;
		halfSlice = 1/(2*numSlices);
		bins = hist(pDay,numSlices);
		binTicks = linspace(0,2*pi,numSlices+1);
		binTicks = binTicks(1:numSlices); 
		for p = 1 : numSlices
			x = sin(binTicks(p)) * bins(p);
			y = cos(binTicks(p)) * bins(p);
			line( [0 x], [ 0, y ], 'LineWidth', 2, 'Marker', 'o' )
		end
		xlabel('counts')
		ylabel('counts')
		%set(gca,'XLim',[-2000 2000])
		%set(gca,'YLim',[-2000 2000])
		axPos = [ 0.05 0.05 0.9 0.9 ]
		outerPos = [ 400 500 1024 1024 ];
		title([ titl, ', ', sprintf( '%d pulses on %d sensors, ', numPulses, numSensors ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
	case 7 % DeltaTriggers
		vals = zeros(numSensors,5);
		for s = 1 : numSensors
			sensor = sensors(s);
			pIdxs = find( pSet(:,1) == sensor & pSet(:,8) > 0 );
			sensorPulses = pSet(pIdxs,:);
			numSensorPulses = numel(pIdxs);
			display(sprintf('Found %d pulses for sensor %d', numSensorPulses, sensor))
			vals(s,1) = min(sensorPulses(:,8));
			vals(s,2) = max(sensorPulses(:,8));
			vals(s,3) = mean(sensorPulses(:,8));
			vals(s,4) = median(sensorPulses(:,8));
			vals(s,5) = numSensorPulses;
		end
		stem(vals(:,1),'Marker','^');
		hold on;
		stem(vals(:,2),'Marker','v')			
		stem(vals(:,3),'Marker','o')			
		stem(vals(:,4),'Marker','x')
		%set(gca,'YLim',[15 2000])
		ssids = linspace(1,numSensors,numSensors);
		xlbl = cellstr(sprintf('%d\n',sensors));
		for s = 1 : numSensors
			text(ssids(s),vals(s,2),sprintf('  %d',vals(s,5)),'HorizontalAlignment','left','VerticalAlignment','middle','Rotation',90,'FontSize',12)
		end
		set(gca,'XTick',ssids);
        set(gca,'XTickLabel',xlbl,'XTickLabelRotation',90);
		set(gca,'XLim',[0 numSensors+1])
		set(gca,'XGrid','on')
		%set(gca,'YScale','log')
		set(gca,'YGrid','on')
		xlabel('Sensor Friendly Number')
		ylabel('DeltaTrigger')
		axPos = [ 0.05 0.075 0.9 0.9-0.025 ];
		outerPos = [ 400 500 1280 1024 ];
		legend({'min','max','mean','median'})
		vals(:,5)
		if( sum(vals(:,5)) ~= numPulses )
			warning('funky whopped')
		end
		title([ titl, ', ', sprintf( '%d pulses on %d sensors, ', numPulses, numSensors ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
	case 8 % Instantaneous interarrival rates
		vals = zeros(numSensors,5);
		for s = srar : numSensors
			s
			sensor = sensors(s);
			pIdxs = find( pSet(:,1) == sensor );
			if numel(pIdxs) < 2
				continue
			end
			sensorPulses = pSet(pIdxs,:);
			numSensorPulses = numel(pIdxs);
			interArrs = (sensorPulses(2:end,2)-sensorPulses(1:end-1,2))*86400;
			interRates = 1 ./ interArrs;
			hold on
			stem(sensorPulses(2:end,2),interRates,'LineStyle','none')
			plot(sensorPulses(:,2),sensorPulses(:,8))
			plot(sensorPulses(:,2),sensorPulses(:,3))
			legnd{s} = sprintf('%06d',sensor);
			%set(gca,'XLim',[datenum('2016-12-10 17:00:00') datenum('2016-12-17 14:00:00')])
			set(gca,'YLim',[0.001 1000])
			set(gca,'XGrid','on')
			set(gca,'YGrid','on')
			ylabel('Instantaneous Pulse Rate (pulses per second)')
			xlabel('PulseDateTime')
			set(gca,'YScale','log')
			datetick('x',6)
			axPos = [ 0.075 0.075 0.9-0.025 0.9-0.025 ];
			outerPos = [ 400 500 1280 1024 ];
			title([ titl, ', ', sprintf( '%d pulses on sensor %s, ', numSensorPulses, legnd{s} ), datestr(pSet(1,2)), ' -to- ', datestr(pSet(end,2)) ])
			set(gcf, 'OuterPosition', outerPos )
			% default [0.1300 0.1100 0.7750 0.8150]
			set(gca, 'Position', axPos )
			set(gca, 'FontSize', 12 )
			set(gcf, 'PaperSize',[17 22])
			while 1
			    [x, y, button] = ginput(1);
			    switch button
			    case 1
			    	%print( gcf,'-djpeg100', [ 'InstRate.', legnd{s}, '.jpg' ] );
			    	saveas(gcf,[ 'InstRate.', legnd{s}, '.jpg' ] )
			    	savefig([ 'InstRate.', legnd{s}, '.fig' ])
			    	break
			    case 2
			    	return
			    case 3
			    	break
			    otherwise
			    end			        
			end			
	    	close('all')
		end
	otherwise
		disp('Unknown mumbo jumbo.')
end

set(gcf, 'OuterPosition', outerPos )
% default [0.1300 0.1100 0.7750 0.8150]
set(gca, 'Position', axPos )
set(gca, 'FontSize', 12 )
