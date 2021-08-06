function titl = makePlotTitle( varName )

ub = strfind(varName,'_');
hr = varName(ub(2)+1:ub(3)-1);
hr = [ hr(1:2), ':', hr(3:4), ':', hr(5:6) ];
titl = [ varName(1:ub(1)-1), ' ' varName(ub(1)+1:ub(2)-1), ' ', hr, ' PDT, ', varName(ub(3)+1:ub(4)-1), ' sensor, Source: ', varName(ub(4)+1:ub(5)-1), ', MICBOOST = ', varName(ub(5)+1:ub(6)-1), ' dB, PGA = ', varName(ub(6)+1:ub(7)-1), ' dB' ]
