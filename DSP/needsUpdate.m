function yn = needsUpdate( fileSrc, fileTarg )
%
%
% yn = needsUpdate( fileSrc, fileTarg )
%
% Tests dependencies.  Returns true iff:
% 
% 1. fileTarg does not exist
% 2. fileSrc exists and is newer than fileTarg
%
% Returns false otherwise.

[statSrc, factsSrc] = system( [ 'stat ', fileSrc ] );
if( statSrc ) % Source does not exist
  display( 'fileSrc Not found!' );
  yn = 0;
  return;
end
%display( 'Found src!' )

[statTarg, factsTarg] = system( [ 'stat ', fileTarg ] );
if( statTarg ) % Source does not exist
  display( 'fileTarg Not found!' );
  yn = 1;
  return;
end
%display( 'Found targ!' )

huntStr = 'Modify: ';
hunStrLen = length( huntStr );

srcModIdx = strfind( factsSrc, huntStr );
srcModDateStr = factsSrc( srcModIdx+hunStrLen: srcModIdx+hunStrLen+18 );

targModIdx = strfind( factsTarg, huntStr );
targModDateStr = factsTarg( targModIdx+hunStrLen: targModIdx+hunStrLen+18 );

srcDN = str2datenum( sql2stdDate( srcModDateStr ) );
targDN = str2datenum( sql2stdDate( targModDateStr ) );

if( srcDN > targDN )
  yn = 1;
else
  yn = 0;
end
