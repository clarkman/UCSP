function plotMeanAzHisto( pp )

h1=hist( pp(:,7), 360 );
h2=hist( pp(:,8), 360 );
h3=hist( pp(:,9), 360 );

for ith = 1 : 360
    line( [0 cosd(ith)]*h1(ith), [0 sind(ith)]*h1(ith), 'Marker', 'o' )
end
