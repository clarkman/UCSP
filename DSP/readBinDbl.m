function outArr = readBinDbl( fileName, ncols )

fid = fopen( fileName );
if( fid == -1 )
  error( [ 'File: ', fileName, ' could not be opened for reading!' ] )
end

outArrT = fread(fid, [ncols,inf],'double');

fclose( fid );

outArr = outArrT';

