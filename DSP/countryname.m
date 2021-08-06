function country = countryname( whichOne )


% Load earthquakes
switch whichOne
   case 'CMN'
      country='California';
   case 'TMN'
      country='Taiwan';
   case 'PMN'
      country='Peru';
   otherwise
      error('Unknown region.')
end
