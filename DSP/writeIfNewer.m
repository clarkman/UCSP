function result = writeIfNewer( target, varargin )
%
% Check whether a file needs to be written.  Returns a code to indicate what happened.
%
%  result =  0: success
%  result =  1: file existed and was written over
%  result = -1: write failed.
%  result = -2: tmpFile write failed.
%
% The technique used is to write the file to a local tmp location, then 
% copy it to its destination on the server.  An MD5Sum then confirms the
% write.  writeForce.bash is the real player.

if( nargin < 2 )
    error( 'At least two args must be passed!!' );
    return;
end


[status, procDir] = system( 'echo -n $QFDC_ROOT' );
if( length( procDir ) == 0 )
    display( 'env must contain QFDC_ROOT variable' );
    display( 'found in CalMagNet/qfpaths.bash' );
    result = -3;
    return;
end

result = writeForce( target );
if( result < 0 )
    error( 'Problem with file write-ability' );
end




proc = [ procDir '/tools/DSP/writeIfNewer.bash' ];

independents='';
for ith = 1 : nargin-1
    independents = [ independents ' ' varargin{ith} ];
end

cmd = [ proc independents ' ' target ]
[ result, msgs ] = system( cmd );


result

