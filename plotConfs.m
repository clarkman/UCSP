function plotConfs( arr, titl )

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
epso = 60/86400;
stepr = 20/86400;
iter = 4/86400;
kth = 0;
line([min(dns)-epso max(dns)+epso],[0 0],'Color','k','LineStyle',':')

colr = [0 1 0];
lastDN = dns(1);
for r = 1 : numRows
	if strcmp( arr{r,2}, 'IndoorGunfire' )
		colr = [0 0.618 0];
	else
		colr = [0.618 0 0];
	end
	if abs(dns(r)-lastDN) > stepr % Jittermaker
		kth = 0;
		lastDN = dns(r);
	else
		kth = kth+1;
	end
	line( [dns(r) dns(r)]+kth*iter, [-1.0*ranges(r) confs(r)], 'Color', colr, 'Marker','o')
end
datetick('x',15)
set(gca,'XLim',[min(dns)-epso max(dns)+epso])
set(gcf, 'OuterPosition', [ 400 500 1280 1024 ] )
xlabel('time')
ylabel('   range-ft                                                                                                               confidence')

lbls = get(gca,'YTickLabel');
lbls{1}='100';
lbls{2}='80';
lbls{3}='60';
lbls{4}='40';
lbls{5}='20';
%set(gca,'YTickLabel',lbls);

set(gca,'YGrid','on');
title( titl );

