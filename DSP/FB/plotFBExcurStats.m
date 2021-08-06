function success = plotFBExcurStats(mode,startTime,endTime,network,siteID,viewPlots,plotEQ,logplotEng)
% function success = plotFBExcurStats(mode,startTime,endTime,network,siteID,viewPlots,plotEQ,logplotEng)
%
% This function will plot the FB excursion stats in hopes to find trends.
%
% List of input arguments:
%   mode - plotting mode: 'all','day','week','month','run7','run30'
%   startTime - 'yyyy/mm/dd' of start day for plot - if zero, plot all days
%   endTime - 'yyyy/mm/dd' of end day for plot - if zero, plot all days
%   network - source network for the data and limits
%   siteID - site name for the data and limits
%   viewPlots - display Figures
%   plotEQ - display EQs of interest (hard coded for 609)
%   logplotEng - plot Energy y-axis on log scale

% NOTE: This code uses the relevant code from plotFBssmcsb.m
% Should we plot EQs? Kp?

% COLORS   = ['-r' '-g' '-b' '-m'];
COLORALL = '-ok';
COLORHI = '-og';
COLORLO = '-om';
COLOREQ = '-r';
LINEWEQ = 2;

numCh = 4;

exTotal = 1;    % Excursion Types
exHigh = 2;
exLow = 3;
sNum = 1;    % Stats
sDur = 2;
sEng = 3;

if( ~viewPlots )
    set(gcf,'Visible','off')
end

% Mode
plotDay = false;
plotWeek = false;
plotMonth = false;
plotRun7 = false;
plotRun30 = false;
if( strcmpi(mode,'all') )
    plotDay = true;
    plotWeek = true;
    plotMonth = true;
    plotRun7 = true;
    plotRun30 = true;
elseif( strcmpi(mode,'day') )
    plotDay = true;
elseif( strcmpi(mode,'week') )
    plotWeek = true;
elseif( strcmpi(mode,'month') )
    plotMonth = true;
elseif( strcmpi(mode,'run7') )
    plotRun7 = true;
elseif( strcmpi(mode,'run30') )
    plotRun30 = true;
end

% Start and End Time
if( startTime ), sT = datenum(startTime); else sT = NaN; end
if( endTime ), eT = datenum(endTime); else eT = NaN; end

% Network
network = upper(network);

% Site ID
if( iscell(siteID) )
    SID = siteID{:};
else
    SID = siteID;
end

if( ischar(SID) )
    siteStr = sprintf('%s',SID);
else
    siteStr = sprintf('%d',SID);
end

siteCell = getStationInfo({network},1,1,'SID',siteID,'NAME');
siteName = siteCell{1};

% Earthquakes
if( strcmpi( siteStr, '609' ) ) % East Milpitas
    EQTimes = [ datenum('2007/10/30','yyyy/mm/dd'), datenum('2010/01/10','yyyy/mm/dd') ];
else
    EQTimes = [ ];
end

