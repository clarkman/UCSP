function binr = yesNo2Bin( strs )

numStrs = numel(strs);
binr = zeros(numStrs,1);

for s = 1 : numStrs
	str = strs{s};
	if strcmpi( str, 'yes' )
		binr(s) = 1;
	elseif strcmpi( str, 'no' )
		binr(s) = 0;
	else
		binr(s) = -1;
		warning([ 'Value other tha yes or no was found: ', str ]);
	end
end
