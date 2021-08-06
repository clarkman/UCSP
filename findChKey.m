function [ chMoniker, chName ] = findChKey( key, idx )
%MAKEDIRKEY Finds a consistent order of channels across Aretmis analyses.
% 
% key - the key made by makeChKey.m
%
% idx - the selector, may be numeric, or a string to
%       match 'moniker' or 'fullname' size of idx must be (1,1)

szKey = numel(key);
if isnumeric(idx)
  if idx > szKey || idx < 1
  	chMoniker = ''; chName = '';
  	error(sprintf('idx must be 1:numel(key)=%d, you requested %d', szKey,idx))
  end
  chMoniker = key(idx).moniker;
  chName = key(idx).fullname;
else
  found = 0;
  for ith = 1 : szKey
	if strcmp( key(ith).moniker, idx ) || strcmp( key(ith).fullname, idx )
	  found = 1;
	  chMoniker = key(ith).moniker;
	  chName = key(ith).fullname;
	  break;
	end
  end
  if ~found
  	chMoniker = ''; chName = '';
  	error(['Your requested key: |' idx, '| was not found!'])
  end
end

%if
