function gunStrs = loadGunStrings()


gunsFile = 'Guns';

fid = fopen(gunsFile);
if( fid == -1 )
  display([ gunsFile, ' NOT FOUND'])
end

rowth = 0;
while 1
  nextl = fgetl(fid);
  rowth = rowth + 1;
  if ~ischar(nextl)
    display(sprintf('Read %d gun names',rowth-1))
    break
  end
  gunStrs{rowth} = nextl;
end
fclose(fid);

