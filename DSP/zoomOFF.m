function out = zoom(varargin)
%ZOOM   Zoom in and out on a 2-D plot.
%   ZOOM with no arguments toggles the zoom state.
%   ZOOM(FACTOR) zooms the current axis by FACTOR.
%       Note that this does not affect the zoom state.
%   ZOOM ON turns zoom on for the current figure.
%   ZOOM XON or ZOOM YON turns zoom on for the x or y axis only.
%   ZOOM OFF turns zoom off in the current figure.
%
%   ZOOM RESET resets the zoom out point to the current zoom.
%   ZOOM OUT returns the plot to its current zoom out point.
%   If ZOOM RESET has not been called this is the original
%   non-zoomed plot.  Otherwise it is the zoom out point
%   set by ZOOM RESET.
%
%   When zoom is on, click the left mouse button to zoom in on the
%   point under the mouse. Each time you click, the axes limits will be
%   changed by a factor of 2 (in or out).  You can also click and drag
%   to zoom into an area. It is not possible to zoom out beyond the plots'
%   current zoom out point.  If ZOOM RESET has not been called the zoom
%   out point is the original non-zoomed plot.  If ZOOM RESET has been
%   called the zoom out point is the zoom point that existed when it
%   was called. Double clicking zooms out to the current zoom out point -
%   the point at which zoom was first turned on for this figure
%   (or to the point to which the zoom out point was set by ZOOM RESET).
%   Note that turning zoom on, then off does not reset the zoom out point.
%   This may be done explicitly with ZOOM RESET.
%
%   ZOOM(FIG,OPTION) applies the zoom command to the figure specified
%   by FIG. OPTION can be any of the above arguments.
%
%   Use LINKAXES to link zooming across multiple axes.
%
%   See also PAN, LINKAXES.

% Copyright 1993-2005 The MathWorks, Inc.

% Internal use undocumented syntax (this may be removed in a future
% release)
% Additional syntax not already ded in zoom m-help
%
% ZOOM(FIG,'UIContextMenu',...)
%    Specify UICONTEXTMENU for use in zoom mode
% ZOOM(FIG,'Constraint',...)
%    Specify constrain option:
%       'none'       - No constraint (default)
%       'horizontal' - Horizontal zoom only for 2-D plots
%       'vertical'   - Vertical zoom only for 2-D plots
% ZOOM(FIG,'Direction',...)
%    Specify zoom direction 'in' or 'out'
% OUT = ZOOM(FIG,'IsOn')
%    Returns true if zoom is on, otherwise returns false.
% OUT = ZOOM(FIG,'Constraint')
%    Returns 'none','horizontal', or 'vertical'
% OUT = ZOOM(FIG,'Direction')
%    Returns 'in' or 'out'

% Undocumented syntax that will never get documented
% (but we have to keep it around for legacy reasons)
% OUT = ZOOM(FIG,'getmode') 'in'|'out'|'off'
%
% Undocumented zoom object registration methods
% OUT = ZOOM(FIG,'getzoom')
%    Get zoom object
% ZOOM(FIG,'setzoom',...)
%    Set zoom object

%   Note: zoom uses the figure buttondown and buttonmotion functions
%
%   ZOOM XON zooms x-axis only
%   ZOOM YON zooms y-axis only

%   ZOOM v6 off Switches to new zoom implementation
%   ZOOM v6 on Switches to old zoom implementation

%   ZOOM FILL scales a plot such that it is as big as possible
%   within the axis position rectangle for any azimuth and elevation.

% Undocumented switch to v6 zoom implementation. This will be removed.
if nargin==2 && ...
        ischar(varargin{1}) && ...
        strcmp(varargin{1},'v6') && ...
        ischar(varargin{2})
    if strcmp(varargin{2},'on')
        localSetV6Zoom(true);
    else
        localSetV6Zoom(false);
    end
    return;
end

% Bypass to v6 zoom
if localIsV6Zoom
    if nargout==0
        v6_zoom(varargin{:});
    else
        out = v6_zoom(varargin{:});
    end
    return;
end

% Parse input arguments
[target,action,action_data] = localParseArgs(varargin{:});

