function [ range, angl ] = rangeAngl( sensVect, sensOrient )

range = norm(sensVect);

unit = sensVect ./ range;

if( abs(norm(unit)) - 1 > eps )
	error('unit non unity')
end
if( norm(sensOrient) ~= 1 )
	error('sensOrient non unity')
end


angl = acosd(dot(unit,sensOrient));