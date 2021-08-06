function result = writeForce( fileName )
%
% Force a file to be written?  Returns a code to indicate possibilities.
%
%  result =  0: successful write can occur
%  result =  1: file exists and can be written over
%  result = -1: write test failed.
%  result = -2: tmpFile write failed.
%  result = -3: Usage error.
%
% The technique used is to write the file to a local tmp location, then 
% copy it to its destination on the server.  An MD5Sum then confirms the
% write.  writeForce.bash is the real player.

[status, procDir] = system( 'echo -n $QFDC_ROOT' );
if( length( procDir ) == 0 )
    display( 'env must contain QFDC_ROOT variable' );
    display( 'found in CalMagNet/qfpaths.bash' );
    result = -3;
    return;
end

proc = [ procDir '/tools/DSP/writeForce.bash' ];

[ result, staDir ] = system( [ proc ' ' fileName ] );


if( result == 255 ), result = -1, end;
if( result == 254 ), result = -2, end;