% If setting zoom object, ZOOM(H,HZOOM), then return early
if strcmp(action,'setzoom')
    localRegisterZoomObject(action_data);
    return;
end

% Return early if target is not an axes or figure
if isempty(target) || ...
        (~isa(target,'hg.axes') && ~isa(target,'hg.figure'))
    return;
end
hFigure = ancestor(target,'hg.figure');
hManager = uigetmodemanager(hFigure);

% Return early if setting zoom off and there's no app data
% this avoids making any objects or setting app data when
% it doesn't need to. For example, hgload calls zoom(fig,'off')
appdata = getappdata(hFigure,'ZoomOnState');
if strcmp(action,'off') && isempty(appdata);
    return;
end

% Get zoom object
hZoom = localGetRegisteredZoomObject(hManager);

% Update zoom target in case it changed
set(hZoom,'target',target);

% Get current axes
hCurrentAxes = get(hFigure,'CurrentAxes');

% Parse various zoom options
change_ui = [];
switch lower(action)

    case 'on'
        set(hZoom,'Constraint','none');
        change_ui = 'on';

    case 'xon'
        set(hZoom,'Constraint','horizontal');
        change_ui = 'on';

    case 'yon'
        set(hZoom,'Constraint','vertical');
        change_ui = 'on';

    case 'getzoom'
        out = hZoom;
    case 'getmode'
        if localIsZoomOn(hZoom)
            out = get(hZoom,'Direction');
        else
            out = 'off';
        end
    case 'constraint'
        out = get(hZoom,'Constraint');
    case 'direction'
        out = get(hZoom,'Direction');
    case 'ison'
        out = localIsZoomOn(hZoom);
    case 'getstyle' %TBD: Remove
        out = get(hZoom,'Constraint');
    case 'getdirection' %TBD: Remove
        out = get(hZoom,'Direction');
    case 'toggle'
        if localIsZoomOn(hZoom)
            change_ui = 'off';
        else
            change_ui = 'on';
        end

        % Undocumented legacy API, used by 'ident', see g194435
        % It would be nice to get rid to dependencies on this API, but
        % many old toolboxes seem to be calling this API.
    case 'down'
        buttondownfcn(hZoom,'dorightclick',true);
        hLine = get(hZoom,'LineHandles');
        if any(ishandle(hLine))
            % Mimic rbbox, don't return until line handles are
            % removed
            waitfor(hLine(1));
        end

    case 'off'
        change_ui = 'off';
    case 'inmode'
        set(hZoom,'Direction','in');
        change_ui = 'on';
    case 'outmode'
        set(hZoom,'Direction','out');
        change_ui = 'on';
    case 'scale'
        if ~isempty(hCurrentAxes)
            % Register current axes view for reset view support
            resetplotview(hCurrentAxes,'InitializeCurrentView');
            applyzoomfactor(hZoom,hCurrentAxes,action_data);
        end
    case 'fill'
        if ~isempty(hCurrentAxes)
            resetplot(hZoom,hCurrentAxes);
        end
    case 'reset'
        resetplotview(hCurrentAxes,'SaveCurrentView');
    case 'out'
        if ~isempty(hCurrentAxes)
            resetplot(hZoom,hCurrentAxes);
        end
    case 'setzoomproperties'
        % undocumented
        set(hZoom,action_data{:});
    otherwise
        return
end

% Update the user interface
if ~isempty(change_ui)
    localSetZoomState(hManager,change_ui);
end

%-----------------------------------------------%
function localSetZoomState(hManager,state)

hMode = locGetMode(hManager);

if strcmp(state,'on')
    set(hManager,'CurrentMode',hMode);
    % zoom off
elseif strcmp(state,'off')
    if hManager.isCurrentMode('Exploration.Zoom')
        set(hManager,'CurrentMode','');
    end
end

%-----------------------------------------------%
function [bool] = localIsZoomOn(hZoom)
fig = hZoom.FigureHandle;
mmgr = uigetmodemanager(fig);
bool = false;
if mmgr.isCurrentMode('Exploration.Zoom');
    bool = true;
