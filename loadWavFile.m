function tds = loadWavFile( fileName )


% Read file
[chans, FS]=audioread( fileName );
sz = size(chans);
numChans = sz(2)
numSamps = sz(1);
fileDurSecs = numSamps / FS;

tds = cell(numChans,1);

% Extract time from filename
underScores = strfind( fileName, '_' );
if numel(underScores) ~= 5
  warning( [ 'Improperly formed file name: ', fileName ] );
  fileTime = 0;
else
  dateStr = fileName( underScores(2)+1:underScores(3)-1 );
  timeStr = fileName( underScores(3)+1:underScores(4)-1 );
  dnStr = [ dateStr(1:4), '/', dateStr(5:6), '/', dateStr(7:8), ' ', timeStr(1:2), ':', timeStr(3:4), ':', timeStr(5:6) ];
  fileTime = datenum( dnStr );
end

display( [ 'File: "', fileName, '"" has ', sprintf('%d',numChans), ', starts at: ' datestr(fileTime), ' UTC, and lasts ', sprintf('%f',fileDurSecs), ' seconds.' ] )

for ch = 1 : numChans
  td=TimeData;
  td.sampleRate = FS;
  td.samples    = chans(:,ch);
  td.source     = [ fileName, ' ch', sprintf('%d',ch) ];
  td.UTCref     = fileTime;
  tds{ch}       = td;
  clear td;
end
