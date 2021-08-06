function fName = makeRawName( row, testStrs, gunStrs, ammoStrs, xducerStrs, fRoot )

fName = [ getTestStr(testStrs,row(1)), sprintf('%d-%d-%d-',row(2),row(3),row(4)), getGunStr(gunStrs,row(5)), '-', getAmmoStr(ammoStrs,row(6)) ];

if nargin > 5
  fName = [ fRoot '/', fName ];
end