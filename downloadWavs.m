function wavs = downloadWavs( dBaseName, urlTable, incIdx, incidentID )

chCodes = { 'audio', 'mwir', 'accel', 'swir' };
urlBase = 'https://star.com/';

url = [ urlBase, dBaseName, '/Audio/' ];

row = find( incIdx == incidentID );
if isempty(row)
	error( 'incidentID not found!' );
end
if numel(row) > 1
	warning('Multiple rows match:')
	row
	warning('Downloading only first')
end

audioUrl = urlTable{row(1),4};
hyphens = strfind(audioUrl,'-');
audioUrl = audioUrl(1:hyphens(end));

for c = 1 : numel(chCodes)
  dnLoad = [ url, audioUrl, chCodes{c}, '.wav' ]
  stat = system( [ '/usr/local/bin/wget ', dnLoad ] );
  if stat
  	warning( [ 'Problem downloading: ', dnLoad] )
  	continue
  end
  slashes = strfind(dnLoad,'/');
  fName = dnLoad(slashes(end)+1:end);
  %audioinfo( fName )
  tdCellArray = loadWAV( fName );
  % [ stat rtn ] = system( [ 'stat ', fName ] );
  % statInds = strfind(rtn,'"');
  % datestr(datenum(rtn(statInds(3)+1:statInds(4)-1)))
  % if stat
  % 	warning( [ 'Problem stat-ing: ', fName] )
  % 	continue
  % end
  td=tdCellArray{1};
  td.source = dnLoad;
  td.station=urlTable{row(1),1};
  td.channel=chCodes{c};
  td.network=dBaseName;
  td.title=urlTable{row(1),2};
  td.UTCref=urlTable{row(1),5};
  td.history=sprintf('IncidentID=%d',incidentID);
  stat = system( [ 'rm ', fName ] );
  if stat
  	warning( [ 'Problem deleting: ', fName] )
  	continue
  end
end

