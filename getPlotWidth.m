function [begT, finT, lenT] = getPlotWidth()

aa = get(gca,'XLim');

begT = aa(1);
finT = aa(2);
lenT = finT - begT;

