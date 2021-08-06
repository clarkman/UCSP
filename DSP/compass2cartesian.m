function cartesian = compass2cartesian( compass )
% Test
% plot( -180:1:360, cartesian2compass( -180:1:360 ));

if( compass > 180 )
  compass = compass - 360;
end
cartesian = 90 - compass;
if( cartesian < 0 )
  cartesian = cartesian + 360;
end
