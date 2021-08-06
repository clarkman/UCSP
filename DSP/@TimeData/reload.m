function outObj = reload( inObj );
% Reload the current file.

[path file ext anot] = splitPath( inObj.DataCommon.source );
if ~strfind( ext, '.raw.txt' )
    % Silly check for now
    outObj = -1;
    msg = ['File extension Wrong! for file:',inObj.DataCommon.source];
    error(msg);
end

outObj = remakeRawTextFile( inObj, inObj.DataCommon.source );