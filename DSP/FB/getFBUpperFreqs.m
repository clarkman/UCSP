function [f1, f2] = getFBUpperFreqs( index )
% Returns the frequency band for the given FB index number.
%  f1 = the lower band edge of the passband
%  f2 = the upper band edge of the passband

if ( index == 0 ),
	f1 = 55;
	f2 = 55;
	return
end

if( index == 56 ) % SLP
    f1 = 9;
    f2 = 9 + 55*0.2;
    return
end

f1 = 9 + (index-1)*0.2;
f2 = f1 + 0.2;

return
