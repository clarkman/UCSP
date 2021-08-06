function plotGPSDiffs( diffs, titl )

figure

colrs = get(gca,'ColorOrder')

% First clip
% sz = size(diffs);
% for r = 1 : sz(1)
% 	if diffs(r,3) > 10
% 		diffs(r,3) = 10;
% 	end
% end
%Then Map


plot(diffs(:,1),diffs(:,2)*1000+0.01);

set(gcf, 'OuterPosition', [ 400 500 1280 1024 ] )

set(gca,'YScale','log');
datetick('x',6);
set(gca,'YGrid','on');

set(gca,'XLim', [diffs(1,1) diffs(end,1)] )

xlabel('date in 2015');
ylabel('diff from prior - meters');

lbls = get(gca,'YTickLabels');
lbls{1} = '0';
set(gca,'YTickLabels',lbls);

title(titl);
