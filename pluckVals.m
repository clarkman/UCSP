function [ pluckedLabels, pluckedValues ] = pluckVals( labels, values, selected, selFormats )
%PLUCKVALS Pull values from structures (pluckedLabels,pluckedValues) made by readLabeledCSV()
%   Select and convert values from read-in CSV file.
%
%   ARGS:
%   labels: made by readLabeledCSV(), {1,numCols} in size.
%   values: made by readLabeledCSV(), {numRows,numCols} in size.
%   selected: a [1,n] array containing the chosen columns.
%   selFormats: a {1,n} array containing the chosen formats.  
%
%   Format strings are standard, with one special so far:
%   dn = Convert to datenum.
%
%   Example:
%   pluckVals( labels, values, [1, 2, 3, 4], { '%d', '%d', '%d', 'dn' } )

% Count and check ...
sz = size(labels);
numLabels = sz(2);
sz = size(values);
numCols = sz(2);
numRows = sz(1);
if numCols ~= numLabels
    error('Labels and values column count mismatch!')
end

% Select all unless specified ...
if nargin < 3
    selected = 1 : numCols;
    iscell(num2str(selected))
end
numSelected = length( selected );
plucked = cell(numRows,numSelected);
plkLbls = cell(numSelected,1);

for r = 1 : numRows
    for s = 1 : numSelected
        col = selected(s);
        if ~isempty(values{r,col})
        	plucked{r,s} = convertVal( values{r,col}, selFormats{s} );
        end
    end  
end
for s = 1 : numSelected
    col = selected(s);
    plkLbls{s} = labels{col};
end

pluckedLabels = plkLbls;
pluckedValues = plucked;

end

