function dnGroups = spoolContiguous( dnArray )

sz = size(dnArray)
if( sz(2) ~= 1 )
	error('SingleDimOnly')
end
numDNs = sz(1);
if numDNs < 2
	warning('ArrayTooShort');
	dnGroups = {};
	return
end

nomDelta = 10/86400; % DN is day = 1.0
bigDelta = nomDelta + 1.5/86400;
litDelta = nomDelta - 0.5/86400;

segStart = 1;
begT = dnArray(segStart);
numGroups = 1;
for dn = 2 : numDNs
	finT = dnArray(dn);
	delta = finT-begT;
	if delta < litDelta
		display('lit miss?')
		datestr(begT)
		datestr(finT)
	end
	if delta > bigDelta
		display('miss')
		datestr(begT)
		datestr(finT)
		groups{numGroups}=[segStart, dn-1];
		segStart = dn;
		dn = dn + 1;
		numGroups = numGroups + 1;
	end 
	begT = finT;
end
groups{numGroups}=[segStart, dn];


dnGroups = groups;

return

