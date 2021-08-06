function tdOut = plotChop(tdIn)

aa=get(gca,'XLim');

tdOut = slice( tdIn, floor(aa(1)*tdIn.sampleRate), ceil(aa(2)*tdIn.sampleRate) );