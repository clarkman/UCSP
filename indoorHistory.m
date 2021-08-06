function indoorHistory( arr )
% 
% This query ....
% SELECT [IncidentID]
%       ,[TriggerTime]
%       ,[IncidentType]
%       ,[Confidence]
%       ,[NumShots]
%       ,[NumImpulses]
%   FROM [AtlantaGASCAD].[dbo].[Incident] order by TriggerTime desc
%
% Followed by:
% [ lbls, strs ] = readLabeledCSV( 'SCAD2018.csv' );
% [lbls, arr] = pluckArray( lbls, strs, [1 2 3 4 5 6], {'%d','dn','%s','%g','%d','%d'} )
%
% lbls =
%
%   6×1 cell array
%
%     'ï»¿IncidentID'
%     'TriggerTime'
%     'IncidentType'
%     'Confidence'
%     'NumShots'
%     'NumImpulses'

numIncidents = numel(arr{1});

inc = arr{1};
time = arr{2};
typo = arr{3};
conf = arr{4};

numNoise = 0;
numOther = 0;
numGun = 0;
numTest = 0;

gun = zeros(numIncidents,2);
noise = gun;
testr = gun;
other = gun;
for ith = 1 : numIncidents-1
	v = typo(ith);
	if strcmp(v,'IndoorGunfire') || strcmp(v,'AnticipatedGunshot')
		inc(ith)
		v
		numGun = numGun +1;
		gun(numGun,:) = [ time(ith), conf(ith) ];
	elseif  strcmp(v,'IndoorNoise') || strcmp(v,'Construction')
		numNoise = numNoise +1;
		noise(numNoise,:) = [ time(ith), conf(ith) ];
		colr = [1,0,0];
	elseif  strcmp(v,'SystemTest')
		numTest = numTest +1;
		testr(numTest,:) = [ time(ith), conf(ith) ];
		colr = [0,0,1];
	elseif  strcmp(v,'Other')
		numOther = numOther +1;
		other(numOther,:) = [ time(ith), conf(ith) ];
		colr = [0,0,0];
	else
		error('Bogus')
	end
end

gun = gun(1:numGun,:);
noise = noise(1:numNoise,:);
testr = testr(1:numTest,:);
other = other(1:numOther,:);

stem( gun(:,1), gun(:,2), 'Color', [1,0,0] );
hold on
stem( noise(:,1), noise(:,2), 'Color', [0,0.5,0], 'LineStyle','none' );
stem( testr(:,1), testr(:,2), 'Color', [0,0,1], 'LineStyle','none' );
stem( other(:,1), other(:,2), 'Color', [0,0,0], 'LineStyle','none' );
datetick('x','mm/yy')
set(gca, 'XLim', [datenum('2016/10/16') now])
legend({'IndoorGunfire/AnticipatedGunshot','IndoorNoise/Construction','SystemTest','Other'})

