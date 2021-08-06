function objects = readSQLObjectsFromFile(filename)
%
% Reads in SQL query results objects from the given SQL output file.
% The file must be in a format as follows:
%   First line is tab-delimited field names
%   Each subsequenct line has one object, with tab-delimited values
%     corresponding to the field names in the first line
% Returns a cell array of object structs

TAB = 9;    % The tab character

fid = fopen(filename, 'r');
if (fid == -1)
    display(['Cannot open the file ', filename]);
    objects = -1;
    return;
end
    
% Get and parse the first line containing the names of all the fields
tline = fgetl(fid);
if (tline == -1)
    % The file is empty, so no objects were returned from the query
    display('No objects returned from the query: No rows matching query');
    objects = -1;
    return;
end
fieldnames = parseDelimitedString(tline, TAB);
% XXX Clark Hack for eliminating leading underscores
for ith = 1 : length(fieldnames)
    daName = fieldnames{ith};
    underscores = strfind( daName, '_' );
    if( length(underscores) >= 1 && underscores(1) == 1 )
        fieldnames{ith} = daName(2:end);
    end
end

% Loop over the remaining lines to get the Signal Events
numObjs = 0;

while feof(fid) == 0
    tline = fgetl(fid);
    
    if (tline == -1)
        % End of file
        break;
    end
        
    values = parseDelimitedString(tline, TAB);
    obj = cell2struct(values, fieldnames, 2);
    
    numObjs = numObjs + 1;
    objects(numObjs) = {obj};
end
fclose(fid); 
