function [ rev4Load, revALoad ] = loadPair( rev4Dir, revADir )

% Presumes audio mp3 & wav, piezo mp3 & wav are present

statedLength = 4 * 24000;

rev4Files = dir( rev4Dir );
numRev4Files = numel(rev4Files);
revAFiles = dir( revADir );
numRevAFiles = numel(revAFiles);

if( numRev4Files ~= numRev4Files || numRev4Files ~= 6 )
  error( 'Malformed data set' )
end

for f = 1 : numRev4Files
  rev4File = [ rev4Dir, '/', rev4Files(f).name ]
  if( strfind( rev4File, 'audio.wav' ) )
    display( [ 'Loading: ', rev4File ] )
    audio = audioread(rev4File);
  end
  if( strfind( rev4File, 'piezo.wav' ) )
    display( [ 'Loading: ', rev4File ] )
    piezo = audioread(rev4File);
  end
end
rev4Load = [audio, piezo];

for f = 1 : numRevAFiles
  revAFile = [ revADir, '/', revAFiles(f).name ]
  if( strfind( revAFile, 'audio.wav' ) )
    display( [ 'Loading: ', revAFile ] )
    audio = audioread(revAFile);
  end
  if( strfind( revAFile, 'piezo.wav' ) )
    display( [ 'Loading: ', revAFile ] )
    piezo = audioread(revAFile);
  end
end
revALoad = [audio, piezo];

