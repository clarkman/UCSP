
function ammoCode = getAmmoCode( ammoTable, ammoString )

sz = size(ammoTable);
numAmmoCodes = sz(2);

if nargin < 2
  % return number of ammo codes
  ammoCode = numAmmoCodes;
  return
end

for c = 1 : numAmmoCodes
  if strcmp( ammoTable{c}, ammoString )
    ammoCode = c;
    return
  end
end

error( [ 'Ammo: |', ammoString, '| not FOUND!' ] )
end
 
