function [ ssamps, usamps ] = unsignedCompr( stdev )

numSecs  = 40;
sampRate = 12000;
numSamps = numSecs * sampRate;

usamps = zeros(numSamps,1,'uint8');
ssamps = zeros(numSamps,1,'int8');

for s = 1 : numSamps
	valu = random('norm',127,stdev);
	if valu < 0
		valu = 0;
		warning('Clamped unsigned to zero!')
	end
	if valu > 255
		valu = 255;
		warning('Clamped unsigned to 255!')
	end
	usamps(s) = uint8(valu);
	vals = random('norm',0,stdev);
	if vals < -128
		vals = -128;
		warning('Clamped signed to -128!')
	end
	if vals > 127
		vals = 127;
		warning('Clamped signed to 127!')
	end
	ssamps(s) = int8(vals);
	%display( sprintf( 'signed = %x, unsigned = %x', ssamps(s), usamps(s)) )
end

fids = fopen('signed','w');
fwrite(fids,ssamps,'int8','b');
fclose(fids);

fidu = fopen('unsigned','w');
fwrite(fidu,usamps,'uint8','b');
fclose(fidu);
