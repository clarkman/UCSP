function success = createFBExcurOutFile(outFile,startDate,endDate,network,sites,channels,bands,outLimNumbers,inLimNumbers,inLimInARow)
% function success = createFBExcurOutFile(outFile,startDate,endDate,network,sites,channels,bands,outLimNumbers,inLimNumbers,inLimInARow)
% 
% This function writes a header to the top of the excursion text file that
% describes the criteria used to determine if an excursion occurs. This
% text file temporarily stores the excursions until they are entered into
% the database table "daily_FB_excursions" using "addFBEvents.plx".
% 
% Input Arguments:
%   outFile - name of text file that the excursions are logged to
%   startDate - Start Date as string 'yyyy/mm/dd' in PST
%   endDate - End Date as string 'yyyy/mm/dd' in PST
%   network - 'CMN','BK', or 'BKQ' - only works with 'CMN' for now
%   sites - station numbers of stations that are being looked at
%   channels - [1:4] - channels to look for excursions on
%   bands - [1:13] - bands to look for excursions on
%   outLimNumbers - Number of points out-of-limit that must occur in a row for an excursion to occur
%   inLimNumbers - Number of points that must be in-limit to end an excursion
%   inLimInARow - Do all of the in-limit points have to be in a row to end an excursion?

display('Function: createFBExcurOutFile.m START')

%--------------------------------------------------------------------------
% Process Input Arguments

% Sites
siteStr = '[ ';
for isite = sites
    if( iscell(isite) )
        try
            jsite = char(isite);
        catch
            jsite = cell2mat(isite);
        end
    else
        jsite = isite;
    end
    
    if( ischar(jsite) )
        siteStr = sprintf('%s%s ',siteStr,jsite);
    else
        siteStr = sprintf('%s%d ',siteStr,jsite);
    end
    % siteStr = [siteStr sprintf('%d ',isite)];
end
siteStr = [siteStr ']'];

% Network
NETWORKS = {'BK' 'BKQ' 'CMN'};
network = upper(network);
if( isempty( find( strcmpi( NETWORKS, network ),1 ) ) )
    success = -1;
    display([ 'Unknown network: ' network ] );
    display('USAGE')
    return
end

% Bands
bandStr = '[ ';
for iband = bands
    bandStr = [bandStr sprintf('%d ',iband)];
end
bandStr = [bandStr ']'];

% Channels
chStr = '[ ';
for ich = channels
    chStr = [chStr sprintf('%d ',ich)];
end
chStr = [chStr ']'];

% Out Lim Numbers
outLimStr = '[ ';
for iOut = outLimNumbers
    outLimStr = [outLimStr sprintf('%d ',iOut)];
end
outLimStr = [outLimStr ']'];

% Out Lim Numbers
inLimStr = '[ ';
for iIn = inLimNumbers
    inLimStr = [inLimStr sprintf('%d ',iIn)];
end
inLimStr = [inLimStr ']'];

if( inLimInARow )
    inRow = 'TRUE';
else
    inRow = 'FALSE';
end
%--------------------------------------------------------------------------

DBTable = 'daily_FB_excursions';

% Make Header and Field Columns for file
header = ['File name: ' outFile '\n' 'DataBase Table: ' DBTable '\n'...
    'Start Date: ' startDate '\n' 'End Date: ' endDate  '\n'...
    'Stations: ' siteStr '\n' 'Bands: ' bandStr '\n' 'Channels: ' chStr '\n' ...
    'Number of Points Out-Of-Limit (In A Row) for Excursion to Occur: ' outLimStr '\n' ...
    'Number of Points Within Limit for Excursion to End: ' inLimStr '\n' ...
    'Points Within Limit Must Occur In A Row: ' inRow '\n\n'];
fields = ['StartTime|EndTime|Duration|CreationTime|EventType|SubEventType|' ...
    'LimitValue|ExcurCriteriaOut|ExcurCriteriaIn|ExcurCriteriaRow|' ...
    'network|sid|channel|FBBand|NumPointsTotal|NumPointsOut|'... 
    'NumPointsIn|EnergyTotal|EnergyOut|EnergyIn|AmbiguousStart|' ... 
    'AmbiguousEnd|InferredStart|InferredEnd' '\n'];

% Open file for write and read - erases all contents of file
[fid,message] = fopen(outFile,'w+');
if( fid < 0 )
    disp(['Problem Opening File: ' outFile])
    disp(message)
    success = fid;
    return
end

% Write to File
status = fprintf(fid, [header fields]);
if( status < 0 )
    disp('Unable to write header to file')
    success = status;
    return
end

% Close file
status = fclose(fid);
if( status < 0 )
    disp('Unable to close file')
    success = status;
    return
end

success = 0;
display('Function: createFBExcurOutFile.m END')
return