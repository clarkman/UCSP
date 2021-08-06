function xstrColor = getXSTRcolor( colorName )
% Return stringized RGB hex color

fullColor = getQFDCcolor( colorName );


xstrColor = sprintf( '%02x%02x%02x', fullColor.qc_r, fullColor.qc_g, fullColor.qc_b );
