function plotFour2( m, ind )

testStrs = loadTestStrs();
gunStrs = loadGunStrs();
ammoStrs = loadAmmoStrs();
xducerStrs = getChannelCodes();
%xducerSets = loadXducerSets();
%xducerSets = loadXducerSets( { '2016-02-11', '2016-02-18' } );
labjackStrs = loadLabjackStrs();

tdObjs = loadRow2( ind, m, testStrs, gunStrs, ammoStrs, xducerStrs, labjackStrs )

colrs = zeros(4,3)
colrs(1,:) = [ 0.2, 0.6, 0.5 ]
colrs(2,:) = [ 0.8, 0.3, 0.0 ]
colrs(3,:) = [ 0.2, 0.0, 1.0 ]
colrs(4,:) = [ 0.2, 0.7, 0.3 ]

spread=-0.1;
for ch = 1 : 4
% hold on;
%   tdObj=tdObjs{ch};
  % tVec = timeVector(tdObj);
  % st=tVec(1);
  % tVec=(tVec-st)/86400;
  % tVec = tVec + st;
  %plot( tVec, tdObj.samples+(ch-1)*spread, 'Color', colrs(ch,:) );
%  plot( tdObj+(ch-1)*spread );
  legr{ch} = getXducerStr(xducerStrs,m(ind,ch+7))
end

td1=tdObjs{1};
td2=tdObjs{2};
td3=tdObjs{3};
td4=tdObjs{4};

figure;
plot2( td1+spread, td2+2*spread, td3+3*spread, td4+4*spread )

set(gcf, 'OuterPosition', [ 400 500 1200 900 ] )
%set(gca,'YLim',[-1,1])
title(sprintf('Test=%d, Gun=%s, Ammo=%s, Range=%g, Labjack=%s', m(ind,2), getGunStr(gunStrs,m(ind,5)), getAmmoStr(ammoStrs,m(ind,6)), m(ind,4), getLabjackStr(labjackStrs,m(ind,13)) ))

%set( gca, 'XLim', [ min(tVec), max(tVec) ] )
zoomAdaptiveDateTicks('on')
legend(legr)
