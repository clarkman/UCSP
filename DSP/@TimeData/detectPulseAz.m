function [ residual1, residual2, residual3, residualPulse, metaOut ] = detectPulseAz( seg1, seg2, seg3, pulses, meta, fid );
%
% Works with pulseAzWalker.m 
%

interactive = 0;
[chan, ch] = makeCh( pulses(1,4) );

% Load pulse detector
if( interactive )
  detector = getPulseDetector( 'qf1', seg1.DataCommon.station );
  switch ch
      case 1
        hiLim = detector.ch1_Pos;
        loLim = detector.ch1_Neg;
        colr = [ 0 0 1 ];
      case 2
        hiLim = detector.ch2_Pos;
        loLim = detector.ch2_Neg;
        colr = [ 0 1 0 ];
      case 3
        hiLim = detector.ch3_Pos;
        loLim = detector.ch3_Neg;
        colr = [ 1 0 0 ];
      otherwise
        error( 'Bad ch!!!' );
  end

end

residual1 = -1;
residual2 = -1;
residual3 = -1;
residualPulse = -1;
metaOut = meta;

RTD = 180 / pi;

sz = size( pulses );
numPulses = sz(1);
pTend = pulses( end, 1 ) + pulses( end, 2 ) / 86400;
if( ~numPulses || pulses( 1, 1 ) > endTime( seg1 ) || pTend < seg1.DataCommon.UTCref  )
    return
end
pWidth = 5;

display( [ 'Computing pulse azimuths for: ', seg1.DataCommon.station, ' CHANNEL', chan, ' ', datenum2str(seg1.DataCommon.UTCref) ] );

numSamps = length( seg1 );
if( strcmp( seg1.DataCommon.network, 'BK' ) )
    seg1 = removeDC(seg1);
    seg2 = removeDC(seg2);
    seg3 = removeDC(seg3);
else
    stn = sscanf( seg1.DataCommon.station, '%d' );

%    if 1
    seg1 = zeroCenter(seg1);
    seg2 = zeroCenter(seg2);
    seg3 = zeroCenter(seg3);
%    else
%      seg1 = removeDC(seg1);
%      seg2 = removeDC(seg2);
%      seg3 = removeDC(seg3);
%    end


% OLD:
%    if 0
%      if( stn > 699 )
%          seg1 = removeDC(seg1);
%          seg2 = removeDC(seg2);
%          seg3 = removeDC(seg3);
%      else
%          Mean1 = channelMean( stn, 1,  seg1.DataCommon.UTCref );
%          Mean2 = channelMean( stn, 2,  seg1.DataCommon.UTCref );
%          Mean3 = channelMean( stn, 3,  seg1.DataCommon.UTCref );
%          seg1 = seg1 - Mean1;
%          seg2 = seg2 - Mean2;
%          seg3 = seg3 - Mean3;
%      end
%    end
end

pTend = pulses( end, 1 ) + pulses( end, 2 ) / 86400;
if( pulses( end, 2 ) > endTime( seg1 ) && pulses( end, 1 ) < endTime( seg1 ) ) % Last pulse hangs off the end of these segments
    residual1 = segDatenum( seg1, [ pulses( end, 1 ), endTime( seg1 ) ] );
    residual2 = segDatenum( seg2, [ pulses( end, 1 ), endTime( seg1 ) ] );
    residual3 = segDatenum( seg3, [ pulses( end, 1 ), endTime( seg1 ) ] );
    residualPulse = pulses( end, : );
    pulses = pulses( 1:end-1, : );
end

sz = size( pulses );
numPulses = sz(1);
display( sprintf( 'Counted %d pulses', numPulses ) );

