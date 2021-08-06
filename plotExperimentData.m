function plotExperimentData( exps, sens, beg, fin, Fs )

outBaseDir = '/Volumes/Funkotron2/SST/Artemis/NewarkHSLiveFire2/Analysis/casDir/'

srcKey = makeSrcKey;
fpKey = makeFpKey;

% All ...
% figure;
% plot(ar2(:,14),ar2(:,11),'Marker','o','LineStyle','none')
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'All Casella measurements')

voltsCorr = sqrt(2);

casellas=find( exps(:,11) > 0 );
numCasellas = numel(casellas);
display(sprintf('A total of %d Casella Measurements made',numCasellas))
casExps = extractRows( exps, casellas );

casIdxs = unique(casExps(:,13));



numCasIdxs = numel(casIdxs);
display(sprintf('Plotting %d Casella experiments',numCasIdxs))


if nargin > 2
  tub = find( casIdxs == beg );
  interactive = 1;
  lo = tub;
  hi = tub;
else
  interactive = 0;
  lo = 1;
  hi = numCasIdxs;
end

for c = 198 : hi
%for c = 157 : hi

  casIdx = casIdxs(c)
  %return
  outputDir = [ outBaseDir, sprintf('exp%03d/',casIdx) ];
  system( [ 'mkdir -p ', outputDir ] );

  cInds = find( exps(:,13) == casIdx & exps(:,3) ~= -9999 );
  numSensors = numel(cInds)
  if ~numSensors
    display(sprintf('No sensor data for Casella index = %d',c))
    continue;
  end

  display(sprintf('Loading sensor data for Casella index = %d',c))

  cExps = extractRows(exps,cInds);
 % cExps = sortrows( cExps, 4 );
  accel = zeros(numSensors,1);
  Fs = zeros(numSensors,2);

  for ex = 1 : numSensors

    sensorNumber = cExps(ex,4);
    loadSuccess = 1;
    if sensorNumber > 9000
      audioFs(ex) = 48000;
      %sensorName = 'knowles'
      [ data, fNames ] = loadAudioData( cExps, ex, sens );
    elseif sensorNumber > 500
      Fs(ex,1) = 24000;
      accel(ex) = 1;
      Fs(ex,2) = 5000;
      %sensorName = 'revA'
      try 
        [ data, fNames ] = loadData( cExps, ex, sens );
      catch
        loadSuccess = 0;
        display( sprintf('No data loaded for revA casIdx = %d, sensorID = %d', casIdx, sensorNumber(ex) ) );
      end
    else
      accel(ex) = 0;
      Fs(ex,1) = 24000;
      %sensorName = 'rev4'
      try 
        [ data, fNames ] = loadData( cExps, ex, sens );
      catch
        loadSuccess = 0;
        display( sprintf('No data loaded for rev4 casIdx = %d, sensorID = %d', casIdx, sensorNumber(ex) ) );
      end
    end

    if loadSuccess
      dataSet{ex} = data{1};
      if numel(data) > 1
        piezoSet{ex} = data{2};
      else
        piezoSet{ex} = [];
      end
      if numel(data) == 3
        accelSet{ex} = data{3};
      else
        accelSet{ex} = [];
      end
    end

  end

  try % Any data loaded?
    a = dataSet;
  catch
    display(sprintf('No data found for %d',casIdx))
    continue; % Guess not!
  end


  plotHeight = numSensors * 2;
  plotTicks = 0 : 1 : 2 * numSensors;
  plotTickLbls = { '1', '0' };
  plotOffs = ( 2 * numSensors : -2 : 2 ) - 1;
  %plotOffs = ( 3 : 3 : 3 * numSensors ) - 1.5

 
  FFTL = 2048;
  ovrlp = 1-1/32;
  for ex = 1 : numSensors

    data = dataSet{ex};
    audio = TimeData;
    hold on;
    sensorNumber = cExps(ex,4);
    if sensorNumber > 9000
      sensorName = 'Knowles';
      display('Decimating Knowles by 2x')
      data = decimate( data, 2 );
      data = data(1:end-1);
      display('Decimated Knowles by 2x')
    elseif sensorNumber > 500
      sensorName = 'revA';
    else
      sensorName = 'rev4';
    end
    audio.sampleRate = 24000;
    % Noise
    audio.samples = data;
