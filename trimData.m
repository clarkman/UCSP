function tdObjsOut = trimData( tdObjsIn, bracks )


numObjs = numel(tdObjsIn)
for obj = 1 : numObjs
  tdObjsOut{obj} = segment(tdObjsIn{obj},bracks(1),bracks(2))
end
