function xducerSets = loadXducerSets( folders )

setsFileName = 'XducerSets';

if nargin == 0
  xducerSetsFiles = {setsFileName};
  numFolders = 1;
else
  if ~iscell(folders)
    error('argument should be a cell array of file names')
  end
  fRoot = '/Users/cuz/Desktop/Projects/SST/Artemis/';
  numFolders = length(folders);
  for f = 1 : numFolders
    xducerSetsFiles{f} = [ fRoot, folders{f}, '/', setsFileName ];
  end
end

for f = 1 : numFolders

  fid = fopen(xducerSetsFiles{f});
  if( fid == -1 )
    display([ xducerSetsFile, ' NOT FOUND'])
  end

  rowth = 0;
  while 1
    nextl = fgetl(fid);
    if ~ischar(nextl)
      display(sprintf('Read %d xducer sets',rowth))
      break
    end
    rowth = rowth + 1;
    splitr = strfind(nextl,' ');
    codes{rowth,1} = nextl(1:splitr(1)-1);
    codes{rowth,2} = nextl(splitr(1)+1:splitr(2)-1);
    codes{rowth,3} = nextl(splitr(2)+1:splitr(3)-1);
    codes{rowth,4} = nextl(splitr(3)+1:end);;
  end
  fclose(fid);

  xducerSets{f} = codes;

end