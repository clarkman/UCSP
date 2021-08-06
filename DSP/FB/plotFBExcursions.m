function plotFBExcursions(numCh,day,network,site,channel,band,dataX,dataY,limitHiX,limitHiY,limitLoX,limitLoY,excurPtsHi,excurPtsLo,viewPlots)
% function plotFBExcursions(numCh,day,network,site,channel,band,dataX,dataY,limitHiX,limitHiY,limitLoX,limitLoY,excurPtsHi,excurPtsLo,viewPlots)
%
% This function will plot the FB data and limits for a given day, network,
% site, channel, and band. The plots will be resized to match the format
% for the website. Excursion points are also marked.
%
% List of input arguments:
%   numCh - total number of channels (used to size the subplots)
%   day - datenum for the input data and limits
%   network - source network for the data and limits
%   sites - site name for the data and limits
%   channel - [1:4] source channel for the data and limits
%   bands - [1:13] source band for the data and limits
%   dataX - x-axis for data plot
%   dataY - y-axis for data plot
%   limitHiX - x-axis for high limit
%   limitHiY - y-axis for high limit
%   limitLoX - x-axis for low limit
%   limitLoY - y-axis for low limit
%   excurPtsHi - points from data that are high excursions
%   excurPtsLo - points from data that are low excursions
%   viewPlots - display Figures

% NOTE: This code uses the relevant code from plotFBssmcsb.m
% Should we plot EQs? Kp?

COLORS   = ['-r' '-g' '-b' '-m'];

if( ~viewPlots )
    set(gcf,'Visible','off')
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

if( strcmpi( network, 'CMN' ) || strcmpi( network, 'BK' ) ),
    [f1 f2] = getUCBMAFreqs(band);
elseif( strcmpi( network, 'BKQ' ) ),
    [f1 f2] = getFBUpperFreqs(band);
end

currDate = datestr(day,'yyyy/mm/dd');
% s = sprintf( '%s %s - %s - FB%d: %f - %f', siteNames(site), currDate, currDate, band, f1, f2 );
% title( s );

lp = channel - 1;
subplot( 'Position' , [ xpos (1 - yllim - (height*(channel)) ) width (height-0.01) ] ), cla, hold on;
plot( dataX, dataY, COLORS((lp*2+1):(channel*2)) );
if( ~isnan(limitHiX) & ~isnan(limitHiY) ) %#ok<AND2>
    plot( limitHiX,limitHiY,'-k' );
end
if( ~isnan(limitLoX) & ~isnan(limitLoY) ) %#ok<AND2>
    plot( limitLoX,limitLoY,'-k' );
end
% if( size(excurPoints,2) > 0 )
%     plot( excurPoints(:,1),excurPoints(:,2),'o','MarkerEdgeColor','k','MarkerFaceColor',COLORS(channel*2),'MarkerSize',3 )
% end
if( ~isnan(excurPtsHi) & (size(excurPtsHi,2) > 0) ) %#ok<AND2>
    plot( excurPtsHi(:,1),excurPtsHi(:,2),'o','MarkerEdgeColor','k','MarkerFaceColor',COLORS(channel*2),'MarkerSize',3 )
end
if( ~isnan(excurPtsLo) & (size(excurPtsLo,2) > 0) ) %#ok<AND2>
    plot( excurPtsLo(:,1),excurPtsLo(:,2),'o','MarkerEdgeColor','k','MarkerFaceColor',COLORS(channel*2),'MarkerSize',3 )
end

% Init y limits.
ymin = 10e30;
ymax = 10e-30;
if( max( limitHiY(:,1) ) > ymax )
    ymax = max( limitHiY(:,1) );
end
if( min( limitHiY(:,1) ) < ymin )
    ymin = min( limitLoY(:,1) );
end


% set(get(gcf,'CurrentAxes'),'YScale','log' );
ca = get( gcf, 'CurrentAxes' );
set( ca, 'YScale', 'log' );
set( ca, 'XTickLabel', {} );
set( ca , 'XLim', [day day+1] );
% jwc
tmp1 = sort( dataY(:,1), 'ascend' );
tmp2 = find( tmp1 > 0 );
if ( ~isempty(tmp2) ) % tmp2 ~= 0
    if ( tmp1(tmp2(1)) < ymin )
        ymin = tmp1(tmp2(1));
    end
end
if ( max( dataY(:,1) ) > ymax )
    ymax = max( dataY(:,1) );
end

if ( ymax > ymin )
    set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
end

%pos = get(ca,'Position');
pos2 = [ figLeft (1 - yllim - (height*(lp+1)) ) figWidth (height-0.01) ];
set( ca, 'Position', pos2 );
%pos = get(ca,'Position');

if ( lp == 0 ),
    s = sprintf( '%s %s - %s - FB%d: %f - %f in pico Teslas', siteNames(site), currDate, currDate, band, f1, f2 );
    title( s );
end

if( channel == numCh )
    datetick('x','HH:MM','keeplimits')
    xlabel( 'Local time (PST)' );
end

return

% cmd = sprintf('gcf%d = gcf;',channel);
% eval( cmd );

% =========================================================================
% Plotting eqs.
% =========================================================================