function invcolr = invertColor( colr )

if( length(colr) == 3 )
    invcolr(1)=1.0-colr(1);
    invcolr(2)=1.0-colr(2);
    invcolr(3)=1.0-colr(3);
elseif( length(colr) == 4 )
    invcolr(2)=1.0-colr(2);
    invcolr(3)=1.0-colr(3);
    invcolr(4)=1.0-colr(4);
end