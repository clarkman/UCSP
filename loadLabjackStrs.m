function labjackStrs = loadLabjackStrs()

labjackFile = 'Labjacks';

fid = fopen(labjackFile);
if( fid == -1 )
  display([ labjackFile, ' NOT FOUND'])
end

rowth = 0;
while 1
  nextl = fgetl(fid);
  rowth = rowth + 1;
  if ~ischar(nextl)
    display(sprintf('Read %d labjack names',rowth-1))
    break
  end
  labjackStrs{rowth} = nextl;
end
fclose(fid);


