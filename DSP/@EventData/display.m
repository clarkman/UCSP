function display(a)
%
% Display parent

display(a.DataCommon);

sizor = size(a.eventTable);
sizeStr = sprintf( 'array of %dx%d dimension', sizor(1), sizor(2) );
if( ~isempty(a.eventTable) && sizor(2) < 5 )
    warning( ['EventData objects with less than five columns are not supported!! actual: ' sprintf( '%d', sizor(2) ) ] );
end

display( [ 'EventData object is: ', sprintf('%d',sizor(1)), ' rows x ', sprintf('%d',sizor(2)), ' columns.' ] )

if( sizor(1) == 0 )
    display( '  ... empty object.' );
else
	% Don't assume sorted
	begDN = min(a.eventTable(:,1));
	[endDN, endDNidx] = max(a.eventTable(:,1));
    display( [ '  covering: ', datenum2str(begDN), ' -to- ', datenum2str(endDN+a.eventTable(endDNidx,2)/86400) ] );
end
