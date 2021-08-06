function [ zone, znum, dn, friendlyNumber, serialNumber, ext ] = parseDnloadName( fName )

% AtlantaGAGeorgiaPower_0404 2018-03-21 205834_-001_HYP-00-AAA-0239.wav
ubars = strfind( fName, '_' );
numbars = numel( ubars );
if numbars < 3
	error( 'Usage: not enough underscores');
end
spaces = strfind( fName, ' ' );
numspaces = numel( spaces );
if numspaces < 2
	error( 'Usage: not enough spaces');
end
dots = strfind( fName, '.' );
numdots = numel( dots );
if numdots < 1
	error( 'Usage: not enough dots');
end


zone = fName(1:ubars(1)-1);
znum = sscanf(fName(ubars(1)+1:spaces(1)-1),'%d');

dat = [ fName(spaces(1)+1:spaces(2)-1), ' ', fName(spaces(2)+1:spaces(2)+2), ':', fName(spaces(2)+3:spaces(2)+4), ':', fName(spaces(2)+5:spaces(2)+6) ];
dn = datenum( dat );
friendlyNumber = sscanf(fName(ubars(2)+1:ubars(3)-1),'%d');

serialNumber = fName(ubars(3)+1:dots(1)-1);

ext = fName(dots(1)+1:end);

return
