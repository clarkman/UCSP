function Zoom_Callback()
% Callback for zooming plots

typer = get( gcf, 'UserData' );

switch typer
    case 9
        plotZoomer( TimeData, typer );
    case 10
        display( 'Plot type 10 axis scaling not implemented yet!' );
    case 11
        display( 'Plot type 11 axis scaling not implemented yet!' );
    case 12
        display( 'Plot type 12 axis scaling not implemented yet!' );
    case 14
        plotZoomer( TimeData, typer );
end

% ORIG from Matlab
%set(gca,'XTickMode','manual');
%set(gca,'XTick',2:2:10);
