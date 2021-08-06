function success = saveFBExcurPlot(fileName)
%
% function success = saveFBExcurPlot(fileName)
%
% Saves the current figure as a .gif file with name given by filename,
% which is the absolute path of the file WITHOUT the file extension.
%

RESIZE   = '760x440!';
QUALITY  = 80;

% Values for attempts to save
nAttempts = 3;

try
    fNamePng = sprintf('%s.png',fileName);
    fNameGif = sprintf('%s.gif',fileName);
    saveas(gcf,fNamePng,'png');
    
    cmd = sprintf( 'chmod a+w %s', fNamePng );
    k = 1;
    retry = 1;
    while( retry && (k <= nAttempts) )
        retry = 0;
        k = k + 1;
        [status,result] = system( cmd );
        if( status )
            display(sprintf('Error with Command: %s',cmd))
            display(sprintf('Result: %s',result))
            retry = 1;
        end
    end
    if( status )
        disp('Maximum Number of Attempts tried')
        error('Error Forced')
    end

    % system( sprintf( 'convert %s %s ', fNamePng, fNameGif ) );
    % system( sprintf( 'convert -resize %s -quality %d %s %s ', RESIZE, QUALITY, fNameGif, fNameGif ) );
    
    cmd = sprintf( 'convert %s -resize %s -quality %d %s', fNamePng, RESIZE, QUALITY, fNameGif );
    k = 1;
    retry = 1;
    while( retry && (k <= nAttempts) )
        retry = 0;
        k = k + 1;
        [status,result] = system( cmd );
        if( status )
            display(sprintf('Error with Command: %s',cmd))
            display(sprintf('Result: %s',result))
            retry = 1;
        end
    end
    if( status )
        disp('Maximum Number of Attempts tried')
        error('Error Forced')
    end
    
    cmd = sprintf( 'rm %s', fNamePng );
    k = 1;
    retry = 1;
    while( retry && (k <= nAttempts) )
        retry = 0;
        k = k + 1;
        [status,result] = system( cmd );
        if( status )
            display(sprintf('Error with Command: %s',cmd))
            display(sprintf('Result: %s',result))
            retry = 1;
        end
    end
    if( status )
        disp('Maximum Number of Attempts tried')
        error('Error Forced')
    end
catch
    display(['Error saving file: ' fileName])
    display('BAD_WRITE')
    success = -1;
    return
end

success = 0;
return