function str = datenum2str(num, fmt)
% Converts a Matlab serial date number to a string for display 
%  fmt is an optional argument as follows:
%       fmt omitted   produces yyyy/mm/dd hh:mm:ss.ff
%       fmt = '2line' produces yyyy/mm/dd hh:mm:ss.ff with the date and time split onto two lines
%       fmt = 'date'  produces yyyy/mm/dd
%       fmt = 'moday'  produces mm/dd
%       fmt = 'time'  produces hh:mm:ss.ff
%       fmt = 'map'   produces mm/dd hh:mm
%       fmt = 'sql'   produces yyyy-mm-dd hh:mm:ss.f (SQL compatible)
%       fmt = 'sec'   produces ss.ff
%       fmt = 'moniker'   produces YYYYMMDD (as in floor())
%   If num is an array, then it produces an array of strings (equal length)


if isempty(num)
    str = 'Unknown';
    return;
end

num = num(:);   % linearize it;
%num
vec = datevec(num);

% Test for 59.9999.. etc sec., which should be rounded up to the next minute
epsilon = 0.00001;                              % epsilon is in seconds
test = vec(:,6) >= 60 - epsilon;
num(test==1) = num(test==1) + epsilon/86400;     % add epsilon only if if meets test; convert epsilon to days

% Recompute the date vector
vec = datevec(num);

str = [];

for ii = 1 : length(num)
    date = sprintf('%02d/%02d/%04d', vec(ii,2), vec(ii,3), vec(ii,1));        
    time = sprintf('%02d:%02d:%05.4f', vec(ii,4), vec(ii,5), vec(ii,6));        
    if nargin == 1
        tmp = [date, ' ', time];
    elseif strcmp(fmt, '2line')
        tmp = sprintf('%s\n%s', date, time);
    elseif strcmp(fmt, 'date')
        tmp = date;        
    elseif strcmp(fmt, 'moday')
        tmp = sprintf('%02d_%02d', vec(ii,2), vec(ii,3));      
    elseif strcmp(fmt, 'time')
        tmp = time;        
    elseif strcmp(fmt, 'sec')
        tmp = sprintf('%0.2f', vec(ii,6));        
    elseif strcmp(fmt, 'map')
		date = sprintf('%02d/%02d', vec(ii,2), vec(ii,3)); 
        time = sprintf('%02d:%02d', vec(ii,4), vec(ii,5));        
        tmp = [date, ' ', time];
    elseif strcmp(fmt, 'sql')
		date = sprintf('%04d-%02d-%02d', vec(ii,1), vec(ii,2), vec(ii,3));
        tmp = [date, ' ', time];
    elseif strcmp(fmt, 'moniker')
		tmp = sprintf('%04d%02d%02d', vec(ii,1), vec(ii,2), vec(ii,3));
    else
        error('Invalid value for fmt');
    end
    str = [str; tmp];
end

