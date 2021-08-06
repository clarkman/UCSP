function success = logFBExcursionToFile(outFileName,startTime,endTime,eventType,subEventType,limitValue,excurOut,excurIn,excurRow,network,station,channel,band,pointsOut,pointsIn,energyOut,energyIn,ambigStart,ambigEnd)
% function success = logFBExcursionToFile(outFileName,startTime,endTime,eventType,subEventType,limitValue,excurOut,excurIn,excurRow,network,station,channel,band,pointsOut,pointsIn,energyOut,energyIn,ambigStart,ambigEnd)
% 
% Logs an excursion to the file given by outFileName. Each line in the text
% file is an excursion entry that will be added to the database table
% "daily_FB_excursions". Each entry has FIELDS described below. Each field
% entry is separated by "|" with no spaces.
% 
% NOTE: We should probably add a field for status as actual or estimated.
% This would be based on the Kp value and could be used to determine what
% points need to be remade. Adding this field would require a change to
% 'addFBEvents.plx', the "daily_FB_excursions" table, and 
% 'createFBExcurOutFile.m'.
%
% FIELDS:
% StartTime|EndTime|Duration|CreationTime|EventType|SubEventType|DataSourceNetwork|DataSourceStation|DataSourceChannel|DataSourceFBBand|NumberOfPointsTotal|NumberOfPointsOut|NumberOfPointsIn|EnergyTotal|EnergyOut|EnergyIn|AmbiguousStart|AmbiguousEnd
% StartTime - excursion start time in UTC, SQL format (2008-03-24 22:15:00)
% EndTime - excursion end time in UTC, SQL format (2008-03-24 23:45:00)
% Duration - length of excursion in milliseconds
% CreationTime - time that excursion is logged in UTC, SQL format
% EventType - FB, mean v. median (FB_MEAN or FB_MEDIAN)
% SubEventType - ABOVE, BELOW, EXCLUSION 
% LimitValue - PERCENTILE_75,SIGMA_2
% ExcurCriteriaOut - number of points out of limit for an excursion
% ExcurCriteriaIn - number of points within limit to end an excursion
% ExcurCriteriaRow - do points within limit occur in a row? (T,F,either)
% network - CMN, BK, BKQ
% sid - site number
% channel - channel number
% FBBand - band number
% NumPointsTotal - total number of points in the excursion
% NumPointsOut - number of points in the excursion out of limits
% NumPointsIn - number of points in the excursion in limit
% EnergyTotal - total energy out of limit during the excursion
% EnergyOut - total energy out of limit for points out of limits
% EnergyIn - total energy within limit for points in limit
% AmbiguousStart - BAD_DATA, BAD_LIMIT before excursion
% AmbiguousEnd - BAD_DATA, BAD_LIMIT after excursion
% InferredStart - 0: nothing, 1: BAD_DATA or BAD_LIMIT
% InferredEnd - 0: nothing, 1: BAD_DATA or BAD_LIMIT
% 
% Input Arguments
% outFileName - string containing the absolute path and name of output file
% startTime - datenum of excursion start time in UTC
% endTime - datenum of excursion end time in UTC
% eventType - 'mean' or 'median'
% subEventType - 'ABOVE' or 'BELOW'
% limitValue - percentage (25,75,etc) or sigma (1,2,3,etc)
% excurOut - number of points out of limit for an excursion to occur
% excurIn - number of points within limit to end an excursion
% excurRow - do points within limit need to occur in a row?
% network - CMN, BK, BKQ
% station - station ID as a string
% channel - 1:4
% band - 1:13
% pointsOut - total number of points out of limit
% pointsIn - total number of points in limit
% energyOut - energy associated with pointsOut ( > 0 )
% energyIn - energy associated with pointsIn ( > 0 )
% ambigStart - -1,-2: BAD_DATA; -3,-4: BAD_LIMIT
% ambigEnd - -1,-2: BAD_DATA; -3,-4: BAD_LIMIT

% Time Information
sT = datenum2str(startTime,'sql');
eT = datenum2str(endTime,'sql');
dur = floor((endTime - startTime) * 86400)*100;
cT = datenum2str(now+8/24,'sql');

