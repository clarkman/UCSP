function arr = networks()

[status, qfdcDir] = system( 'echo -n $QFDC_ROOT' );
if( length( qfdcDir ) == 0 )
    display( 'env must contain QFDC_ROOT variable' );
end
pathN= [ qfdcDir, '/include/networks'  ]; 

arr = textread( pathN, '%s' );
