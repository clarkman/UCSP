function dumpPlotTimes()

aa=get(gca,'XLim');

begStr = std2sqlDate(datenum2str(aa(1))); begStr = begStr(1:end-3);
finStr = std2sqlDate(datenum2str(aa(2))); finStr = finStr(1:end-3);

display( sprintf( '%s, %s', begStr, finStr ) );