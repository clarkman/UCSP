function trimmedObj = segDatenumStrict( inObj, dnRange );

evts = inObj.events;

sz=size(evts);
numFound = 0;
finders=zeros(sz(1),sz(2));
for p = 1 : sz(1)
    if( evts(p,1) > evts(p,2) )
        error( 'Event start time after end time!!!' );
    end
    if( evts(p,1) >= dnRange(1) && evts(p,2) <= dnRange(2) )
        % Add completely contained event
        numFound = numFound + 1;
        finders(numFound,:)=evts(p,:);
    else
        % Do jack!!
    end
end


trimmedObj = inObj;
trimmedObj.events=sortrows(finders(1:numFound,:),1);



