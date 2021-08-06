function mergedObj = union( obj1, obj2 );

evts1 = obj1.events;
evts2 = obj2.events;

sz1=size(evts1)
sz2=size(evts2)

mergedWidth = max( sz1(2), sz2(2) );
numResultingRows = sz1(1) + sz2(1);

evtResult = zeros( numResultingRows, mergedWidth );

evtResult(1:sz1(1),1:sz1(2)) = evts1;
evtResult((sz1(1)+1):(sz1(1)+sz2(1)),1:sz2(2)) = evts2;

mergedObj = obj1;
mergedObj.events=evtResult;
mergedObj = updateTimes( mergedObj );