end

%-----------------------------------------------%
function [hZoom] = localGetRegisteredZoomObject(hManager,dopeek) %#ok

hFigure = hManager.FigureHandle;

% TBD Get Zoom object from Figure Tool Manager
hMode = locGetMode(hManager);
hZoom = hMode.ModeStateData.ZoomObject;
if isempty(hZoom) || ~isa(hZoom,'graphics.zoom')
    hZoom = graphics.zoom(hFigure);
    hMode.ModeStateData.ZoomObject = hZoom;
end

%-----------------------------------------------%
function localRegisterZoomObject(hFigure,hZoom) %#ok
hZoom.FigureHandle = hFigure;
hManager = uigetmodemanager(hFigure);
hMode = locGetMode(hManager);
hMode.ModeStateData.ZoomObject = hZoom;

%-----------------------------------------------%
function localSetNewZoom(bool) %#ok

setappdata(0,'NewZoomImplementation',bool);

%-----------------------------------------------%
function [target,action,action_data] = localParseArgs(varargin)

target = []; %#ok
action = [];
action_data = [];
errstr = {'Zoom:InvalidSyntax','Invalid Syntax'};
target = get(0,'CurrentFigure');

% zoom
if nargin==0
    action = 'toggle';

elseif nargin==1
    arg1 = varargin{1};

    % zoom(SCALE)
    if all(size(arg1)==[1,1]) && isnumeric(arg1)
        action = 'scale';
        action_data = arg1;

        % zoom(OPTION)
    elseif ischar(arg1)
        action = arg1;

        % zoom(FIG)
        % zoom(HZOOM)
        %elseif ishandle(arg1)
    elseif any(ishandle(arg1))
        if isa(handle(arg1),'graphics.zoom')
            target = get(arg1,'target');
            action = 'setzoom';
        elseif isa(handle(arg1),'hg.figure')
            target = arg1;
            action = 'toggle';
        end
    else
        error(errstr{:});
    end


elseif nargin==2

    % zoom('newzoom',0)
    if ischar(varargin{1})
        action = varargin{1};
        action_data = varargin{2};

        % zoom(FIG,SCALE)
        % zoom(FIG,OPTION)
        %elseif ishandle(varargin{1})
    elseif any(ishandle(varargin{1}))
        target = varargin{1};
        arg2 = varargin{2};
        if ischar(arg2)
            action = arg2;
        elseif isnumeric(arg2)
            action = 'scale';
            action_data = arg2;
        end
    end

    % zoom(FIG,<paramater/value pairs>);
elseif nargin>=3
    target = varargin{1};
    arg2 = varargin{2};
    %if ~isempty(target) && ishandle(target) && ischar(arg2)
    if any(ishandle(target)) && ischar(arg2)
        action = 'setzoomproperties';
        action_data = {varargin{2:end}};
    end
end

target = handle(target);

%-----------------------------------------------%
function localSetV6Zoom(bool)
setappdata(0,'V6Zoom',bool);

%-----------------------------------------------%
function [bool] = localIsV6Zoom
bool = getappdata(0,'V6Zoom');

%-----------------------------------------------%
function [hMode] = locGetMode(manager)
hMode = getMode(manager,'Exploration.Zoom');
if isempty(hMode)
    hMode = newMode(manager,'Exploration.Zoom');
    set(hMode,'WindowButtonDownFcn',{@localWindowButtonDownFcn,hMode});
    set(hMode,'WindowButtonUpFcn',[]);
    set(hMode,'WindowButtonMotionFcn',{@localMotionFcn,hMode});
    set(hMode,'KeyPressFcn',{@localKeyPressFcn,hMode});
    set(hMode,'ModeStartFcn',{@localStartZoom,hMode});
    set(hMode,'ModeStopFcn',{@localStopZoom,hMode});
    hMode.ModeStateData.ZoomObject = [];
end

%---------------------------------------------------------------------%
function localStartZoom(hMode)

hFigure = hMode.FigureHandle;
hZoom = hMode.ModeStateData.ZoomObject;

