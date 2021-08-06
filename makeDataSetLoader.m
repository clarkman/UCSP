function [ segs, segNames ] = makeDataSetLoader( loadDir, writeDir )

% Presumes audio mp3 & wav, piezo mp3 & wav are present

if nargin > 0
  files=dir( [ loadDir '/*audio.wav' ] )
else
  files=dir( '*audio.wav' )
end

numFiles = numel( files );

segs = zeros( numFiles, 4 );
segNames = cell( numFiles, 1 );

for f = 34 : numFiles
  f
  seg = zeros(1,4);
  dashInds = strfind( files(f).name, '-' );
  segNames{f} = files(f).name(1:dashInds(end));
  seg = analyzeDQVaudio( segNames{f}, writeDir, seg );
  segs(f,:) = seg;
end
