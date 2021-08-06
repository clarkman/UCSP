function arr = plotStrength( m, testStrs, gunStrs, ammoStrs, xducerStrs, labjackStrs, test, caliber, ammo, xducer )

testCode = getTestCode(testStrs,test);
gunCode = getGunCode(gunStrs,caliber);
ammoCode = getAmmoCode(ammoStrs,ammo);
xducerCode = getXducerCode(xducerStrs,xducer);

m = extractRows( m, find( m(:,1) == testCode ) );
m = extractRows( m, find( m(:,5) == gunCode ) );
m = extractRows( m, find( m(:,6) == ammoCode ) );
m = extractRows( m, find( m(:,8) == xducerCode | m(:,9) == xducerCode | m(:,10) == xducerCode | m(:,11) == xducerCode ) );

sz = size(m);
strengths = zeros(sz(1),1);

m = sortrows( m, 4 );
peaks = loadSignalPeaks( m, testStrs, gunStrs, ammoStrs, xducerStrs, labjackStrs, xducerCode );



plot( m(:,4), peaks )