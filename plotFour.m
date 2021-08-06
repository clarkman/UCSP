function plotFour( tdObjs, chans, lj, fRoot )

sz = size( tdObjs );
numTimeDataObjects = sz(2);
sz = size( chans );
numChannels = sz(2);

if numTimeDataObjects ~= numChannels
  error('Whacko!')
end

width = 500;

figure;
spread = -0.1;
left = 100 + (lj-1) * width*1.1;
for td = 1 : numTimeDataObjects
  tdObj = removeDC( tdObjs{td} );
  %tdObj = tdObjs{td};
  hold on;
  tVec = timeVector(tdObj);
  plot( tVec, tdObj.samples + (td-1)*spread )
  set(gcf, 'OuterPosition', [ left 500 width 500 ] )
end

title( fRoot )
legend(chans)
datetick('x','SS')
set( gca, 'XLim', [tVec(1), tVec(end)] )
xlabel('secs');
ylabel('Volts');
set(gca,'XGrid','on')
set(gca,'YGrid','on')
print( gcf,'-djpeg100', [ fRoot, '.ts.jpg' ] );

hold off
