function dot = dotAccel( accel, dotV )

srcKey = makeSrcKey;

sz = size(accel)

if sz(2) ~= 4
	error('Not accelerometer data')
end

dottr = zeros(sz(1),1);

for s = 1 : sz(1)

 dottr(s) = accel(s,2)*dotV(1) + accel(s,3)*dotV(2) + accel(s,4)*dotV(3); 

end

dot = dottr;