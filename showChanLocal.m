function showChanLocal( range, caliber, bullet, chans, comment )
%showChanLocal Summary of this function goes here
%   Detailed explanation goes here


%ipAddr = '192.168.1.7';
%ipAddr = '10.10.102.70';
usr = 'cuz';
%ljPath = '/home/cuz/src/afusion/trunk/labjack/'
ljPath = '/Users/cuz/Desktop/Projects/SST/Artemis/src/Artemis/tools/afusion/labjack/';
ljExec = [ ljPath, 'labjackBurst' ];
ljAdresses = { '192.168.2.8', '192.168.2.7', '192.168.2.6' };
ljOutFiles = { 'a', 'b', 'c' };
sampRate = 24000;
collLen = sampRate * 16;

if ~iscell(chans)
  error( 'chans must be cell array!' )
end

numChans = length(chans);

fName = sprintf('%s-%d-%s-%s-%s',comment,numChans,caliber,bullet,datestr(now,'yyyy-mm-dd-HH-MM-SS'));

%collLen = collLen / numChans;
%sampRate = sampRate / numChans;

chCodes = getChannelCodes( chans );
if isempty(chCodes)
  error('Channel Code fail')
end
if( length(chCodes) ~= numChans )
  error( 'One or more channel codes not matched');
end

chs='';
%iscell(chCodes{1})
for c = 1 : numChans
  chs = [ chs, chCodes{c}, ' ' ];
end

% Clean prior ...
cmd = [ 'rm -f ', [ ljOutFiles{1} '.dat ' ], [ ljOutFiles{2} '.dat ' ], [ ljOutFiles{3} '.dat' ] ]
system(cmd)
cmdA = [ ljExec, ' ', sprintf('%d %d %s %s', collLen, sampRate, ljAdresses{1}, ljOutFiles{1} ), ' ', chs, '&' ]
cmdB = [ ljExec, ' ', sprintf('%d %d %s %s', collLen, sampRate, ljAdresses{2}, ljOutFiles{2} ), ' ', chs, '&' ]
cmdC = [ ljExec, ' ', sprintf('%d %d %s %s', collLen, sampRate, ljAdresses{3}, ljOutFiles{3} ), ' ', chs, '&' ]

kickoffTime = now;
system(cmdA);
system(cmdB);
system(cmdC);
datestr(kickoffTime)

pause(12);

% range = { '68', '34', '9' };
% range = { '34.5', '5', '26' };
%range = { '26.5', '10', '8.6' };
ljNames{1} = [ fName, '-', range{1}, '-', ljOutFiles{1} ];
cmdAmv = [ 'mv ', [ ljOutFiles{1}, '.dat' ], ' ', ljNames{1} ];
system(cmdAmv);
ljNames{2} = [ fName, '-', range{2}, '-', ljOutFiles{2} ];
cmdBmv = [ 'mv ', [ ljOutFiles{2}, '.dat' ], ' ', ljNames{2} ];
system(cmdBmv);
ljNames{3} = [ fName, '-', range{3}, '-', ljOutFiles{3} ];
cmdCmv = [ 'mv ', [ ljOutFiles{3}, '.dat' ], ' ', ljNames{3} ];
system(cmdCmv);

fftL = 2048;
adcRange = 20;

for lj = 1 : 3

  tdObjs=readData( ljNames{lj}, sampRate, numChans, kickoffTime );

  for chan = 1 : numChans

    tdObj = tdObjs{chan};
    fRoot = [ ljNames{lj}, '-', chans{chan} ];
    writeWaveFile( tdObj, fRoot, sampRate );

    % figure;
    % plot2(tdObj);
    % ylabel('Volts');
    % uVect = unique(tdObj.samples);
    % bitsRes = uVect(end)-uVect(end-1);
    % LSB = adcRange / bitsRes;
    % bits = round(log2(LSB));
    % title( sprintf( '%s, SR= %d, res = %fV, bits=%d, mean=%f, std=%f', fRoot, sampRate, bitsRes, bits, mean(tdObj), std(tdObj) ) );
    % orient portrait
    % print( gcf,'-djpeg100', [ fRoot, '.ts.zoomed.jpg' ] );
    % set(gca,'YLim',[-5,5])
    % print( gcf,'-djpeg100', [ fRoot, '.ts.jpg' ] );


    % [outBins, histBinWidth] = histogram(tdObj,1000);
    % xlabel('Volts');
    % ylabel('Qty');
    % numVals = numel(find(outBins>0));
    % title( sprintf( '%s, Sample Rate = %d, numVals=%d', fRoot, sampRate, numVals ) )
    % print( gcf,'-djpeg100', [ fRoot, '.hist.jpg' ] );


    % hndl = figure;
    % fdObj = spectrum(zeroCenter(tdObj),fftL);
    % freq=freqVector(fdObj);
    % fdObj.valueType = 'Volts^2/Hz';
    % plot(fdObj);
    % set(gca,'XScale','log');
    % set(gca,'YScale','log');
    % set(gca,'XLim',[freq(1),freq(end)]);
    % title( fRoot );
    % orient portrait
    % set(gca,'YLim',[min(fdObj.samples),max(fdObj.samples)]);
    % print( gcf,'-djpeg100', [ fRoot, '.fft.zoomed.jpg' ] );
    % set(gca,'YLim',[1e-12,1e-2]);
    % print( gcf,'-djpeg100', [ fRoot, '.fft.jpg' ] );
    % close( hndl );



    % plot(log10(spectrogram(zeroCenter(tdObj),fftL,0.75)));
    % orient portrait
    % title( fRoot );
    % print( gcf,'-djpeg100', [ fRoot, '.sgram.jpg' ] );

  end
display(sprintf('Printing %d',lj))
  plotFour( tdObjs, chans, lj, ljNames{lj} );

end
