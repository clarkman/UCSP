function rr = plotIrResponse( m, testStrs, gunStrs, ammoStrs, xducerStrs, labjackStrs )

% Note how column is the same for all sensors physically the same ...
% xducersHi = { '3mm-InGaaS-Hi-Gain', '1mm-InGaaS-Hi-Gain', 'PbS-Hi-Gain', 'Si-Hi-Gain', 'Thor-PbSe', 'Thor-Si' };
% xducersAudio = { '3mm-InGaaS-Hi-Gain', '1mm-InGaaS-Hi-Gain', 'PbS-Hi-Gain' };
% xducersLo = { '3mm-InGaaS-Lo-Gain', '1mm-InGaaS-Lo-Gain', 'PbS-Lo-Gain', 'Si-Lo-Gain' };
% xducersAccel = { '3mm-InGaaS-Hi-Gain' };
% xducersHi = 1;
% xducersAudio = 2;
% xducersLo = 3;
%xducersAccel = 4;

%sets = loadXducerSets( { '2016-02-11', '2016-02-18' } );

% Date filter
divDn = datenum('2016-02-29 00:00:00');
m = extractRows( m, find( m(:,12) > divDn ) );

% Labjack filter
chosenLabjack = 'b';
% ljCode = getLabjackCode(labjackStrs,chosenLabjack);
% m = extractRows( m, find( m(:,13) == ljCode ) );

% Create sensor lookup tables
xducerSets = buildXducerIndices( m );


% Those of interest ...
irSet = [ getXducerCode(xducerStrs,'3mm-InGaaS-Hi-Gain'), ...
          getXducerCode(xducerStrs,'1mm-InGaaS-Hi-Gain'), ...
          getXducerCode(xducerStrs,'Si-Hi-Gain'), ...
          getXducerCode(xducerStrs,'PbS-Lo-Gain'), ...
          getXducerCode(xducerStrs,'Thor-PbSe'), ...
          getXducerCode(xducerStrs,'Thor-Si' ) ];

audioSet = [ getXducerCode(xducerStrs,'Knowles-Lo' ) ];

accelSet = [ getXducerCode(xducerStrs,'Accel-X'), ...
             getXducerCode(xducerStrs,'Accel-Y'), ...
             getXducerCode(xducerStrs,'Accel-Z') ];

% Prepare for output
folder = 'ir-response';
outFolder = [ 'plots/', folder ];
system( [ 'mkdir -p ', outFolder ] );

typer = 2;
switch typer
  case 1
    xducerSelect = irSet;
    plotCol = 8;
    analysisTitle = 'snr-noise-peak'
    yAxLbl = 'SNR dB (over peak noise)'
    %plotCol = 8;
    ruleHt = 0;
  case 2
    xducerSelect = irSet;
    plotCol = 9;
    analysisTitle = 'snr-noise-rms'
    yAxLbl = 'SNR dB (over rms noise)'
    %plotCol = 9;
    ruleHt = 0;
  % case 3
  %   analysisTitle = 'peak'
  %   yAxLbl = 'Signal Peak - Volts'
  %   plotCol = 2;
  %   ruleHt = 4.05;
  case 4
    xducerSelect = irSet;
    analysisTitle = 'peak'
    yAxLbl = 'Signal Peak - Volts'
    plotCol = 2;
    ruleHt = 4.05;
  case 5
    analysisTitle = 'noise-peak'
    yAxLbl = 'Noise Peak - Volts'
    plotCol = 6;
    ruleHt = 4.05;
  case 6
    xducerSelect = irSet;
    analysisTitle = 'noise-rms'
    yAxLbl = 'Noise RMS - Volts'
    plotCol = 6;
    ruleHt = 4.05;
  case 7
    analysisTitle = 'duration-secs'
    yAxLbl = 'Seconds duration'
    plotCol = 3;
    ruleHt = 4.05;
  case 8
    analysisTitle = 'onset-secs'
    yAxLbl = 'Seconds onset'
    plotCol = 4;
    ruleHt = 4.05;
  case 9
    analysisTitle = 'decay-secs'
    yAxLbl = 'Seconds decay'
    plotCol = 5;
    ruleHt = 4.05;
  case 10
    analysisTitle = 'range-snr'
    xducerSelect = irSet;
    yAxLbl = 'meters'
    plotCol = 2;
    ruleHt = 4.05;
    chosenLabjack = 'all';
  otherwise
    error('Unknown method.')
end

numXducerSelections = length( xducerSelect );

