function sz = size( inObj )

szor=size(inObj.eventTable);

if numel(szor) <= 1
  sz = [0,0];
else
  sz = szor;
end
