function h=plot(obj,varargin)
%Function to plot EventData objects
%
%h is a list of all the handles for every line object plotted.
%
%obj is the EventData object
%the optional input argument is a list of plotting "rules" that override
%the defaults
%
%
%Function to plot EventData objects
%for now take obj as EventData object
%
%Notes: it defaults to line plots that run from 0 to 1 on the y-axis

% %if ~strcmp(lower(class(obj)),lower('EventData'))
% if ~strcmpi(class(obj),'EventData')
% if ~isa(obj,'EventData')
%     fprintf('Object is not a EventDataObject!\n');
%     return
% end

num=size(varargin,1);

%input argument checks
switch num
    
    case 0
        
        PlotType='line';
        PlotYLims=[0,1];
        PlotColor='Black';
    
    case 1
        
        inArg=varargin{1,1};
            
        if isstruct(inArg)
            
            rules=varargin{1,1};

            if isfield(rules,'PlotType')
                %disp('Found custom plot type...')
                PlotType=rules.PlotType;
            else
                PlotType='line';
            end

            if isfield(rules,'Color')
                %disp('Found custom plot color...')
                PlotColor=rules.Color;
            else
                PlotColor='Black';
            end
            
            if isfield(rules,'YLim')
                %disp('Found custom YLims...')
                PlotYLims=rules.YLim;
            else
                PlotYLims=[0 1];
            end
            
        else
            
            Error('Optional input argument not recognized!')
            
        end
        
    otherwise
        
        Error(sprintf('You supplied %d optional input arguments; there should be no more than one optional input arguments!',num));
        
end

if size(PlotYLims)~=[2,1] & size(PlotYLims)~=[1,2];
    Error('The Y Limit properties are incorrect!')
end
if ~strcmpi(PlotType,'line')
    Error('The plot type must be a line!')
end
%passed

data=obj.events;
numRecs=size(data,1);

hold on
for i=1:numRecs;
    hndl=line([data(i,1) data(i,1)],PlotYLims);
    set(hndl,'Color',PlotColor,'LineStyle','-');
    h(2*i-1)=hndl;
    hndl=line([data(i,2) data(i,2)],PlotYLims);
    set(hndl,'Color',PlotColor,'LineStyle','-.');
    h(2*i)=hndl;
end
hold off

if numRecs==0;
    h=[];
end

end