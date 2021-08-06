function [ output_args ] = plotRangeAngle( arr )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sz = size(arr);
numRows = sz(1);
numCols = sz(2);

rangeArray = zeros(numRows,2);
found = 0;
for r = 1 : numRows
    if arr{r,11} > 0
        found = found + 1;
        rangeArray(found,1) = arr{r,9};
        rangeArray(found,2) = arr{r,10};
        celStrs{found} = sprintf( '%s %s', arr{r,12}, arr{r,13} );
    end
end
rangeArray = rangeArray(1:found,:);
figure;
plot(rangeArray(:,1),rangeArray(:,2),'LineStyle','None','LineWidth',2,'Marker','o', 'MarkerSize',7);

% guns = unique(celStrs);
% numGuns = length(guns);
% figure;
% colrs = get(gca,'ColorOrder');
% for g = 1 : numGuns
%     gun = guns(g)
%     vals = zeros(found,2);
%     gunth = 0;
%     for n = 1 : found
%         if strcmp( gun, celStrs{n} )
%             gunth = gunth + 1;
%             vals(gunth,1) = rangeArray(n,1);
%             vals(gunth,2) = rangeArray(n,2);
%         end
%     end
%     lgnd{g} = sprintf( '%s, %d, shots', gun{1}, gunth)
%     vals = vals(1:gunth,:);
%     hold on;
%         plot(vals(:,1),vals(:,2),'LineStyle','None','LineWidth',2,'Marker','o', 'MarkerSize',7);
%     hold off;
% end
ylabel('Off-axis angle')
xlabel('Range (ft)')
%legend(guns, 'Location', 'southeast')
set(gcf, 'OuterPosition', [ 400 500 1280 960 ] )
title('Geometry of firing points vs. sensors, NMHS LFTS: 2016-10-17 & 2016-11-01')

