function residual = makeResidual( obj, index1, max_dur );
% The minus one is key here.  
% Keeps joined TD for next pass starting on a pulse.

if( index1 > 1 ) 
    index1 = index1-1;
end

residual = slice( obj, index1, length(obj) );
if( lengthSecs( residual ) > max_dur )  % Too long, won't be counted anyway.
    residual = -1;
    display( 'Residual too long, wont be counted anyway' );
else
	display( sprintf( 'Created residual of %d samples.', length(residual) ) )
end
