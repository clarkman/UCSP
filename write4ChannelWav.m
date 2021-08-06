function write4ChannelWav( fName )

tdObjs = readData( fName, 24000, 4, now );

numRows = length(tdObjs{1});
outArray = zeros(numRows,4);

for ch = 1 : 4
  tdObj = tdObjs{ch};
  outArray(:,ch) = tdObj.samples;
end

outArray = outArray ./ 10;

audiowrite([ fName '.wav'],outArray,24000);