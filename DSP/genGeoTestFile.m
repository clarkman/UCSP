
filename = 'Y:\new\ingestme\MG2HXNZ2M07Oct0740B.pre';

% These are the column numbers for each parameter, EXCLUDING THE TIME
% COLUMNS AT THE BEGINNING
latCol = 2;
lonCol = 1;
footLatCol = 17;
footLonCol = 18;
ionoLatCol = 26;
ionoLonCol = 27;


% Number of fields beyond time
nfields = 9;

charsInTimeFields = 18;

ncols = charsInTimeFields + nfields; % 18 columns for 18 characters in the time fields, plus 9 fields beyond time

formatStr = '%3s%7s%8s';    % the 3 time fields
for ifield = 1:nfields
    formatStr = [formatStr, '%f'];
end

fid = fopen(filename);
data = fscanf(fid, formatStr);


% Reshape matrix to have ncols
data = reshape(data', ncols, length(data)/ncols);
data = data';  % transpose columns and rows

% Add extra columns 

nrows = size(data);
nrows = nrows(1);

nTotalFields = 35;   % Number of fields beyond time in the final file format
nColsToAdd = nTotalFields - nfields;

pad = zeros(nrows, nColsToAdd);

data = [data, pad];

data(:,charsInTimeFields+footLatCol) = data(:,charsInTimeFields+latCol) + 0.5;
data(:,charsInTimeFields+footLonCol) = data(:,charsInTimeFields+lonCol) + 0.8;
data(:,charsInTimeFields+ionoLatCol) = data(:,charsInTimeFields+latCol) + 0.25;
data(:,charsInTimeFields+ionoLonCol) = data(:,charsInTimeFields+lonCol) + 0.4;

% Write out to file

formatStr = '%c%c%c %c%c%c%c%c%c%c %c%c%c%c%c%c%c%c';    % the 3 time fields
for ifield = 1:nTotalFields
    formatStr = [formatStr, ' %f'];
end
formatStr = [formatStr, '\n'];

fidout = fopen('C:\MATLAB6p5\work\test.rep', 'w');
fprintf(fidout, formatStr, data');
fclose(fidout);
