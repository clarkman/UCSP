function zoomAdaptiveDateTicksY(varargin)
% ZOOMADAPTIVEDATETICKS - Make date ticks adapt to zooming
%
% zoomAdaptiveDateTicks('on')
% Turns on the automatic adaptation of date ticks
% to user zooming for the current figure window
%
% zoomAdaptiveDateTicks('off')
% Turns off the automatic adaptation of date ticks
% to user zooming for the current figure window
% 
% zoomAdaptiveDateTicks('demo')
% Opens a demo figure window to play with


if (nargin>0)
   switch varargin{1}
      case 'demo'
         % Create demo values
         dates = floor(now) - linspace(1169,0,15000)';
         values= randn(15000,1);
         % Show data with date ticks
         figure
         plot(dates,values)
         datetick('y')
         zoomAdaptiveDateTicksY('on')
      case 'on'
         % Define a post zoom callback
         set(zoom(gcf),'ActionPostCallback', @adaptiveDateTicksY);
      case 'rel'
         % Define a post zoom callback
         set(zoom(gcf),'ActionPostCallback', @adaptiveTicksY);
      case 'off'
         % Delete the post zoom callback
         set(zoom(gcf),'ActionPostCallback', '');
      otherwise
         figure(gcf)
   end
end


function adaptiveTicksY(figureHandle,eventObjectHandle)
% Resetting x axis to automatic tick mark generation 
set(eventObjectHandle.Axes,'YTickMode','auto')


function adaptiveDateTicksY(figureHandle,eventObjectHandle)
% Resetting x axis to automatic tick mark generation 
set(eventObjectHandle.Axes,'YTickMode','auto')
% using automaticallly generate date ticks
datetick(eventObjectHandle.Axes,'y','keeplimits')