for st = 1 : numXducerSelections

  inds = xducerSets{xducerSelect(st)};

  results = buildSignalMatrix2( inds, m, testStrs, gunStrs, ammoStrs, xducerStrs, labjackStrs, st );
  rr{st} = results;

  if isempty(results)
    continue
  end

  numTypesAmmo = unique(results(:,11));
  numTraces = 0;
  colrs = get(gca,'ColorOrder');

  for ammo = 1 : 5
    thisAmmo = find( results(:,11) == ammo );
    numel(thisAmmo)
    if numel(thisAmmo) == 0
      warning( [ 'Skipping: ' ])
      continue
    end
    thisSet = extractRows(results,thisAmmo);
    if typer < 1
      plot( thisSet(:,10), thisSet(:,plotCol), 'LineStyle', 'none', 'Marker', 'o' );
    elseif typer < 10
      filtrInds = find( thisSet(:,12) == 1 );
      noFiltrInds = find( thisSet(:,12) == 3 );
      fltrSet = extractRows(thisSet,filtrInds);
      noFltrSet = extractRows(thisSet,noFiltrInds);
      cIdx = get(gca,'ColorOrderIndex');
      if( numel(filtrInds) > 0 && numel(noFiltrInds) > 0 ) 
        sprdr = makeSpreader( filtrInds, 0.5 );
        plot( fltrSet(:,10)+sprdr, fltrSet(:,plotCol), 'LineStyle', 'none', 'Marker', 'o' );
        numTraces = numTraces + 1;
        lgnd{numTraces} = [ getAmmoStr(ammoStrs,ammo) '-filtered' ];
        sprdr = makeSpreader( noFiltrInds, 0.5 );
        line( noFltrSet(:,10)+sprdr, noFltrSet(:,plotCol), 'LineStyle', 'none', 'Marker', 'x', 'Color', colrs(cIdx,:) );
        numTraces = numTraces + 1;
        lgnd{numTraces} = [ getAmmoStr(ammoStrs,ammo) '-no filter' ];
      elseif( numel(noFiltrInds) > 0 )
        sprdr = makeSpreader( noFiltrInds, 0.5 );
        plot( noFltrSet(:,10)+sprdr, noFltrSet(:,plotCol), 'LineStyle', 'none', 'Marker', 'o' );
        numTraces = numTraces + 1;
        lgnd{numTraces} = [ getAmmoStr(ammoStrs,ammo) '-no filter' ];
      elseif( numel(filtrInds) > 0 )
        sprdr = makeSpreader( filtrInds, 0.5 );
        plot( fltrSet(:,10)+sprdr, fltrSet(:,plotCol), 'LineStyle', 'none', 'Marker', 'o' );
        numTraces = numTraces + 1;
        lgnd{numTraces} = [ getAmmoStr(ammoStrs,ammo) '-filtered' ];
      end
      % if typer < 3
      %   find        
      %   text( fltrSet(:,10), 0.6, sprintf('total=%d\n'))
      % end
    else
        filtrInds = find( thisSet(:,12) == 1 );
        noFiltrInds = find( thisSet(:,12) == 3 );
        fltrSet = extractRows(thisSet,filtrInds);
        noFltrSet = extractRows(thisSet,noFiltrInds);
        cIdx = get(gca,'ColorOrderIndex');
        plot( fltrSet(:,14), fltrSet(:,plotCol), 'LineStyle', 'none', 'Marker', 'o' );
        numTraces = numTraces + 1;
        lgnd{numTraces} = [ getAmmoStr(ammoStrs,ammo) '-filtered' ];
        if numel(noFiltrInds) > 0
          line( noFltrSet(:,14), noFltrSet(:,plotCol), 'LineStyle', 'none', 'Marker', 'x', 'Color', colrs(cIdx,:) );
          numTraces = numTraces + 1;
          lgnd{numTraces} = [ getAmmoStr(ammoStrs,ammo) '-no filter' ];
        end
    end
      
    hold on;
  end
  xlbls = { '', getGunStr(gunStrs,1), ...
                getGunStr(gunStrs,2), ...
                getGunStr(gunStrs,3), ...
                getGunStr(gunStrs,4), ...
                getGunStr(gunStrs,5), ...
                getGunStr(gunStrs,6), ...
                getGunStr(gunStrs,7), ...
                getGunStr(gunStrs,8), ...
                getGunStr(gunStrs,9) };
  if typer < 3
    lgnd{numTraces+1} = 'SNR = 1';
  else
    lgnd{numTraces+1} = 'Voltage rail';
  end
  legend( lgnd, 'Location', 'EastOutside' )
  xducerName = getXducerStr( xducerStrs, xducerSelect(st) );
  title( [ analysisTitle, ' of ', xducerName '/', chosenLabjack ] )
  set( gca, 'XGrid', 'on' )
  set( gca, 'YGrid', 'on' )
  if typer < 10
    set( gca, 'XLim', [0 10] );
    line(get(gca,'XLim'),[ruleHt ruleHt], 'Color', [1 0 0])
    set( gca, 'XTick', [0:10] );
    set( gca, 'XTickLabel', xlbls );
  end
  % if typer < 3
  %   set( gca, 'YLim', [0.8 1000])
  % end
  if typer > 2    
    set( gca, 'YScale', 'log')
  end
  if typer > 4 && typer < 7
    set( gca, 'YLim', [0.01 10])
    %set( gca, 'YLim', [0.0005 10])
  end    
  if typer == 7 || typer == 9
    set( gca, 'YLim', [0.00002 0.002]) % duration
  end    
  if typer == 8
    set( gca, 'YLim', [0.00001 0.001]) % onset
  end    
  if typer == 4
    set( gca, 'YLim', [0.01 10]) % onset
  end    
  if typer < 3
    set( gca, 'YLim', [-2 70])
    %set( gca, 'YTickLabel', { '1', '10', '100', '1000'})
  else    
    set( gca, 'YScale', 'log')
  end
  xlabel('weapon')
  ylabel( yAxLbl )
  fNameRoot = [ outFolder, '/', xducerName, '-', folder, '-', chosenLabjack, '-', analysisTitle ]
  print( gcf,'-djpeg100', [ fNameRoot '.jpg' ] );
  %saveas( gcf, fNameRoot, 'fig');

end

