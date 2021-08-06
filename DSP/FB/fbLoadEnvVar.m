function [fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network )
%
% function [fbDir fbStatDir] = fbLoadEnvVar
%
% Purpose: Loads env. variables that provide pointers to FB files and output
%          directories.
% 

if ( strcmp( network, 'BK' ) )

	[status, fbDir] = system( 'echo -n $FBOUTPUT_BK' );
	if( length( fbDir ) == 0 )
	    error( 'ERROR: env must contain FBOUTPUT_BK variable found in $QFDC/include/qfpaths.bash' );
	end

	[status, fbStatDir] = system( 'echo -n $FBSTATOUTPUT_BK' );
	if( length( fbStatDir ) == 0 )
	    error( 'ERROR: env must contain FBSTATOUTPUT_BK variable found in $QFDC/include/qfpaths.bash' );
	end

elseif ( strcmp( network, 'BKQ' ) )

	[status, fbDir] = system( 'echo -n $FBOUTPUT_BKQ' );
	if( length( fbDir ) == 0 )
	    error( 'ERROR: env must contain FBOUTPUT_BKQ variable found in $QFDC/include/qfpaths.bash' );
	end

	[status, fbStatDir] = system( 'echo -n $FBSTATOUTPUT_BKQ' );
	if( length( fbStatDir ) == 0 )
	    error( 'ERROR: env must contain FBSTATOUTPUT_BK variable found in $QFDC/include/qfpaths.bash' );
	end

elseif ( strcmp( network, 'CMN' ) )

	[status, fbDir] = system( 'echo -n $FBOUTPUT_CMN' );
	if( length( fbDir ) == 0 )
	    error( 'ERROR: env must contain FBOUTPUT_CMN variable found in $QFDC/include/qfpaths.bash' );
	end

	[status, fbStatDir] = system( 'echo -n $FBSTATOUTPUT_CMN' );
	if( length( fbStatDir ) == 0 )
	    error( 'ERROR: env must contain FBSTATOUTPUT_CMN variable found in $QFDC/include/qfpaths.bash' );
	end
else
	error( ['ERROR: invalid network name--' network] );
end

[status, kpTxtFileName] = system( 'echo -n $KPOUTPUTTXT' );
if( length( kpTxtFileName ) == 0 )
    error( 'ERROR: env must contain KPOUTPUTTXT variable found in $QFDC/include/qfpaths.bash' );
end

[status, kpMatFileName] = system( 'echo -n $KPOUTPUTMAT' );
if( length( kpMatFileName ) == 0 )
    error( 'ERROR: env must contain KPOUTPUTMAT variable found in $QFDC/include/qfpaths.bash' );
end
