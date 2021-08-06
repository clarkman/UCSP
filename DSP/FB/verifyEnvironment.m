function success = verifyEnvironment(fbDir)
% function success = verifyEnvironment(fbDir)

dirExist = exist(fbDir,'dir');
if( dirExist ~= 7 )
    [status, cmdResult] = system( ['mkdir ' fbDir] );
    if( status ~= 0 )
        display(['Error Creating Directory: ' fbDir] );
        display(cmdResult);
        display('ENVIRONMENT')
        success = false;
        return
    end
end

success = true;
return