%    plot(log10(sgramPhase(audio,FFTL,ovrlp)));
    plot(log10(spectrogram(audio,FFTL,ovrlp)));
    setPlotSize();
    xlabel('Secs');
    ylabel('Hz');
    title( sprintf('Spectrogram of microphone %d for casIdx=%d experiments %s,  src=%s,  FP=%s,  SPL=%gdB', sensorNumber, casIdx, datestr(cExps(ex,10)), srcKey(cExps(ex,12)).name, fpKey(cExps(ex,1)).name, cExps(ex,11) ) )
    %   dataSet{ex} = data{1};
    audioName = [ makeHexName(sensorNumber), '-' sprintf('%d',cExps(ex,5)), '-audio-sgram', '.jpg' ];
    orient portrait;
    print( gcf,'-djpeg100', '-noui', [ outputDir, audioName ] );
  end


  mults = [ 0.5, 1.0, 2.0, 4.0 ];
  for m = 1 : numel(mults)
    % PSD _________________________________________________________________
    if interactive
      figure;
    else
      figure('Visible','off');
    end
    mult=mults(m);
    FFTL = 512*mult;
    slic = 600*mult;
    noiseBase = 12000;
    signlBase = 24000;
    leg = {};
    numLoaded = 0;
    for ex = 1 : numSensors

      sensorNumber = cExps(ex,4);
      if sensorNumber > 9000
        continue;
        % sensorName = 'Knowles';
        % display('Decimating Knowles by 2x')
        % data = decimate( data, 2 );
        % data = data(1:end-1);
        display('Decimated Knowles by 2x');
      elseif sensorNumber > 500
        sensorName = 'revA';
      else
        sensorName = 'rev4';
      end
      numLoaded = numLoaded + 1;
      data = piezoSet{ex};
      piezo = TimeData;
      hold on;
      piezo.sampleRate = 24000;
      % Noise
      %[ data, offSec ] = slideAudio( data, 100, piezo.sampleRate );
      piezo.samples = data(noiseBase:noiseBase+slic);
      %piezo
      noisePSD  = sqrt( spectrum(piezo,FFTL,1) );
      frqs = freqVector(noisePSD);
      plot(frqs,noisePSD.samples,'Color',getColor(numLoaded,1));
      hold on;
      leg{2*numLoaded-1} = sprintf('%s / %04d noise', sensorName, sensorNumber );
      piezo.samples = data(signlBase:signlBase+slic);
      signlPSD  = sqrt( spectrum(piezo,FFTL,1) );
      plot(frqs,signlPSD.samples,'Color',getColor(numLoaded));
      leg{2*numLoaded} = sprintf('%s / %04d signal', sensorName, sensorNumber );
    end
    try
      a = piezo
    catch
      continue;
    end
    setPlotSize();
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    set(gca,'XGrid','on')
    set(gca,'YGrid','on')
    set(gca,'XLim',[signlPSD.freqResolution, piezo.sampleRate/2])
    xlabel('Hz');
    ylabel('amplitude/rootHz');
    leg
    legend(leg);
    title( sprintf('Spectra of piezos for casIdx=%d experiments %s,  src=%s,  FP=%s,  SPL=%gdB, FFT length = %d', casIdx, datestr(cExps(ex,10)), srcKey(cExps(ex,12)).name, fpKey(cExps(ex,1)).name, cExps(ex,11), FFTL ) )
    piezoName = [ makeHexName(sensorNumber), '-' sprintf('%d',cExps(ex,5)), '-piezo-spectra.', sprintf('%d',FFTL), '.jpg' ];
    print( gcf,'-djpeg100', '-noui', [ outputDir, piezoName ] );
    set(gca,'XScale','lin')
    set(gca,'YScale','lin')
    piezoName = [ makeHexName(sensorNumber), '-' sprintf('%d',cExps(ex,5)), '-piezo-spectra.lin.', sprintf('%d',FFTL), '.jpg' ];
    print( gcf,'-djpeg100', '-noui', [ outputDir, piezoName ] );
    close('all')
  end

  FFTL = 2048;
  ovrlp = 1-1/32;
  for ex = 1 : numSensors

    %hold on;
    sensorNumber = cExps(ex,4);
    if sensorNumber > 9000
      continue
    elseif sensorNumber > 500
      sensorName = 'revA';
    else
      sensorName = 'rev4';
    end
    data = piezoSet{ex};
    if isempty(data)
      continue
    end
    piezo = TimeData;
    piezo.sampleRate = 24000;
    % Noise
    piezo.samples = data;
