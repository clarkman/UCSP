function filename = removeFilePath(fullpathfilename)
% Remove the file path from the input full file path

filename = fullpathfilename;

% Remove the path by finding the last slash or backslash
slashes = [strfind(filename, '/') strfind(filename, '\')];
if slashes
    filename = filename(max(slashes)+1:end);
end    
