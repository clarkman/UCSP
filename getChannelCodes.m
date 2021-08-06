function chCodes = getChannelCodes( channels )


codeFile = '/Users/cuz/Desktop/Projects/SST/Artemis/ChannelCodes';

foundAny = 0;

fid = fopen(codeFile);
if( fid == -1 )
  display([ codeFile, ' NOT FOUND'])
end

rowth = 1;
while 1
  nextl = fgetl(fid);
  if ~ischar(nextl)
    display(sprintf('Read %d channel codes',rowth-1))
    break
  end
  splitr = strfind(nextl,' ');
  chCode = nextl(1:splitr(1)-1);
  chLabel = nextl(splitr(1)+1:end);
  codes{rowth,1} = chCode;
  codes{rowth,2} = chLabel;
  rowth = rowth + 1;
end
fclose(fid);

if nargin < 1
  chCodes = codes;
  return
end

if ~iscell(channels)
  error( 'chans must be cell array!' )
end

numChans = length( channels );


sz=size(codes);
numCodes = sz(1);

numMatchedChans = 1;
for code = 1 : numChans
  for ch = 1 : numCodes
     if strcmp( channels{numMatchedChans}, codes(ch,2) )
      display( [ 'Matched: ', channels{numMatchedChans} ] )
      foundAny = 1;
      chCodes{numMatchedChans} = codes{ch,1};
      if numMatchedChans == numChans
        break;
      end
      numMatchedChans = numMatchedChans + 1;
    end
  end
end

if numMatchedChans ~= numChans
  error('Incomplete match!!')
end

if foundAny == 0
  chCodes = {};
end

