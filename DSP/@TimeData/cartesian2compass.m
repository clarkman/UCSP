function compass = cartesian2compass( cartesian )
% Test
% plot( -180:1:360, cartesian2compass( -180:1:360 ));

samps = cartesian.samples;
numSamps = length(samps);

comps = zeros( numSamps, 1 );

for s = 1 : numSamps
  comp = -samps(s) + 90;
  if( comp < 0 )
    comp = comp + 360;
  end
  comps(s) = comp;
end

compass = cartesian;
compass.samples = comps;