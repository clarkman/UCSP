function arr = joinTimedTables(tabl1,tabl2,tcol)
% Not very general yet
% Assumes that any overlapping rows are duplicates
% tabl1 starts before tabl2

% Sort first
tabl1 = sortrows(tabl1,tcol);
tabl2 = sortrows(tabl2,tcol);

% Then find overlap
if tabl1(end,tcol) < tabl2(1,tcol)
	display('No overlap');
else
	display('Yes overlap');
	lapInd = find( tabl2(:,tcol) == tabl1(end,tcol) );
	if( numel(lapInd) ~= 1 )
		warning('Jankification')
	end
	tabl2 = tabl2(lapInd(end)+1:end,:);
end

arr = [ tabl1 ; tabl2 ];