function tdObjs = loadRow( row, m, testStrs, gunStrs, ammoStrs, xducerStrs )

mRow = m(row,:);

sampleRate = 24000;

fName = makeRawName( mRow, testStrs, gunStrs, ammoStrs, xducerStrs );

tdObjsTmp = readData( fName, sampleRate, mRow(3) );

for obj = 1 : numel(tdObjsTmp)
  td = tdObjsTmp{obj};
  td.channel = getXducerStr(xducerStrs,mRow(6+obj));
  td.UTCref = mRow(12);
  td.sampleRate = sampleRate;
  tdObjs{obj} = td;
end