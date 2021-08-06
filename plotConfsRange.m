function plotConfsRange( arr, titl )

sz = size(arr);
numRows = sz(1);

dns = extractNumeric(arr,1);
confs = extractNumeric(arr,3);

ranges = zeros(numRows,1);
for r = 1 : numRows
	if isempty(arr{r,4})
		ranges(r) = 0;
	else
		ranges(r) = arr{r,4};
	end
end


figure;
colr = [0 1 0];
lastDN = dns(1);
indoorGunfire = zeros(numRows,2);
numIndoorGunfire = 0;
indoorNoise = zeros(numRows,2);
numIndoorNoise = 0;
for r = 1 : numRows
	if strcmp( arr{r,2}, 'IndoorGunfire' )
		numIndoorGunfire = numIndoorGunfire + 1;
		indoorGunfire(numIndoorGunfire,1) = ranges(r);
		indoorGunfire(numIndoorGunfire,2) = confs(r);
	else
		numIndoorNoise = numIndoorNoise + 1;
		indoorNoise(numIndoorNoise,1) = ranges(r);
		indoorNoise(numIndoorNoise,2) = confs(r);
	end
end
indoorGunfire = indoorGunfire(1:numIndoorGunfire,:);
indoorNoise = indoorNoise(1:numIndoorNoise,:);

plot( indoorGunfire(:,1), indoorGunfire(:,2), 'Color', [0 0.618 0], 'Marker', 'o', 'LineStyle', 'none' )
hold on;
plot( indoorNoise(:,1), indoorNoise(:,2), 'Color', [0.618 0 0], 'Marker', 'o', 'LineStyle', 'none' )

legend({'Indoor Gunfire', 'Indoor Noise'})

set(gca,'XGrid','on');
set(gca,'YGrid','on');

set(gcf, 'OuterPosition', [ 400 500 1280 1024 ] )
xlabel('range-ft')
ylabel('confidence')


title( titl );

