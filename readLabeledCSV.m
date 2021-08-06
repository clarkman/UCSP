function  [ labels, values ] = readLabeledCSV( fName, numread )
%READLABELEDCSV Read in CSV file with labels in first row
%   Read in file fName and return labels as a {1,numCols}
%   and values as a {numRows,numCols}.

fid = fopen( fName );
if( fid == -1 )
    display([ 'File: |', fName, '| NOT FOUND'])
    return
end

% Discard labels
lbls = fgetl(fid);
labels = strsplit(lbls,',');
numcols = length(labels);

if nargin >= 2
    % Check file length
    for r = 1 : numread
        nextl = fgetl(fid);
        if ~ischar(nextl)
            warning(sprintf('Read only %d data rows',r))
            break
        end
    end
    display(sprintf('Read %d data rows',r))
else
    rowth = 0;
    while 1
        nextl = fgetl(fid);
        if ~ischar(nextl)
            display(sprintf('Read %d data rows',rowth))
            break
        end
        rowth = rowth + 1;
    end
end

frewind(fid);
fgetl(fid); % Step over hdr

if nargin < 2 
  outr = cell(rowth,numcols);
  numrows = rowth;
else
  outr = cell(numread,numcols);
  numrows = numread;
end  

rowth = 0;
for row =  1 : numrows
    nextl = fgetl(fid);
    if ~ischar(nextl)
        break
    end
    rowth = rowth + 1;
    row = strsplit( nextl, ',', 'CollapseDelimiters', false );
    if( numcols ~= length(row) )
        error(sprintf('Malformed CSV file at row %d. Header has %d cols, row has %d',rowth,numcols,length(row)))
    end
    for cth = 1 : numcols
        outr{rowth,cth} = row{cth};
    end
end

values = outr;
fclose( fid );
