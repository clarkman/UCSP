function obj = loadHeartbeatEvents( obj, fileName )

fid = fopen( fileName )
if fid == -1, error('File open failed');, end;


numLines = 0;
while 1
    daLine = fgetl( fid );
    if( daLine == -1 )
        break;
    end
    numLines = numLines + 1;
end
frewind(fid);
numLines

return;
eventArray = zeros( numLines, 7 );
numEvents = 0;
for evt = 1 : numLines
    daLine = fgetl( fid );
    numChars = length(daLine)
end

fclose(fid);