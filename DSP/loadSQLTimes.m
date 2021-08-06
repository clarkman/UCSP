function times = loadSQLTimes( fname )


fid = fopen( fname );
if fid == -1 
    display( [ 'Could not open ', fname ] );
    return;
end

numLines=0;
while 1
    daLine = fgetl( fid );
    if( daLine == -1 )
        break;
    else
        numLines = numLines + 1;
    end
end
frewind( fid );

lineEnd=length(daLine);
if( lineEnd > 19 )
  isFract=1
else
  isFract=0
end

numLines
times = zeros( numLines, 1 );

for ith = 1 : numLines
    daLine = fgetl( fid );
    if( daLine == -1 )
        break;
    else
        times( ith, 1 ) = str2datenum( sql2stdDate(daLine(1:19)) );
        fract = sscanf( [ '0', daLine(20:26) ],'%lf' );
        times( ith, 1 ) = times( ith, 1 ) + fract/86400;
    end
end

fclose( fid );

