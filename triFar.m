function angle = triFar( muzzHt, ceilHt, hyp )

y=muzzHt-ceilHt;

angle = 90 - asind( y/hyp );