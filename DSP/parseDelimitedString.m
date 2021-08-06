function values = parseDelimitedString(tline, delimiters)
%
% Parse a delimited text string into a cell array containing strings and
% numbers. Converts any number-valued string to an actual number.
%  delimiters is a vector of delimiter characters
% Any delimiter characters at the beginning of tline are ignored
%   Returns a cell array of string and numeric values

remainder = tline;
numvals = 0;

while (any(remainder))
    [word, remainder] = strtok(remainder, delimiters);     % Strip off first field
    
    numvals = numvals + 1;
    
    if (~isempty(word))
	if( length(strfind(word,'/')) >= 2 && length(strfind(word,':')) >= 2 )
	    values(numvals) = {str2datenum(word)};
	else
            % Try to convert it to a number
            num = str2num(word);
            if (~isempty(num))
        	values(numvals) = {num};    % save it as an actual number
            else
        	values(numvals) = cellstr(word);
            end
	end
    else
        % Account for missing values (e.g. two tabs in a row) by inserting
        % an empty value
        values(numvals) = {[]};
    end
end