%Refresh context menu
hui = get(hMode,'UIContextMenu');
if ishandle(hZoom.UIContextMenu)
    set(hMode,'UIContextMenu',hZoom.UIContextMenu);
elseif ishandle(hui)
    delete(hui);
    set(hMode,'UIContextMenu','');
end

set(hMode,'WindowButtonUpFcn',[])
set(hFigure,'PointerShapeHotSpot',[5 5]);

% Turn on Zoom UI (i.e. toolbar buttons, menus)
% This must be called AFTER uiclear to avoid uiclear state munging
zoom_direction = get(hZoom,'Direction');
switch zoom_direction
    case 'in'
        localUISetZoomIn(hFigure);
    case 'out'
        localUISetZoomOut(hFigure);
end

set(hZoom,'IsOn',true);

% Define appdata to avoid breaking code in
% scribefiglisten, hgsave, and figtoolset
setappdata(hFigure,'ZoomOnState','on');

%---------------------------------------------------------------------%
function localStopZoom(hMode)

hZoom = hMode.ModeStateData.ZoomObject;
hFigure = hZoom.FigureHandle;

%Edge case, we turn off the zoom while in drag-mode:
hLines = get(hZoom,'LineHandles');
if any(ishandle(hLines))
    delete(hLines);
end

% Turn off Zoom UI (i.e. toolbar buttons, menus)
localUISetZoomOff(hFigure);

% Remove uicontextmenu
hui = get(hMode,'UIContextMenu');
if (~isempty(hui) && ishandle(hui)) && ...
        (isempty(hZoom.UIContextMenu) || ~ishandle(hZoom.UIContextMenu))
    delete(hui);
end

set(hZoom,'IsOn',false);

% Remove appdata to avoid breaking code in
% scribefiglisten, hgsave, and figtoolset
if isappdata(hFigure,'ZoomOnState');
    rmappdata(hFigure,'ZoomOnState');
end

%%%%% INSERT CALLBACK CODE HERE %%%%%

% This code gets executes when you deselect the zoom button at the top
% of the figure window

try
    Zoom_Callback();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------%
function localWindowButtonDownFcn(hFigure,evd,hMode) %#ok

hZoom = hMode.ModeStateData.ZoomObject;

if ~any(ishandle(hZoom))
    return;
end

fig_sel_type = get(hFigure,'SelectionType');
fig_mod = get(hFigure,'CurrentModifier');

hAxes = findaxes(hZoom);

if (isempty(hAxes)) || ~localInBounds(hAxes)
    if strcmp(fig_sel_type,'alt')
        hMode.ShowContextMenu = false;
    end
    return;
end

switch (lower(fig_sel_type))
    case 'alt' % right click
        % display context menu
        localGetContextMenu(hMode);
    otherwise % left click, center click, double click
        % Zoom out if user clicked on 'alt' or shift
        % ToDo: Remove "alt" in a future release
        if ~isempty(fig_mod) && ...
                (strcmp(fig_mod,'alt') || strcmp(fig_mod,'shift'))
            resetplotview(findaxes(hZoom),'InitializeCurrentView');
            switch get(hZoom,'Direction')
                case 'in'
                    applyzoomfactor(hZoom,findaxes(hZoom),.4);
                case 'out'
                    applyzoomfactor(hZoom,findaxes(hZoom),2.5);
            end
            % Delegate to registered zoom object
        else
            buttondownfcn(hZoom);
        end
end

%-----------------------------------------------%
function localMotionFcn(obj,evd,hMode) %#ok

hFigure = evd.Source;
hZoom = hMode.ModeStateData.ZoomObject;
% Get current point in figure units
curr_units = hgconvertunits(hFigure,[0 0 evd.CurrentPoint],...
    'pixels',get(hFigure,'Units'),hFigure);
curr_units = curr_units(3:4);

if any(ishandle(hZoom))
    set(hFigure,'CurrentPoint',curr_units);
    hAx = locFindAxes(hFigure);
    if ~isempty(hAx) && localInBounds(hAx)
        if strcmp(get(hZoom,'Direction'),'in')
            setptr(hFigure,'glassplus');
        else
            setptr(hFigure,'glassminus');
        end
    else
        setptr(hFigure,'arrow');
    end
