function arrayOut = readColumnFile( filename )
%
% Case-Sensitive, tab-delimited format:
% 
% TOKEN1 = blah
% TOKEN2 = blather
% HEADER_END
% LABELS = a	b   c
% 2.4	5.6 7.8
% 3.2	5.4 7.6
% 1.5	3.4 8.9
%
% Header is optional, but "LABELS = " must be exact
% and is mandatory.  Returned struct will have fields
% struct.a, struct.b, etc.

TAB = 9;    % The tab character

fid = fopen(filename, 'r');
if (fid == -1)
    display(['Cannot open the file ', filename]);
    return;
end

if 1

    tline = fgetl(fid);
    numColumns = length( parseDelimitedString(tline, TAB) );
    % Loop over the remaining lines to get the Signal Events
    numObjs = 0;
    while feof(fid) == 0
        tline = fgetl(fid);
        if (tline == -1)
            % End of file
            break;
        end
        numObjs = numObjs + 1;
    end
    frewind(fid);
    tline = fgetl(fid);
    arrayOut = zeros( numObjs, numColumns );
    for ith = 1 : numObjs
        tline = fgetl(fid);

        values = parseDelimitedString(tline, TAB);
        for jth = 1 : numColumns
            arrayOut(ith,jth) = values{jth};
        end
    end
    fclose(fid); 

else
    
    
    % Get and parse the first line containing the names of all the fields
    while feof(fid) == 0
        tline = fgetl(fid);
        if (tline == -1)
            display( 'No "LABELS = " line found in this file!' );
	    return;
        end
        if( strfind( tline, 'LABELS = ' ) > 0 )
            break;
        end
    end
    if( feof(fid) )
        display( 'No "LABELS = " line found in this file!' );
        return;
    end

    fieldnames = parseDelimitedString(tline(10:end), TAB);
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
        numObjs = numObjs + 1;
        inVals(numObjs,:) = values;
    end
    fclose(fid); 


    structOut = cell2struct(inVals', fieldnames', 1);

end

