function success = getFBExclusions(network)
% function success = getFBExclusions(network)
% 
% This file creates FBExculsions.mat located in fbs/excursions
% 
% The .mat file is created from the data table "e_CONTAMINATED_DATA"
% located under data_products. The file gives start/end times, station ID,
% and channel to exclude on.
% 

funcname = 'getFBExclusions.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

NEWLINE = char(10);

exclusions = [ ];

% network = 'CMN';
network = upper(network);

[fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir] = fbLoadExcurEnv(network);
fileExclusion = sprintf('%s/FBExclusions.mat',fbExcurDir);

% Run SQL Query to get additional earthquakes
display('Running SQL Query for Exclusions:')
queryString = ...
['use data_products;', NEWLINE, ...
 'select e_CONTAMINATED_DATA.DataSourceStation AS station,', NEWLINE, ...
 'e_CONTAMINATED_DATA.DataSourceChannel AS channel,', NEWLINE, ...
 'DATE_FORMAT(e_CONTAMINATED_DATA.StartTime,"%Y/%m/%d %H:%i:%S") AS startTime,', NEWLINE, ...
 'DATE_FORMAT(e_CONTAMINATED_DATA.EndTime,"%Y/%m/%d %H:%i:%S") AS endTime', NEWLINE, ...
 'FROM e_CONTAMINATED_DATA', NEWLINE, ...
 'WHERE e_CONTAMINATED_DATA.DataSourceNetwork = "', network, '"', NEWLINE];

display(sprintf('%sSQL Query String:%s%s',NEWLINE,NEWLINE,queryString))
try
    exObjects = SQLrunQuery( queryString, 'quakedata', 'matlab' );
catch
    try
        exObjects = SQLrunQuery( queryString, 'quakedata', 'matlab', fbExcurDir );
    catch
        display('Error with SQLrunQuery')
        success = false;
        return
    end
end

% Process Exclusions
if( iscell(exObjects) )
    nExclusions = length(exObjects);
    display(sprintf('%d Exclusions found',nExclusions))
    for iex = 1:nExclusions
        ex = exObjects{iex};
        exST = datenum(ex.startTime);
        exET = datenum(ex.endTime);
        % Adjust start and end time to fit with FB intervals
        stDay = floor(exST);    % day of start time
        etDay = floor(exET);    % day of end time
        stFrac = exST - stDay;  % fraction of day of start time
        etFrac = exET - etDay;  % fraction of day of end time
        stFB = 1/96 * floor( 96*stFrac ); % latest 15 min period before exclusion
        etFB = 1/96 * ceil( 96*etFrac ); % first 15 min period after exclusion
        exSTFB = stDay + stFB;
        exETFB = etDay + etFB;
        
        exclusions = [ exclusions; exSTFB, exETFB, ex.station, ex.channel, exST, exET ];
    end % end: for iquake = 1 : nQuakes
    exclusions = sortrows(exclusions,[3,1,2,4]); %#ok<NASGU>
    
    try
        cmd = sprintf('save %s exclusions',fileExclusion);
        eval(cmd)
        display('Exclusion data updated')
    catch
        display('Exclusion data failed to save')
        success = false;
        return
    end
else
    display('No Exclusions found')
end % end: if( iscell(exObjects) )

try
    cmd = sprintf('delete %s/tmp/SQLResult*',fbExcurDir);
    eval(cmd)
    display('Temporary files removed')
catch
    display('Failed to remove temporary files')
end

fend = now;
delta = (fend - fstart)*86400;
display(sprintf('%s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))

success = true;
return