end

%-----------------------------------------------%
function localKeyPressFcn(hFigure,evd,hMode) %#ok

% Delegate to registered zoom object
hZoom = hMode.ModeStateData.ZoomObject;
if any(ishandle(hZoom))
    keypressfcn(hZoom,evd);
end

%-----------------------------------------------%
function [hui] = localUICreateDefaultContextMenu(hMode)
% Create default context menu
hZoom = hMode.ModeStateData.ZoomObject;
hFig = get(hMode,'FigureHandle');
props_context.Parent = hFig;
props_context.Tag = 'ZoomContextMenu';
props_context.Callback = {@localUIContextMenuCallback,hMode};
props_context.ButtonDown = {@localUIContextMenuCallback,hMode};
hui = uicontextmenu(props_context);

% Generic attributes for all zoom context menus
props.Callback = {@localUIContextMenuCallback,hMode};
props.Parent = hui;

props.Label = 'Zoom Out       Shift-Click';
props.Tag = 'ZoomInOut';
props.Separator = 'off';
uzoomout = uimenu(props); %#ok

% Full View context menu
props.Label = 'Reset to Original View';
props.Tag = 'ResetView';
props.Separator = 'off';
ufullview = uimenu(props); %#ok

% Zoom Constraint context menu
props.Callback = '';
props.Label = 'Zoom Options';
props.Tag = 'Constraint';
props.Separator = 'on';
uConstraint = uimenu(props);

props.Parent = uConstraint;

props.Callback = {@localUIContextMenuCallback,hMode};
props.Label = 'Unconstrained Zoom';
props.Tag = 'ZoomUnconstrained';
props.Separator = 'off';
uimenu(props);

props.Label = 'Horizontal Zoom (2-D Plots Only)';
props.Tag = 'ZoomHorizontal';
uimenu(props);

props.Label = 'Vertical Zoom (2-D Plots Only)';
props.Tag = 'ZoomVertical';
uimenu(props);

localUIContextMenuUpdate(hZoom,get(hZoom,'Constraint'));

%-----------------------------------------------%
function localGetContextMenu(hMode)
% Create context menu

hui = get(hMode,'UIContextMenu');
hZoom = hMode.ModeStateData.ZoomObject;

if isempty(hui) || ~ishandle(hui)
    hui = localUICreateDefaultContextMenu(hMode);
    set(hMode,'UIContextMenu',hui);
end
if isempty(hZoom.UIContextMenu) || ~ishandle(hZoom.UIContextMenu)
    localUIUpdateContextMenuLabel(hMode);
end
drawnow expose;

%-------------------------------------------------%
function localUIContextMenuCallback(obj,evd,hMode) %#ok
hZoom = hMode.ModeStateData.ZoomObject;
tag = get(obj,'tag');

switch(tag)
    case 'ZoomInOut'
        resetplotview(findaxes(hZoom),'InitializeCurrentView');
        switch get(hZoom,'Direction')
            case 'in'
                applyzoomfactor(hZoom,findaxes(hZoom),0.4);
            case 'out'
                applyzoomfactor(hZoom,findaxes(hZoom),2.5);
        end
    case 'ResetView'
        hAxes = findaxes(hZoom);
        resetplotview(hAxes,'ApplyStoredView');
    case 'ZoomContextMenu'
        localUIContextMenuUpdate(hZoom,get(hZoom,'Constraint'));
    case 'ZoomUnconstrained'
        localUIContextMenuUpdate(hZoom,'none');
    case 'ZoomHorizontal'
        localUIContextMenuUpdate(hZoom,'horizontal');
    case 'ZoomVertical'
        localUIContextMenuUpdate(hZoom,'vertical');
end

%-------------------------------------------------%
function localUIContextMenuUpdate(hZoom,zoom_Constraint)

hFigure = get(hZoom,'FigureHandle');
ux = findall(hFigure,'Tag','ZoomHorizontal','Type','UIMenu');
uy = findall(hFigure,'Tag','ZoomVertical','Type','UIMenu');
uxy = findall(hFigure,'Tag','ZoomUnconstrained','Type','UIMenu');

