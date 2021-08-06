function titl = makePlotTitle(td)

slashes = strfind(td.DataCommon.source,'/');
if ~isempty( slashes )
  path = td.DataCommon.source;
  source = path(slashes(end)+1:end);
end

titl = [ source, ' for: ', td.DataCommon.station, ...
	        ', ', td.DataCommon.channel, ', ', ...
	        datestr( td.DataCommon.UTCref, 31 ) ];
