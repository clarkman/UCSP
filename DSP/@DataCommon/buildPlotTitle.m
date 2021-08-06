function str = buildPlotTitle(obj)
% Combines the title, source, and history fields into a string that can be
% displayed as the current figure's title.

[path file ext anot] = splitPath( obj.source );
str = file;

% Replace underscores
underscores = strfind( str, '_' );
for ith = 1 : length( underscores )
    str(underscores(ith)) = ' ';
end

if obj.title
    % Append the title field on to the front
    str = [obj.title, ' : ', str];
end

if(isempty(obj.UTCref))
    str = sprintf('%s', str);
else
    str = sprintf('%s  (%s UTF, Span = %9.3f - %9.3f sec)', ...
                str, datenum2str(abs(obj.UTCref)), obj.timeOffset, obj.timeEnd);
end

if obj.history
    % Append the history field on another line
    str = sprintf('%s\n[history: %s]', str, obj.history);
end

    
