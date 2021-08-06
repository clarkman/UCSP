function [ pointsC, pIdxsC, pSegsC, tt ] = pickPulses( pulses, col, stationDir, channel  )
%
% Let the user pick a set of points from the current figure. Find the
% actual data value that is closest to the mouse click.
% Display each point as it is selected; display the actual data value (not
% the pixel where the mouse was clicked).

[ status, procDir ] = system( 'echo -n $CMN_PROC_ROOT' );
if( status ), error('$CMN_PROC_ROOT must be defined'), end;

% Get the corresponding source object for the current figure
figureObj = getappdata(gcf, 'sourceData');

hold on
disp('Left mouse button picks points. Right mouse button picks last point.');

tailr = 1/86400;

btn = 1;
numSets = 0;
while btn ~= 2

    btn = 1;
    while btn == 1
        [xi,yi,btn] = ginput(1);
        if( btn == 1 )
            startPt = [xi, yi]
        end
        if( btn == 3 )
            endPt = [xi, yi]
        end
        if( btn == 2 )
            return;
        end
    end

    %Un rotate
    if( startPt(1) > endPt(1) ) % They are bassackwards
        tmpT = startPt(1);
        startPt(1) = endPt(1);
        endPt(1) = tmpT;
        display( 'Flipped X' )
    end
    if( startPt(2) > endPt(2) ) % They are bassackwards
        tmpT = startPt(2);
        startPt(2) = endPt(2);
        endPt(2) = tmpT;
        display( 'Flipped Y' )
    end
    display( [ 'Plotting from: ', datenum2str(startPt(1)), ' to ', datenum2str(endPt(1)) ] );

    line( [startPt(1) startPt(1)], [startPt(2) endPt(2)], 'Color', [0 0 0] )
    line( [endPt(1) endPt(1)], [startPt(2) endPt(2)], 'Color', [0 0 0] )
    line( [startPt(1) endPt(1)], [startPt(2) startPt(2)], 'Color', [0 0 0] )
    line( [startPt(1) endPt(1)], [endPt(2) endPt(2)], 'Color', [0 0 0] )


    % Find the nearest actual data value to the selected mouse click
    sz=size(pulses);
    numPulses = sz(1);

    points = pulses;
    numPoints = 0;
    pIdxs = zeros( numPulses, 1 )
    for p = 1 : numPulses
        pAz = 90 - pulses(p,col);
        if(  pAz < 0 )
            pAz = pAz + 360;
        end

        if( pulses(p,1) >= startPt(1) && pulses(p,2) < endPt(1) && pAz >= startPt(2) && pAz < endPt(2)  )
            numPoints = numPoints + 1;
            points(numPoints,:) = pulses(p,:);
            pIdxs(numPoints) = p;
        end
    end
    points = points(1:numPoints,:);
    pIdxs = pIdxs(1:numPoints);
    display( [ 'Plotting ', sprintf('%d',numPoints), ' pulses.' ] );

    tt=figure;
    [ obj, baseRoot ] = loadDatenum( [startPt(1)-tailr, endPt(1)+tailr], stationDir, channel );
    obj = highpass(double(obj),0.1,1373);

    pSegs = cell( numPoints, 1 );
    minV = 2e24;
    maxV = -2e24;
    maxTT = 0;
    for ith = 1 : numPoints
        try 
            seg = segDatenum( obj, [points(ith,1)-tailr points(ith,2)+tailr] );
            minVmaybe = min(seg);
            if( minVmaybe < minV ), minV=minVmaybe;, end
            maxVmaybe = max(seg);
            if( maxVmaybe > maxV ), maxV=maxVmaybe;, end
            maxTTmaybe = seg.timeEnd;
            if( maxTTmaybe > maxTT ), maxTT=maxTTmaybe;, end
            pSegs{ith} = seg;
            interval = 1 / (seg.sampleRate);
            first = 0;
            last =  first + (length(seg.samples)-1)*interval;
            axisvec = first: interval: last;
            if( points(ith,3) > 0 )
                colr = [0.618 0 0];
            else
                colr = [0 0 0.618];
            end
            hold on;
              plot( axisvec, seg.samples, 'Color', colr );
            hold off;
        catch
            continue;
        end
    end
    
    rr=get(gca,'XLim');
    stationDir(7) = ' ';
    title( sprintf( 'Pulse Overlay for Station %s, Channel %d, %s -to- %s', stationDir, channel, datenum2str( startPt(1)),  datenum2str(endPt(1)) ) );
    ylabel('Counts');
    xlabel('Seconds');
    %set( gca,'YLim', [-10e5, 3e5] );
    plotMargin=(maxV-minV)/10;
    set( gca,'YLim', [minV-plotMargin, maxV+plotMargin] );
    set( gca,'XLim', [0, maxTT] );

    btn=0;
    while btn ~= 1
        try

            [xi,yi,btn] = ginput(1);
            if bth == 2 
            display('Lower');
                return;
            end
        catch
            break;
        end
    end
    
    try
        numSets = numSets + 1;
        pointsC{numSets} = points;
        pIdxsC{numSets} = pIdxs;
        pSegsC{numSets} = pSegs;
        outName = [ procDir, '/pulses/pulseOverlay', sprintf('%d',numSets), '.jpg' ]
        print( tt,'-djpeg100', '-noui', outName)
        figName = [ procDir, '/pulses/pulseOverlay', sprintf('%d',numSets), '.fig' ]
        saveas(gcf,figName)
        close(tt);
    catch
    end

end

