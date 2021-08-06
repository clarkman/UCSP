function [ output_args ] = plotCasellaStrength( arr )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sz = size(arr);
numRows = sz(1);
numCols = sz(2);

celArray = zeros(numRows,2);
%celStrs = cell(numRows);
found = 0;
for r = 1 : numRows
    if arr{r,5} > 0
        found = found + 1;
        celArray(found,1) = arr{r,8};
        celArray(found,2) = arr{r,5};
        celStrs{found} = sprintf( '%s %s', arr{r,12}, arr{r,13} );
    end
end
celArray = celArray(1:found,:);

guns = unique(celStrs);
numGuns = length(guns);
figure;
colrs = get(gca,'ColorOrder');
for g = 1 : numGuns
    gun = guns(g);
    strengths = zeros(found,1);
    gunth = 0;
    for n = 1 : found
        if strcmp( gun, celStrs{n} )
            gunth = gunth + 1;
            strengths(gunth) = celArray(n,2);
        end
    end
    strengths = strengths(1:gunth);
    f(g) = polyfit([1:gunth]',strengths,0)
    hold on;
        plot(strengths,'LineStyle',':','LineWidth',2,'Marker','o', 'MarkerSize',7);
    hold off;
end
ylabel('dB SPL')
xlabel('Total Number of shots')
legend(guns, 'Location', 'southeast')
for g = 1 : numGuns
    avdB = f(g);
    colr = colrs(g,:)
    line(get(gca,'XLim'),[avdB avdB],'Color',colr,'LineStyle',':')
    text(0.2,avdB,sprintf('%0.1f',avdB),'Color',colr,'BackgroundColor',[1 1 1])
end
line(get(gca,'XLim'),[169.5 169.5],'Color','k','LineStyle','--')
text(1,169.5,'Cassella saturation 169.5dB','BackgroundColor',[1 1 1])
set(gcf, 'OuterPosition', [ 400 500 1280 960 ] )
title('Strengths of rounds from NMHS 2016-10-17 & 2016-11-01 LFTs')

