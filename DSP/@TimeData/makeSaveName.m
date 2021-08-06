function saveName = makeSaveName( td, ext )

slashes = strfind(td.DataCommon.source,'/');
if ~isempty( slashes )
  path = td.DataCommon.source;
  source = path(slashes(end)+1:end);
end

saveName = [ source, '.', td.DataCommon.station, '.', td.DataCommon.channel, '.', ext ]