if( numPulses > 0 )

    for pul = 1 : numPulses
        try
            pTend = pulses( pul, 1 ) + pulses( pul, 2 ) / 86400;
            pulse1 = segDatenum( seg1, [pulses( pul, 1 ),  pTend] );
            pulse2 = segDatenum( seg2, [pulses( pul, 1 ),  pTend] );
            pulse3 = segDatenum( seg3, [pulses( pul, 1 ),  pTend] );
        catch
            break;
        end
        pLengthr = length(pulse1);
        if( pLengthr > 10000 )  % Half power stuff - turned off for now.
          switch( ch )
            case 1
              if( pulses( pul, 5 ) > 0 )
                [v, pk] = max( pulse1.samples );
              else
                [v, pk] = min( pulse1.samples );
              end
            case 2
              if( pulses( pul, 5 ) > 0 )
                [v, pk] = max( pulse2.samples );
              else
                [v, pk] = min( pulse2.samples );
              end
            case 3
              if( pulses( pul, 5 ) > 0 )
                [v, pk] = max( pulse3.samples );
              else
                [v, pk] = min( pulse3.samples );
              end
            otherwise
              error( 'Bad ch!!!' );
          end
          hWidth = floor(pWidth/2);
          if( pk < ceil(pWidth/2) )
            pulse1.samples = double( pulse1.samples(1:pk+hWidth) );
            pulse2.samples = double( pulse2.samples(1:pk+hWidth) );
            pulse3.samples = double( pulse3.samples(1:pk+hWidth) );
          elseif( pk >  pLengthr - ceil(pWidth/2) )
            pulse1.samples = double( pulse1.samples(pk-hWidth:end) );
            pulse2.samples = double( pulse2.samples(pk-hWidth:end) );
            pulse3.samples = double( pulse3.samples(pk-hWidth:end) );
          else
            pulse1.samples = double( pulse1.samples(pk-hWidth:pk+hWidth) );
            pulse2.samples = double( pulse2.samples(pk-hWidth:pk+hWidth) );
            pulse3.samples = double( pulse3.samples(pk-hWidth:pk+hWidth) );
          end
        else
          pulse1.samples = double( pulse1.samples );
          pulse2.samples = double( pulse2.samples );
          pulse3.samples = double( pulse3.samples );
          if( pulses( pul, 5 ) > 0 )
            v1 = max( pulse1.samples );
            v2 = max( pulse2.samples );
            v3 = max( pulse3.samples );
          else
            v1 = min( pulse1.samples );
            v2 = min( pulse2.samples );
            v3 = min( pulse3.samples );
          end
        end
        pAz1 = round( cartesian2compass( atan2( pulse1, pulse2 ) * RTD ) );
        pAz2 = round( cartesian2compass( atan2( pulse3, pulse2 ) * RTD ) );
        pAz3 = round( cartesian2compass( atan2( pulse3, pulse1 ) * RTD ) );
        
        % Histograms anew
        pAzHist1 = zeros(1,360);
        pAzHist2 = zeros(1,360);
        pAzHist3 = zeros(1,360);

        pLen = length( pAz1 );
        for p = 1 : pLen
            if( ~pAz1(p) ) % Hand-wrapped
                pAzHist1( 360 ) = pAzHist1( 360 ) + 1;
            else
                pAzHist1( pAz1(p) ) = pAzHist1( pAz1(p) ) + 1;
            end
            if( ~pAz2(p) ) % Hand-wrapped
                pAzHist2( 360 ) = pAzHist2( 360 ) + 1;
            else
                pAzHist2( pAz2(p) ) = pAzHist2( pAz2(p) ) + 1;
            end
            if( ~pAz3(p) ) % Hand-wrapped
                pAzHist3( 360 ) = pAzHist3( 360 ) + 1;
            else
                pAzHist3( pAz3(p) ) = pAzHist3( pAz3(p) ) + 1;
            end
        end
        % Now we have three wrapped histograms.  Compute facts & write.
        modeCount = floor( pLen / 2 );
        run1Tot = 0; run2Tot = 0; run3Tot = 0;
        median1 = 0; median2 = 0; median3 = 0;
        for p = 1 : 360
            run1Tot = run1Tot + pAzHist1(p) * p;
            run2Tot = run2Tot + pAzHist2(p) * p;
            run3Tot = run3Tot + pAzHist3(p) * p;
        end
        totlr = 0;
        for p = 1 : 360
            totlr = totlr + pAzHist1(p);
            if( totlr > modeCount )
                break;
            end
        end
        median1 = p;
        totlr = 0;
        for p = 1 : 360
            totlr = totlr + pAzHist2(p);
            if( totlr > modeCount )
                break;
            end
        end
        median2 = p;
        totlr = 0;
        for p = 1 : 360
            totlr = totlr + pAzHist3(p);
            if( totlr > modeCount )
                break;
            end
        end
        median3 = p;
        mean1 = run1Tot / pLen;
        mean2 = run2Tot / pLen;
        mean3 = run3Tot / pLen;
        [ peak1, iPeak1 ] = max( pAzHist1 );
        numF = find( pAzHist1 == peak1 );
        countF = length( numF );
        if( countF > 2 )
          iPeak1 = numF(round(countF/2));
          display( sprintf( 'Taking median hist bin %d', iPeak1 ) );
        end
        [ peak2, iPeak2 ] = max( pAzHist2 );
        numF = find( pAzHist2 == peak2 );
        countF = length( numF );
        if( countF > 2 )
          iPeak2 = numF(round(countF/2));
          display( sprintf( 'Taking median hist bin %d', iPeak1 ) );
        end
        [ peak3, iPeak3 ] = max( pAzHist3 );
        numF = find( pAzHist3 == peak3 );
        countF = length( numF );
        if( countF > 2 )
          iPeak3 = numF(round(countF/2));
          display( sprintf( 'Taking median hist bin %d', iPeak1 ) );
        end
        rsum1 = 0;
        rsum2 = 0;
        rsum3 = 0;
        for p = 1 : 360
            rsum1 = rsum1 + ( ( p - mean1 ) ^ 2 * pAzHist1(p) );
            rsum2 = rsum2 + ( ( p - mean2 ) ^ 2 * pAzHist2(p) );
            rsum3 = rsum3 + ( ( p - mean3 ) ^ 2 * pAzHist3(p) );
        end
        std1 = sqrt( rsum1 / pLen );
        std2 = sqrt( rsum2 / pLen );
        std3 = sqrt( rsum3 / pLen );
        pTend = pulses( pul, 1 ) + pulses( pul, 2 ) / 86400;

        if( interactive )
          subplot(2,1,1);
          plot( pulse1, pulse2, pulse3 );
          line( get(gca,'XLim'), [loLim, loLim], 'Color', colr, 'LineStyle', '--' );
          line( get(gca,'XLim'), [hiLim, hiLim], 'Color', colr, 'LineStyle', '--' );
          %set( gca, 'XLim', [pulses(pul,1), pTend] )
          subplot(2,1,2);
          plot( 1:360, pAzHist2 );
          but = 1;
          while but == 1
            [xi,yi,but] = ginput(1)
          end
          close('all');
        end


        %           1              2      3              4             5           6           7           8      9      10     11       12       13       14              15              16              17    18    19
        nextRow = [ pulses(pul,1), pTend, pulses(pul,3), double(pLen), double(v1), double(v2), double(v3), mean1, mean2, mean3, median1, median2, median3, double(iPeak1), double(iPeak2), double(iPeak3), std1, std2, std3 ];
        fwrite(fid, nextRow, 'double');

        % Now add to meta, 1 is grand total
        ch1Summary = meta.histos1( 1, : );
        ch2Summary = meta.histos2( 1, : );
        ch3Summary = meta.histos3( 1, : );
        metaOut.histos1( 1, : ) = ch1Summary + pAzHist1;
        metaOut.histos2( 1, : ) = ch2Summary + pAzHist2;
        metaOut.histos3( 1, : ) = ch3Summary + pAzHist3;
        
        pulseT = ( pulse1.DataCommon.UTCref + endTime(pulse1) ) / 2.0;
        pulseHOD =  ceil( ( pulseT - floor(pulseT) ) * 24 ) + 1; % Idx = 2:25
        if( pulseHOD < 2 || pulseHOD > 25 )
            error( 'Conceptual Operator Mysfunction' );
        end
        ch1Summary = meta.histos1( pulseHOD, : );
        ch2Summary = meta.histos2( pulseHOD, : );
        ch3Summary = meta.histos3( pulseHOD, : );
        metaOut.histos1( pulseHOD, : ) = ch1Summary + pAzHist1;
        metaOut.histos2( pulseHOD, : ) = ch2Summary + pAzHist2;
        metaOut.histos3( pulseHOD, : ) = ch3Summary + pAzHist3;
        
    end

end


