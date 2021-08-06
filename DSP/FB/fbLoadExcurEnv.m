function varargout = fbLoadExcurEnv(network)
% function [fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir,fbExcurPointsDir,fbExcurPlotDir,fbExcurLogDir,fbLimitDir] = fbLoadExcurEnv(network)
% 
% Returns the names of the following directories (in this order):
%   fbDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs
%   fbStatDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs/stats
%   kpTxtFileName - /mnt/Inetpub/Kp/KpRecent.mat
%   kpMatFileName - /mnt/Inetpub/Kp/KpRecent.txt
%   fbExcurDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs/excursions
%   fbExcurPointsDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs/excursions/excursionPoints
%   fbExcurPlotDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs/excursions/dailyPlots
%   fbExcurLogDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs/excursions/DBEntryLog
%   fbLimitDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs/limits
%   fbSmoothDir - /mnt/CalMagNet/cmnProducts/dataCenterOutput/fbs/smoothedData
% 

nout = nargout;

% Network
NETWORKS = {'BK' 'BKQ' 'CMN'};
network = upper(network);
if( isempty( find( strcmpi( NETWORKS, network ),1 ) ) )
    display([ 'Unknown network: ' network ] );
    display('USAGE')
    for iout = 1:nout
        varargout(iout) = { 'ERROR' };
    end
    return
end



% Create Env Variables
[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );
fbExcurDir = [fbDir '/excursions'];
fbExcurPointsDir = [fbExcurDir '/excursionPoints'];
fbExcurPlotDir = [fbExcurDir '/dailyPlots'];
fbExcurLogDir = [fbExcurDir '/DBEntryLog'];
fbLimitDir = [fbDir '/limits'];
fbSmoothDir = [fbDir '/smoothedData'];

% Create directories if they don't already exist
success = verifyEnvironment(fbDir);
success = success && verifyEnvironment(fbStatDir);
success = success && verifyEnvironment(fbExcurDir);
success = success && verifyEnvironment(fbExcurPointsDir);
success = success && verifyEnvironment(fbExcurPlotDir);
success = success && verifyEnvironment(fbExcurLogDir);
success = success && verifyEnvironment(fbLimitDir);
success = success && verifyEnvironment(fbSmoothDir);
if( ~success )
    for iout = 1:nout
        varargout(iout) = { 'ERROR' };
    end
    return
end

for iout = 1:nout
    switch iout
        case 1
            varargout(iout) = { fbDir };
        case 2
            varargout(iout) = { fbStatDir };
        case 3
            varargout(iout) = { kpTxtFileName };
        case 4
            varargout(iout) = { kpMatFileName };
        case 5
            varargout(iout) = { fbExcurDir };
        case 6
            varargout(iout) = { fbExcurPointsDir };
        case 7
            varargout(iout) = { fbExcurPlotDir };
        case 8
            varargout(iout) = { fbExcurLogDir };
        case 9
            varargout(iout) = { fbLimitDir };
        case 10
            varargout(iout) = { fbSmoothDir };
        otherwise
            varargout(iout) = { 'UNKNOWN OUTPUT' };
    end
end

return
