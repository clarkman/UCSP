function success = verifyFBEnvironment(fbDir)
% function success = verifyFBEnvironment(fbDir)

dirExist = exist(fbDir,'dir');
if( dirExist ~= 7 )
    [status, cmdResult] = system( ['mkdir ' fbDir] );
    if( status ~= 0 )
        display(['Error Creating Directory: ' fbDir] );
        display(cmdResult);
        display('ENVIRONMENT')
        success = -1;
        return
    end
end

success = 0;
return