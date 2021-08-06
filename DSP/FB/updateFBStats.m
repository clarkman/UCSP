function success = updateFBStats( site, network, useMatFile, cleanDataLevel )
% function success = updateFBStats( site, network, useMatFile, cleanDataLevel )
% 
% This function calls fbmedian.m, which updates the stats for the input
% arguments given. This function then saves the output of fbmedian.m to the
% appropriate .mat file, which is used for FB limit generation.
% 

% Process Input Arguments
network = upper(network);

% Get Stat Directory
[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );

% Generate fbmedian command, and save command based on network
filename = sprintf('%s',fbStatDir);
if( strcmpi( network, 'CMN' ) )
    cmd = sprintf('[data%d stats%d kp_arr%d season%d] = fbmedian(%d,''%s'',%d,%d);', ...
        site,site,site,site,site,network,useMatFile,cleanDataLevel);
    filename = [filename sprintf('/summary-%d.mat',site)];
    saveCMD = sprintf('save %s data%d stats%d kp_arr%d season%d', ...
        filename,site,site,site,site);
    validStatCMD = sprintf('stats = stats%d',site);
elseif( strcmpi( network, 'BK' ) )
    cmd = sprintf('[data%s stats%s kp_arr%s season%s] = fbmedian(''%s'',''%s'',%d,%d);', ...
        site,site,site,site,site,network,useMatFile,cleanDataLevel);
    filename = [filename sprintf('/summary-%s.mat',site)];
    saveCMD = sprintf('save %s data%s stats%s kp_arr%s season%s', ...
        filename,site,site,site,site);
    validStatCMD = sprintf('stats = stats%s',site);
elseif( strcmpi( network, 'BKQ' ) )
    cmd = sprintf('[data%s stats%s kp_arr%s season%s] = fbmedian(''%s'',''%s'',%d,%d);', ...
        site,site,site,site,site,network,useMatFile,cleanDataLevel);
    filename = [filename sprintf('/summaryQuiet-%s.mat',site)];
    saveCMD = sprintf('save %s data%s stats%s kp_arr%s season%s', ...
        filename,site,site,site,site);
    validStatCMD = sprintf('stats = stats%s',site);
else
    display(sprintf('Error: Invalid network - %s',network))
    display('USAGE')
    success = -1;
    return
end % if( strcmpi( network, 'CMN' ) )

% Run fbmedian.m to generate Stats
try
    eval(cmd);
catch
    display('Error running fbmedian.m')
    display('FAILURE')
    success = -1;
    return
end

% Make sure stats are valid before trying to save
try
    eval(validStatCMD)
    
    dimStats = size(stats);
    dimStats = size(dimStats,2);
    for idim = 1:dimStats
        if( idim == 1 )
            statMax = max(stats);
            statMin = min(stats);
        else
            statMax = max(statMax);
            statMin = min(statMin);
        end
    end
catch
    display('Error checking stats')
    display('FAILURE')
    success = -1;
    return
end



% Save results from fbmedian.m to .mat file
if( statMax || statMin ) % Make sure stats are not all zeros
    try
        display(sprintf('Saving Stats .mat file: %s',filename))
        display(saveCMD)
        eval(saveCMD)
    catch
        display('Error saving Stats .mat file');
        display('BAD_WRITE')
        success = -1;
        return
    end
else
    display('Stats not calculated properly in fbmedian.m')
    display('Not saving stats')
end

display('SUCCESS')
success = 0;
return
