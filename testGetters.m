function testGetters()

testStrs = loadTestStrs();
numTestCodes = getTestCode(testStrs);
for tc = 1 : numTestCodes
  getTestCode(testStrs,getTestStr(testStrs,tc));
end

gunStrs = loadGunStrs();
numGunCodes = getGunCode(gunStrs);
for gc = 1 : numGunCodes
  getGunCode(gunStrs,getGunStr(gunStrs,gc));
end

ammoStrs = loadAmmoStrs();
numAmmoCodes = getAmmoCode(ammoStrs);
for ac = 1 : numAmmoCodes
  getAmmoCode(ammoStrs,getAmmoStr(ammoStrs,ac));
end

xducerStrs = getChannelCodes();
numXducerCodes = getXducerCode(xducerStrs);
for xc = 1 : numXducerCodes
  getXducerCode(xducerStrs,getXducerStr(xducerStrs,xc));
end