% Event/SubEvent type
SubEventType = subEventType;
if( strcmpi( eventType, 'MEAN' ) ),
    EventType = 'FB_MEAN';
    LimitValue = sprintf('SIGMA_%d',limitValue);
elseif( strcmpi( eventType, 'MEDIAN' ) ),
    EventType = 'FB_MEDIAN';
    LimitValue = sprintf('PERCENTILE_%d',limitValue);
else
    EventType = 'FB_INDETERMINATE';
    SubEventType = 'EXCLUSION';
    LimitValue = 'INDETERMINATE';
end

% Excursion Criteria - points in a row
if( excurIn == 1 )
    excurRow = 'EITHER';
elseif( excurRow )
    excurRow = 'TRUE';
else
    excurRow = 'FALSE';
end

% Event Information
network = upper(network);
% if( strcmpi( network, 'CMN' ) )
%     station = sprintf('%d',station);
% end
pointsTotal = pointsOut + pointsIn;
energyTotal = energyOut - energyIn;
if( ambigStart < 0 )
    if( ambigStart >= -2 )
        AmbigStart = 'BAD_DATA';
    elseif( ambigStart >= -4 )
        AmbigStart = 'BAD_LIMIT';
    elseif( ambigStart == -5 )
        AmbigStart = 'EXCLUSION_TIME';
    else
        AmbigStart = 'INDETERMINATE';
    end
    InferredStart = '1';
else
    AmbigStart = 'NONE';
    InferredStart = '0';
end
if( ambigEnd < 0 )
    if( ambigEnd >= -2 )
        AmbigEnd = 'BAD_DATA';
    elseif( ambigEnd >= -4 )
        AmbigEnd = 'BAD_LIMIT';
    elseif( ambigEnd == -5 )
        AmbigEnd = 'EXCLUSION_TIME';
    else
        AmbigEnd = 'INDETERMINATE';
    end
    InferredEnd = '1';
else
    AmbigEnd = 'NONE';
    InferredEnd = '0';
end

% Create line to be written to file
entry = [ sT '|' eT '|' sprintf('%d',dur) '|' cT '|' ...
    EventType '|' SubEventType '|' LimitValue '|'  ... 
    sprintf('%d',excurOut) '|' sprintf('%d',excurIn) '|' excurRow '|'  ... 
    network '|' station '|' sprintf('%d',channel) '|' sprintf('%d',band) '|' ...
    sprintf('%d',pointsTotal) '|' sprintf('%d',pointsOut) '|' ...
    sprintf('%d',pointsIn) '|' sprintf('%f',energyTotal) '|' ...
    sprintf('%f',energyOut) '|' sprintf('%f',energyIn) '|' ...
    AmbigStart '|' AmbigEnd '|' InferredStart '|' InferredEnd '\n' ];

% Open file for append and read
[fid,message] = fopen(outFileName,'a+');
if( fid < 0 )
    disp(message)
    success = fid;
    return
end

% % Read last entry to ensure it is not the same as the entry to be added
% status = fseek(fid,0,'bof');
% if( status < 0 )
%     disp('Unable to move to beginning of file')
%     success = status;
%     return
% end
% feof = 0;
% while( ~feof )
%     currPos = ftell(fid);
%     currLine = fget1(fid);
%     if( ~ischar(currLine) )
%         feof = 1;
%     end
%     prevPos = currPos;
%     prevLine = currLine;
% end % while
% 
% prevStartTime = strtok(prevLine,'|');
% if( strcmpi(startTime,prevStartTime) )  % entry to be added has same start time as last entry -> overwrite!
%     if( prevPos < 0 )
%         disp('Unable to determine location of last entry in file')
%         success = prevPos;
%         return
%     end
%     status = fseek(fid,prevPos,'bof');  % Move to beginning of last entry
% else                                    % append entry to end of file
%     status = fseek(fid,0,'eof');        % Move to end of file
% end % if
% if( status < 0 )
%     disp('Unable to move to move to appropriate line of file')
%     success = status;
%     return
% end

% Write line to file
status = fseek(fid,0,'eof');    % Move to end of file
if( status < 0 )
    disp('Unable to move to end of file')
    success = status;
    return
end
status = fprintf(fid, entry);
if( status < 0 )
    disp('Unable to write to file')
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
return