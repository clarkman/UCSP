function srcNum = findSrcKey( key, str )

numKeys = numel(key);

found = 0;
for k = 1 : numKeys
  if strcmp( key(k).name, str )
    tKey = key(k).num;
    found = 1;
    break
  end
end

if found
  srcNum = tKey;
else
  error([ 'String: |', str, '| not found!'])
end
	