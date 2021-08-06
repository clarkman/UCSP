function gunCode = getGunCode( gunTable, gunString )

sz = size(gunTable);
numGunCodes = sz(2);

if nargin < 2
  % return number of ammo codes
  gunCode = numGunCodes;
  return
end

for c = 1 : numGunCodes
  if strcmp( gunTable{c}, gunString )
    gunCode = c;
    return
  end
end

error( [ 'Gun: |', gunString, '| not FOUND!' ] )
end
 
 
