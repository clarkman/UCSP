function Lshellplot(filename);

% These are the column numbers for each parameter
LshellCol = 29;
LatCGMCol = 19;

% Total number of columns
ncols = 43;   % Number of fields in the input file

% Time has 3 fields and looks like this: www ddmmmyy hh:mm:ss
% Excluding the spaces, it is 18 characters and takes up 18 columns in the
% 'data' array due to the way Matlab handles strings
numTimeFields = 3;
ncharsInTimeFields = 18;

% Prepare the format string for reading data from the file
formatStr = '%3s%7s%8s';    % the 3 time fields convert to 18 characters
for ifield = 1 : ncols-numTimeFields
   formatStr = [formatStr, '%f'];  % Add a floating-pt field for each non-time column
end

% Adjust column numbers for conversion of time fields to single characters
% (as performed by the Matlab file read code below)
LshellCol = LshellCol - numTimeFields + ncharsInTimeFields;
LatCGMCol = LatCGMCol - numTimeFields + ncharsInTimeFields;

% Adjust total number of columns for the matrix
ncols = ncols - numTimeFields + ncharsInTimeFields;

% Read in the data
fid = fopen(filename);
data = fscanf(fid, formatStr);
fclose(fid);

%length(data)
nrows = length(data)/ncols;
if fix(nrows) ~= nrows
    error('Bad Data File:  Incorrect or inconsistent number of columns.');
end

data = reshape(data', ncols, nrows);
data = data';  % transpose columns and rows

% Get absolute time from file
time = data(:,11:18);
time = char(time);
time(1,:);
numtime = datenum(datevec(time));   % in units of days
numtime = numtime - numtime(1);
numtime = numtime * 86400;          % in units of seconds

% Extract the Lshell and LatCGM values 
LshellPts = data(:,LshellCol);
LatCGMPts = data(:,LatCGMCol);

% Create overlay plot of lshell and magnetic latitude against time
[AX,H1,H2] = plotyy (numtime, LshellPts, numtime, LatCGMPts, 'plot');
xlabel ('Time (sec)'),
set(get(AX(1),'Ylabel'),'String','L-Shell')
set(get(AX(2),'Ylabel'),'String','Magnetic Latitude')
grid on;

% Set grid line spacing
xlimits = get(AX(1), 'XLim');
ylimits = get(AX(1), 'YLim');
xinc = (xlimits(2) - xlimits(1))/10;
yinc = (ylimits(2) - ylimits(1))/10;
set(AX(1), 'XTick', [xlimits(1):xinc:xlimits(2)], 'YTick', [ylimits(1):yinc:ylimits(2)]);
xlimits = get(AX(2), 'XLim');
ylimits = get(AX(2), 'YLim');
xinc = (xlimits(2) - xlimits(1))/10;
yinc = (ylimits(2) - ylimits(1))/10;
set(AX(2), 'XTick', [xlimits(1):xinc:xlimits(2)], 'YTick', [ylimits(1):yinc:ylimits(2)]);

% Remove path from filename to display it in the title
slashes = [strfind(filename, '/') strfind(filename, '\')];
if slashes
    filename = filename(max(slashes)+1:end);
end    

lastRow = size(data,1);
title([filename, ':  ', data(1,4:10), ' ', data(1,11:18), ' to ', data(lastRow,4:10), ' ', data(lastRow,11:18), ' UTC' ]);

