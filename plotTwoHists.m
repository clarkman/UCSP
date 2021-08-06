function plotTwoHists( h1, h1Norm, h2, h2Norm )
	
	h1Min = datenum('2018-05-01 00:00:00');
	h2Min = h1Min;
	h1Max = datenum('2018-04-01 00:00:00');
	h2Max = h1Max;

	if(isempty(h1)||isempty(h2))
		return
	end

	h1Min = min(h1)
	h1Max = max(h1)
	h2Min = min(h2)
	h2Max = max(h2)

	plotMin = min( h1Min, h2Min )
	plotMax = min( h1Max, h2Max )

	hrs = 1/24;

	% Count number of hourly bins & alloc
	pT = plotMin;
	numBins = 0;
	while pT < plotMax
		numBins = numBins + 1;
		pT = pT + hrs;
	end
	binTs = zeros( numBins, 3 );

	% Count occurence per hour
	pT = plotMin;
	numBins = 0;
	while pT < plotMax
		begT = pT;
		finT = pT + hrs;
		numBins = numBins + 1;
		binTs( numBins, 1 ) = ( begT + finT ) / 2;
		indsH1 = find( h1 >= begT & h1 < finT  );
		binTs( numBins, 2 ) = numel(indsH1);
		indsH2 = find( h2 >= begT & h2 < finT  );
		binTs( numBins, 3 ) = numel(indsH2);
		pT = finT;
	end

	% Normalize to per sensor
	binTs( :, 2 ) = binTs( :, 2 ) ./ h1Norm;
	binTs( :, 3 ) = binTs( :, 3 ) ./ h2Norm;

	stem(binTs(:,1),binTs(:,2))
	hold on;
	stem(binTs(:,1),binTs(:,3))
	set(gca,'YScale','log')
	set(gca,'YGrid','on')
	datetick('x','dd HH')
	set(gca,'XLim',[plotMin,plotMax])
	set(gca,'YLim',[100,10000])
	legend({'Hyperion','Scepter'})
	title('Pulse Counts for HYP/SCP pairs.')
	ylabel('pulse counts')
	xlabel('2018-04-day hr')


