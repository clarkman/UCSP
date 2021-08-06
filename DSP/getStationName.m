function stationName = getStationName(fileName)
% function stationName = getStationName(fileName)
% 
% This function returns the station name based on the input file name. If
% the file name starts with "CMN" the station is on the CMN network and is
% of the format: "CMN###_StationName###". Otherwise, the file name and the
% station name are the same.
% 



% Check if first 3 characters are "CMN"
if( strncmp(fileName,'CMN',3) )
    % File Name should be of format: "CMN###_StationName###"
    
    % Get length of fileName
    nChars = length(fileName);
    
    % Character numbers of station name start and end
    startChar = 8;
    endChar = nChars - 3;
    
    try
        stationName = fileName(startChar:endChar);
    catch
        stationName = fileName;
    end
else
    stationName = fileName;
end

return
