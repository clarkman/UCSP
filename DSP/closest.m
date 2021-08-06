function [i,err] = closest( aray, a )

% function [i,err] = closest( aray, a )  finds index into aray such that 
% abs(aray-a) is minimized, with err = a - aray(i);

[tmp,idx] = sort( abs( aray - a ) );
i = idx(1);
err = a - aray(i);
