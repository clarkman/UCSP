function ammoStrs = loadAmmoStrings()

ammoFile = 'Ammo';

fid = fopen(ammoFile);
if( fid == -1 )
  display([ ammoFile, ' NOT FOUND'])
end

rowth = 0;
while 1
  nextl = fgetl(fid);
  rowth = rowth + 1;
  if ~ischar(nextl)
    display(sprintf('Read %d ammo names',rowth-1))
    break
  end
  ammoStrs{rowth} = nextl;
end
fclose(fid);

