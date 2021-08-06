function ok = write(inObj,writePath)
%  $Id: write.m,v dad18e544a10 2014/01/17 21:22:40 qcvs $
%
% Write events table.

ok = 0;

if nargin ~= 2
  error( 'Must supply two args: object and file name' );
end

sz = size( inObj.eventTable );
display( sprintf( 'Writing %d events to file: %s', sz(1), writePath ) );

if( sz(1) == 0 | numel(sz) < 2 )
  warning('Will write empty file!')
end
numEvents = sz(1);

% Sort every time!
inObj.eventTable = sortrows( inObj.eventTable, 1 );


fid = fopen( writePath, 'w' );
if( fid == -1 )
  warning( [ 'Could not open file: |', writePath, '| for writing!' ] );
  return
end

%display(sprintf() 'Writing')

for p = 1 : sz(1)
  fwrite(fid, inObj.eventTable(p,:), 'double');
end

fclose( fid );

ok = 1;