switch(zoom_Constraint)

    case 'none'
        set(hZoom,'Constraint','none');
        set(ux,'checked','off');
        set(uy,'checked','off');
        set(uxy,'checked','on');

    case 'horizontal'
        set(hZoom,'Constraint','horizontal');
        set(ux,'checked','on');
        set(uy,'checked','off');
        set(uxy,'checked','off');

    case 'vertical'
        set(hZoom,'Constraint','vertical');
        set(ux,'checked','off');
        set(uy,'checked','on');
        set(uxy,'checked','off');
end

%-----------------------------------------------%
function localUISetZoomIn(fig)
set(uigettoolbar(fig,'Exploration.ZoomIn'),'State','on');
set(uigettoolbar(fig,'Exploration.ZoomOut'),'State','off');

%-----------------------------------------------%
function localUISetZoomOut(fig)
h = findall(fig,'type','uitoolbar');
set(uigettool(h,'Exploration.ZoomIn'),'State','off');
set(uigettool(h,'Exploration.ZoomOut'),'State','on');

%-----------------------------------------------%
function localUISetZoomOff(fig)
h = findall(fig,'type','uitoolbar');
set(uigettool(h,'Exploration.ZoomIn'),'State','off');
set(uigettool(h,'Exploration.ZoomOut'),'State','off');

% Remove the following lines after UITOOLBARFACTORY API is on by default
set(findall(fig,'Tag','figToolZoomIn'),'State','off');
set(findall(fig,'Tag','figToolZoomOut'),'State','off');

%-----------------------------------------------%
function localUIUpdateContextMenuLabel(hMode)

hZoom = hMode.ModeStateData.ZoomObject;
h = findobj(get(hMode,'UIContextMenu'),'Tag','ZoomInOut');
zoom_direction = get(hZoom,'Direction');
if strcmp(zoom_direction,'in')
    set(h,'Label','Zoom Out       Shift-Click');
else
    set(h,'Label','Zoom In        Shift-Click');
end

%-----------------------------------------------%
function targetInBounds = localInBounds(hAxes)
%Check if the user clicked within the bounds of the axes. If not, do
%nothing.
targetInBounds = true;
tol = 3e-16;
cp = get(hAxes,'CurrentPoint');
XLims = get(hAxes,'XLim');
if ((cp(1,1) - min(XLims)) < -tol || (cp(1,1) - max(XLims)) > tol) && ...
        ((cp(2,1) - min(XLims)) < -tol || (cp(2,1) - max(XLims)) > tol)
    targetInBounds = false;
end
YLims = get(hAxes,'YLim');
if ((cp(1,2) - min(YLims)) < -tol || (cp(1,2) - max(YLims)) > tol) && ...
        ((cp(2,2) - min(YLims)) < -tol || (cp(2,2) - max(YLims)) > tol)
    targetInBounds = false;
end
ZLims = get(hAxes,'ZLim');
if ((cp(1,3) - min(ZLims)) < -tol || (cp(1,3) - max(ZLims)) > tol) && ...
        ((cp(2,3) - min(ZLims)) < -tol || (cp(2,3) - max(ZLims)) > tol)
    targetInBounds = false;
end

%-----------------------------------------------%
function [ax] = locFindAxes(fig)
% Return the axes that the mouse is currently over
% Return empty if no axes found (i.e. axes has hidden handle)

if ~ishandle(fig)
    return;
end

% Return all axes under the current mouse point
allHit = hittest(fig,'axes');
allAxes = findobj(allHit,'flat','Type','Axes','HandleVisibility','on');
ax = [];

for i=1:length(allAxes),
    candidate_ax=allAxes(i);

    b = hggetbehavior(candidate_ax,'Zoom','-peek');
    if ~isempty(b) &&  ishandle(b) && ~get(b,'Enable')
        % ignore this axes

        % 'NonDataObject' is a legacy flag defined in
        % datachildren m-file.
    elseif ~isappdata(candidate_ax,'NonDataObject')
        ax = candidate_ax;
        break;
    end
end
