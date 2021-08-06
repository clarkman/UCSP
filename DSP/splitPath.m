function [path, file, ext, anot] = splitPath( filename )
% Remove the file path from the input full file path
 
% Remove the path by finding the last slash or backslash
dots = strfind( filename, '.');
numDots=length(dots);
slashes = strfind( filename, '/');
annotation = strfind( filename, '|');
if isempty(annotation)
    annotation(1)=length(filename)+1;
end
% All dots before the final slash are part of the path
if ~isempty(slashes) && ~isempty(dots)
    for ith = 1 : length(dots)
        if( dots(ith) > slashes(end) )
            break;
        end
    end
    path = filename(1:slashes(end));
    file = filename(slashes(end)+1:dots(numDots)-1);
    %ext = filename(dots(ith):length(filename));
    ext = filename(dots(numDots):annotation(1)-1);
    anot = filename(annotation(1):length(filename));
    return;
end
if dots % Without slashes, all dots are part of extension.
    path = [];
    file = filename(1:dots(numDots)-1);
    ext = filename(dots(numDots):annotation(1)-1);
    anot = filename(annotation(1):length(filename));
    return;
end % If only slashes, filename has no extension. 
if slashes
    path = filename(1:slashes(end));
    file = filename(slashes(end)+1:annotation(1)-1);
    ext = [];
    anot = filename(annotation(1):length(filename));
    return;
end    

% otherwise
path = [];
file = filename;
ext = [];
anot = [];
