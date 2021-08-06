function [td] = fbloader1( fileName )

	try
		td = readColumnFile( fileName );

%		t1 = size(td);
%		if (t1(1) ~= 96 || t1(2) ~=14),
%			s = sprintf(' Error in %s, size is %d %d.', fn, t1(1), t1(2) );
%			error( s );
%		end
	catch,          % - Catch a file that doesn't exist, or there was an error.  Use zeros.
		display(sprintf('%s does not exist. Loading zeros',fileName));
		td = zeros(96,14);	
	end


return