% Stats File
% Load environment variables
[fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    success = false;
    return
end
dirExcurStats = sprintf('%s/excursionStats',fbExcurDir);
fileExcurStats = sprintf('%s/excurStats.%s%s.mat',dirExcurStats,network,siteStr);

statsDay = [ ];
statsWeek = [ ];
statsMonth = [ ];
statsRun7 = [ ];
statsRun30 = [ ];
if( exist(fileExcurStats,'file') )
    try
        cmd = sprintf('load %s statsDay statsWeek statsMonth statsRun7 statsRun30',fileExcurStats);
        eval(cmd)
        display(sprintf('Excursion Stats loaded from file: %s',fileExcurStats));
    catch
        display(sprintf('Error loading Excursion Stats from file: %s',fileExcurStats));
        success = false;
        return
    end
end

% Plot Directories
currDir = [dirExcurStats '/Plots'];
success = verifyEnvironment(currDir);
currDir = [currDir sprintf('/%s%s_%s%s',network,siteStr,siteName,siteStr)];
success = success && verifyEnvironment(currDir);
plotDirNum = [currDir '/Number/'];
plotDirDur = [currDir '/Duration/'];
plotDirEng = [currDir '/Energy/'];
success = success && verifyEnvironment(plotDirNum) && verifyEnvironment(plotDirDur) && verifyEnvironment(plotDirEng);
if( ~success )
    display(sprintf('Error creating directory for plots: %s, %s, %s',plotDirNum,plotDirDur,plotDirEng))
    display('ENVIRONMENT')
    return
end

figLeft = 0.05;
% figBottom = 0.075;
figWidth = 1.0-2*figLeft;
% figSpacing = 0.025;
% figHeight = (1.0 - 2 * figSpacing - 2 * figBottom) / 3;

% l = {};	                          % - Init legend variable
yllim = 0.08;
xpos = 0.13;
width = 0.7750;
yulim = 1 - yllim;
dy = yulim - yllim;
height = dy / numCh;


for band = 1:13
    if( strcmpi( network, 'CMN' ) || strcmpi( network, 'BK' ) ),
        [f1 f2] = getUCBMAFreqs(band);
    elseif( strcmpi( network, 'BKQ' ) ),
        [f1 f2] = getFBUpperFreqs(band);
    end
    
    if( plotDay )
        % Excursion Number
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsDay(:,1,channel,exTotal,sNum);
            dataZ = statsDay(:,2,channel,exTotal,sNum);
            dataY1 = statsDay(:,band+2,channel,exLow,sNum);
            dataY2 = statsDay(:,band+2,channel,exHigh,sNum);
            dataY3 = statsDay(:,band+2,channel,exTotal,sNum);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Number of Excursions per Day, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirNum sprintf('Day.Number.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Duration
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsDay(:,1,channel,exTotal,sDur);
            dataZ = statsDay(:,2,channel,exTotal,sDur);
            dataY1 = statsDay(:,band+2,channel,exLow,sDur);
            dataY2 = statsDay(:,band+2,channel,exHigh,sDur);
            dataY3 = statsDay(:,band+2,channel,exTotal,sDur);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Duration per Day, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirDur sprintf('Day.Duration.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Energy
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsDay(:,1,channel,exTotal,sEng);
            dataZ = statsDay(:,2,channel,exTotal,sEng);
            dataY1 = statsDay(:,band+2,channel,exLow,sEng);
            dataY2 = statsDay(:,band+2,channel,exHigh,sEng);
            dataY3 = statsDay(:,band+2,channel,exTotal,sEng);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            if(logplotEng), set( ca, 'YScale', 'log' ); end
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Energy per Day, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirEng sprintf('Day.Energy.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
    end % if( plotDay )
    
    if( plotWeek )
        % Excursion Number
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsWeek(:,1,channel,exTotal,sNum);
            dataZ = statsWeek(:,2,channel,exTotal,sNum);
            dataY1 = statsWeek(:,band+2,channel,exLow,sNum);
            dataY2 = statsWeek(:,band+2,channel,exHigh,sNum);
            dataY3 = statsWeek(:,band+2,channel,exTotal,sNum);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Number of Excursions per Week, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirNum sprintf('Week.Number.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Duration
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsWeek(:,1,channel,exTotal,sDur);
            dataZ = statsWeek(:,2,channel,exTotal,sDur);
            dataY1 = statsWeek(:,band+2,channel,exLow,sDur);
            dataY2 = statsWeek(:,band+2,channel,exHigh,sDur);
            dataY3 = statsWeek(:,band+2,channel,exTotal,sDur);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Duration per Week, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirDur sprintf('Week.Duration.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Energy
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsWeek(:,1,channel,exTotal,sEng);
            dataZ = statsWeek(:,2,channel,exTotal,sEng);
            dataY1 = statsWeek(:,band+2,channel,exLow,sEng);
            dataY2 = statsWeek(:,band+2,channel,exHigh,sEng);
            dataY3 = statsWeek(:,band+2,channel,exTotal,sEng);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            if(logplotEng), set( ca, 'YScale', 'log' ); end
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Energy per Week, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirEng sprintf('Week.Energy.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
    end % if( plotWeek )
    
    if( plotMonth )
        % Excursion Number
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsMonth(:,1,channel,exTotal,sNum);
            dataZ = statsMonth(:,2,channel,exTotal,sNum);
            dataY1 = statsMonth(:,band+2,channel,exLow,sNum);
            dataY2 = statsMonth(:,band+2,channel,exHigh,sNum);
            dataY3 = statsMonth(:,band+2,channel,exTotal,sNum);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Number of Excursions per Month, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirNum sprintf('Month.Number.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Duration
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsMonth(:,1,channel,exTotal,sDur);
            dataZ = statsMonth(:,2,channel,exTotal,sDur);
            dataY1 = statsMonth(:,band+2,channel,exLow,sDur);
            dataY2 = statsMonth(:,band+2,channel,exHigh,sDur);
            dataY3 = statsMonth(:,band+2,channel,exTotal,sDur);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Duration per Month, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirDur sprintf('Month.Duration.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Energy
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            dataX = statsMonth(:,1,channel,exTotal,sEng);
            dataZ = statsMonth(:,2,channel,exTotal,sEng);
            dataY1 = statsMonth(:,band+2,channel,exLow,sEng);
            dataY2 = statsMonth(:,band+2,channel,exHigh,sEng);
            dataY3 = statsMonth(:,band+2,channel,exTotal,sEng);
            plot( dataX, dataY1, COLORLO, dataX, dataY2, COLORHI, dataX, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataX(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataX >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            if(logplotEng), set( ca, 'YScale', 'log' ); end
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Energy per Month, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirEng sprintf('Month.Energy.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
    end % if( plotMonth )
    
    if( plotRun7 )
        % Excursion Number
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            % dataX = statsRun7(:,1,channel,exTotal,sNum);
            dataZ = statsRun7(:,2,channel,exTotal,sNum);
            dataY1 = statsRun7(:,band+2,channel,exLow,sNum);
            dataY2 = statsRun7(:,band+2,channel,exHigh,sNum);
            dataY3 = statsRun7(:,band+2,channel,exTotal,sNum);
            plot( dataZ, dataY1, COLORLO, dataZ, dataY2, COLORHI, dataZ, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataZ(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataZ >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Number of Excursions per Last 7 Days, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirNum sprintf('Run7.Number.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Duration
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            % dataX = statsRun7(:,1,channel,exTotal,sDur);
            dataZ = statsRun7(:,2,channel,exTotal,sDur);
            dataY1 = statsRun7(:,band+2,channel,exLow,sDur);
            dataY2 = statsRun7(:,band+2,channel,exHigh,sDur);
            dataY3 = statsRun7(:,band+2,channel,exTotal,sDur);
            plot( dataZ, dataY1, COLORLO, dataZ, dataY2, COLORHI, dataZ, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataZ(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataZ >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Duration per Last 7 Days, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirDur sprintf('Run7.Duration.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Energy
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            % dataX = statsRun7(:,1,channel,exTotal,sEng);
            dataZ = statsRun7(:,2,channel,exTotal,sEng);
            dataY1 = statsRun7(:,band+2,channel,exLow,sEng);
            dataY2 = statsRun7(:,band+2,channel,exHigh,sEng);
            dataY3 = statsRun7(:,band+2,channel,exTotal,sEng);
            plot( dataZ, dataY1, COLORLO, dataZ, dataY2, COLORHI, dataZ, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataZ(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataZ >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            if(logplotEng), set( ca, 'YScale', 'log' ); end
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Energy per Last 7 Days, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirEng sprintf('Run7.Energy.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
    end % if( plotRun7 )
    
    if( plotRun30 )
        % Excursion Number
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            % dataX = statsRun30(:,1,channel,exTotal,sNum);
            dataZ = statsRun30(:,2,channel,exTotal,sNum);
            dataY1 = statsRun30(:,band+2,channel,exLow,sNum);
            dataY2 = statsRun30(:,band+2,channel,exHigh,sNum);
            dataY3 = statsRun30(:,band+2,channel,exTotal,sNum);
            plot( dataZ, dataY1, COLORLO, dataZ, dataY2, COLORHI, dataZ, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataZ(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataZ >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Number of Excursions per Last 30 Days, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirNum sprintf('Run30.Number.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Duration
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            % dataX = statsRun30(:,1,channel,exTotal,sDur);
            dataZ = statsRun30(:,2,channel,exTotal,sDur);
            dataY1 = statsRun30(:,band+2,channel,exLow,sDur);
            dataY2 = statsRun30(:,band+2,channel,exHigh,sDur);
            dataY3 = statsRun30(:,band+2,channel,exTotal,sDur);
            plot( dataZ, dataY1, COLORLO, dataZ, dataY2, COLORHI, dataZ, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataZ(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataZ >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            % set( ca, 'YScale', 'log' );
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Duration per Last 30 Days, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirDur sprintf('Run30.Duration.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
        
        % Excursion Energy
        if( ishandle(1) )
            set(0,'CurrentFigure',1)
        else
            figure(1)
        end
        
        for channel = 1:4
            subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
            % dataX = statsRun30(:,1,channel,exTotal,sEng);
            dataZ = statsRun30(:,2,channel,exTotal,sEng);
            dataY1 = statsRun30(:,band+2,channel,exLow,sEng);
            dataY2 = statsRun30(:,band+2,channel,exHigh,sEng);
            dataY3 = statsRun30(:,band+2,channel,exTotal,sEng);
            plot( dataZ, dataY1, COLORLO, dataZ, dataY2, COLORHI, dataZ, dataY3, COLORALL );
            
            % Plot settings
            % x limits
            if( isnan( sT ) ), xmin = dataZ(1); else xmin = sT; end
            if( isnan( eT ) ), xmax = dataZ(end); else xmax = eT; end
            if( xmax < xmin ), trash = xmin; xmin = xmax; xmax = trash; end
            
            % y limits.
            ymin = 10e30;
            ymax = 10e-30;
            xInd = ( dataZ >= xmin & dataZ <= xmax );
            dY1 = dataY1( xInd, : );
            dY2 = dataY2( xInd, : );
            dY3 = dataY3( xInd, : );
            maxy = max( [ max(dY1);max(dY2);max(dY3) ] );
            miny = min( [ min(dY1);min(dY2);min(dY3) ] );
            if( maxy > ymax ), ymax = maxy; end
            if( miny < ymin ), ymin = miny; end

            ca = get( gcf, 'CurrentAxes' );
            if(logplotEng), set( ca, 'YScale', 'log' ); end
            set( ca, 'XTickLabel', {} );
            set( ca , 'XLim', [xmin xmax] );
            if ( ymax > ymin )
                set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
            end

            %pos = get(ca,'Position');
            pos2 = [ figLeft (1 - yllim - (height*(channel)) ) figWidth (height-0.01) ];
            set( ca, 'Position', pos2 );
            %pos = get(ca,'Position');
            
            if( plotEQ )
                for iEQ = EQTimes
                    plot( [iEQ;iEQ], [ymin;ymax], COLOREQ, 'LineWidth', LINEWEQ )
                end
            end
            
            if ( channel == 1 )
                s = sprintf( '%s%s - %s - Average Excursion Energy per Last 30 Days, FB%d: %f - %f', network, siteStr, siteName, band, f1, f2);
                title( s );
            end

            if( channel == numCh )
                datetick('x','yyyy/mm/dd','keeplimits')
                xlabel( 'Local time (PST)' );
            end
        end % for channel = 1:4
        
        % Save plot
        dateRange = sprintf('%s_%s',datestr(xmin,'yyyymmdd'),datestr(xmax,'yyyymmdd'));
        plotFileName = [plotDirEng sprintf('Run30.Energy.%s.%s.%s.FB%02d',dateRange,network,siteStr,band)];
        try
            success = saveFBExcurPlot(plotFileName);
            if( success ~= 0 )
                success = false;
                display('Error saving plot for current day')
                display('BAD_WRITE')
                return
            end
        catch
            display('Error saving plot for current day')
            display('BAD_WRITE')
            success = false;
            return
        end
    end % if( plotRun30 )
end % for band = 1:13

success = true;
return

% cmd = sprintf('gcf%d = gcf;',channel);
% eval( cmd );

% =========================================================================
% Plotting eqs.
% =========================================================================