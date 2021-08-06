function plotAudioIRArrivalTime( m, testStrs, gunStrs, ammoStrs, xducerStrs )


colrs = zeros( 4, 3 );
colrs(1,:) = [ 0.5, 0.5, 0.5 ];
colrs(2,:) = [ 0.618, 0, 0 ];
colrs(3,:) = [ 0, 0.618, 0 ];
colrs(4,:) = [ 0, 0, 0.618 ];

xducerSet = 2
folder = 'ir-audio';


outFolder = [ 'plots/', folder ];
system( [ 'mkdir -p ', outFolder ] )

k = find( m(:,7) == xducerSet );

numFound = numel(k)

display( sprintf( 'Plotting infrared-audio signals of %d data sets.', numFound ) )

for r = 1 : numFound
  tdObjs = loadRow( k(r), m, testStrs, gunStrs, ammoStrs, xducerStrs );
  fName = makeRawName( m(k(r),:), testStrs, gunStrs, ammoStrs, xducerStrs );
  for td = 1 : numel(tdObjs)
    tdObj=zeroCenter(tdObjs{td});
    sampPeriod = 1/tdObj.sampleRate;
    xAx = sampPeriod/2 : sampPeriod : (tdObj.sampleCount) * sampPeriod;
    plot(xAx,tdObj.samples+td/4, 'Color', colrs(td,:))
    hold on;
  end
  legend({ getXducerStr(xducerStrs,m(k(r),8)), getXducerStr(xducerStrs,m(k(r),9)), getXducerStr(xducerStrs,m(k(r),10)), getXducerStr(xducerStrs,m(k(r),11)) })
  title( [ mfilename, '  ', fName, '  ', folder, '  ', datestr(tdObj.UTCref) ] );
  xlabel('secs')
  ylabel('Volts')
  print( gcf,'-djpeg100', [ outFolder, '/', fName, '-', folder, '.jpg' ] );
  while 1
    keydown = waitforbuttonpress;
    if ( keydown == 0 )
     % disp('Mouse button was pressed');
    else
      break;
    end
  end
  print( gcf,'-djpeg100', [ outFolder, '/', fName, '-', folder, '.zoomed.jpg' ] );
  close('all');
  %return
end