%    plot(log10(sgramPhase(audio,FFTL,ovrlp)));
    plot(log10(spectrogram(piezo,FFTL,ovrlp)));
    setPlotSize();
    xlabel('Secs');
    ylabel('Hz');
    title( sprintf('Spectrogram of piezo %d for casIdx=%d experiments %s, src=%s,  FP=%s,  SPL=%gdB', sensorNumber, casIdx, datestr(cExps(ex,10)), srcKey(cExps(ex,12)).name, fpKey(cExps(ex,1)).name, cExps(ex,11) ) )
    %   dataSet{ex} = data{1};
    audioName = [ makeHexName(sensorNumber), '-' sprintf('%d',cExps(ex,5)), '-piezo-sgram', '.jpg' ];
    orient portrait;
    print( gcf,'-djpeg100', '-noui', [ outputDir, audioName ] );
    close('all')
  end



  % Lin PLot ____________________________________________________________________
  if interactive
    figure;
  else
    figure('Visible','off');
  end
  lim = sqrt(2);
  leg = {};
  grey = 0.8;
  numSensorsCounted = 0;
  for ex = 1 : numSensors
    if isempty( piezoSet{ex} )
      continue;
    end
    numSensorsCounted = numSensorsCounted + 1;
  end

  if numSensorsCounted
    plotHeight = numSensorsCounted * 2;
    plotTicks = 0 : 1 : 2 * numSensorsCounted;
    plotTickLbls = { '1', '0' };
    plotOffs = ( 2 * numSensorsCounted : -2 : 2 ) - 1;

    numPlotted = 0;
    for ex = 1 : numSensors
      if isempty( piezoSet{ex} )
        continue;
      end
      numPlotted = numPlotted + 1;
      hold on;
      sensorNumber = cExps(ex,4);
      if sensorNumber > 9000
        continue
      elseif sensorNumber > 500
        sensorName = 'revA';
      else
        sensorName = 'rev4';
      end
      piezo = piezoSet{ex};
      tVec = timeVector(Fs(ex,1),numel(piezo));
      denom = max( abs(max(piezo)), abs(min(piezo)) );
      text(0.25, plotOffs(numPlotted)+0.5, sprintf('%s / %04d - gain=%g/%gdB', sensorName, sensorNumber, cExps(ex,8), cExps(ex,9) ));
      display(sprintf('Plotting piezo vector of %d samples',numel(piezo)))
      plot(tVec,double(piezo)./denom+plotOffs(numPlotted),'Color',[grey,grey,grey])
      plot(tVec,piezo+plotOffs(numPlotted))
    end

    set(gca,'YLim',[0, plotHeight]);
    set(gca,'YTick',plotTicks);
    set(gca,'YTickLabel',plotTickLbls);
    xlabel('Secs')
    ylabel('Amplitude')
    title( sprintf('Plot of piezos for casIdx=%d experiments %s,  src=%s,  FP=%s,  SPL=%gdB', casIdx, datestr(cExps(ex,10)), srcKey(cExps(ex,12)).name, fpKey(cExps(ex,1)).name, cExps(ex,11) ) )
    setPlotSize();
    piezoName = [ makeHexName(sensorNumber), '-' sprintf('%d',cExps(ex,5)), '-piezo-ts', '.jpg' ];
    print( gcf,'-djpeg100', '-noui', [ outputDir, piezoName ] );
  end


  if ~interactive
    
  else
    return
  end

    	
end

