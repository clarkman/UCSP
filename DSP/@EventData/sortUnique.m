function sortedObj = sortUnique( inObj );

sortedObj = inObj;
evts = inObj.events;
evts = sortrows(evts,1);

sz=size(evts);
uniqueEvts=zeros(sz(1),sz(2));
numUnique = 0;
if( sz(1) > 0 )
    numUnique = 1;
    uniqueEvts(1,:) = evts(1,:);
end

if( sz(1) > 1 )
    for r = 2 : sz(1)
        if( evts(r,1) == evts(r-1,1) )
            matches=evts(r,:) == evts(r-1,:)
            if( matches) != 1 )
                numUnique = numUnique + 1;
                uniqueEvts(,:)=evts(r,:)
            end
        else
            numUnique = numUnique + 1;
            uniqueEvts(,:)=evts(r,:)
        end
    end
end
end


sortedObj = inObj;
sortedObj.events = uniqueEvts;

