function fName = makeRawName2( row, testStrs, gunStrs, ammoStrs, xducerStrs, labJackStrs, fRoot )

dStr = datestr(row(12),'yyyy-mm-dd-HH-MM-SS');
lJ = getLabjackStr(labJackStrs,row(13));
if floor(row(4)) == row(4)
  range = sprintf('%d',row(4));
else
  range = sprintf('%0.1f',row(4));
end

fName = [ getTestStr(testStrs,row(1)), sprintf('%d-%d-',row(2),row(3)), getGunStr(gunStrs,row(5)), '-', getAmmoStr(ammoStrs,row(6)), '-', dStr, '-', range, '-',  lJ ];

if nargin > 6
  fName = [ fRoot '/', fName ];
end
