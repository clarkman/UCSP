function testStrs = loadTestStrs()

testFile = 'Tests';

fid = fopen(testFile);
if( fid == -1 )
  display([ testFile, ' NOT FOUND'])
end

rowth = 0;
while 1
  nextl = fgetl(fid);
  rowth = rowth + 1;
  if ~ischar(nextl)
    display(sprintf('Read %d test names',rowth-1))
    break
  end
  testStrs{rowth} = nextl;
end
fclose(fid);


