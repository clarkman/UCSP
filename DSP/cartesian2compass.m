function compass = cartesian2compass( cartesian )
% Test
% plot( -180:1:360, cartesian2compass( -180:1:360 ));

compass = -cartesian + 90;
if( compass < 0 )
  compass = compass + 360;
end
