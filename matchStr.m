function [ inds, matches ] = matchStr( strs, match )

numStrs = length(strs);

inds = [];
matches = {};

numMatched = 0;
for s = 1 : numStrs
  str = strs{s};
  if ~isempty( strfind(str,match) )
    numMatched = numMatched + 1;
    inds(numMatched) = s;
    matches{numMatched} = str;
  end
end
