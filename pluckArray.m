function [ pluckedLabels, pluckedCell ] = pluckArray( labels, values, selected, selFormats )
%PLUCKVALS Pull values from structures (labels,values) made by readLabeledCSV()
%   Select and convert values from read-in CSV file.
%
%   ARGS:
%   labels: made by readLabeledCSV(), {1,numCols} in size.
%   values: made by readLabeledCSV(), {numRows,numCols} in size.
%   selected: a [1,n] array containing the chosen columns (or empty).
%   selFormats: a {1,n} array containing the chosen formats.  
%
%   Format strings are standard libc, with these exceptions:
%   'dn'    = Convert date string to datenum.
%   'lv'    = Convert Labview time to datenum.
%   'bool'  = Convert words true and false (any case) to 0 & 1.
%   'h16'   = Convert four hex characters (0-F) to decimal number (any case, prepended '0x' ok)
%   'float' = Convert to four byte floating point number.
%
%   Examples:
%
%   1. Convert everything to doubles:
%   pluckVals( labels, values )
%
%   2. Convert selected columns with format specifiers:
%   pluckVals( labels, values, [1, 2, 4, 7], { '%d', '%d', '%d', 'dn' } )
%
%   3. Convert all columns usgin specified formats:
%   pluckVals( labels, values, [], { '%d', '%d', '%d', '%g', '%g', 'dn' } )

% Count and check ...
sz = size(labels);
numLabels = sz(2);
sz = size(values);
numCols = sz(2);
numRows = sz(1);
if numCols ~= numLabels
    error( sprintf( 'Labels=%d and values column=%d count mismatch!', numLabels, numCols ) );
end

% Select all unless specified ...
if nargin < 3 || isempty( selected )
    selected = 1 : numCols;
    iscell(num2str(selected))
end
numSelected = length( selected );
plucked = zeros(numRows,numSelected);
plkLbls = cell(numSelected,1);
pluckedCell = cell(numSelected,1);

for s = 1 : numSelected
    arr = createArray( numRows, selFormats{s} );
    if iscell(arr)
        for r = 1 : numRows
            col = selected(s);
            if ~isempty(values{r,col})
                arr{r} = convertVal( values{r,col}, selFormats{s} );
            end
        end
    else
        for r = 1 : numRows
            col = selected(s);
            if ~isempty(values{r,col})
                %r
                %values{r,col}
                %selFormats{s}
                try
                    arr(r) = convertVal( values{r,col}, selFormats{s} );
                catch
                    values{r,col}
                    selFormats{s}
                    return
                end
            end
        end
    end
    pluckedCell{s} = arr;
end
for s = 1 : numSelected
    col = selected(s);
    plkLbls{s} = labels{col};
end

pluckedLabels = plkLbls;
pluckedArray = plucked;

end

