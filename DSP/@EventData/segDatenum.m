function trimmedObj = segDatenum( inObj, dnRange );

evts = inObj.eventTable;

sz=size(evts)
numFound = 0;
finders=zeros(sz(1),sz(2));
for p = 1 : sz(1)
    begDN = evts(p,1);
    endDN = begDN+evts(p,2)/86400;
    if( begDN >= dnRange(1) && endDN <= dnRange(2) )
        %display( sprintf( '%d, Add completely contained event', p ) )
        numFound = numFound + 1;
        finders(numFound,:)=evts(p,:);
    elseif( begDN <= dnRange(1) && endDN >= dnRange(2) )
        %display( sprintf( '%d, Add completely containing event', p ) )
        numFound = numFound + 1;
        finders(numFound,:)=evts(p,:);
    elseif( begDN >= dnRange(1) && begDN <= dnRange(2) )
        %display( sprintf( '%d, Add event starting in range', p ) )
        numFound = numFound + 1;
        finders(numFound,:)=evts(p,:);
    elseif( endDN >= dnRange(1) && endDN <= dnRange(2) )
        %display( sprintf( '%d, Add event ending in range', p ) )
        numFound = numFound + 1;
        finders(numFound,:)=evts(p,:);
    else
        %display( sprintf( '%d, Do jack!!', p ) ) 
    end
end

trimmedObj = inObj;
trimmedObj.eventTable=sortrows(finders(1:numFound,:),1);

%added this to update UTCref and timeEnd fields in DataCommon to reflect
%new object start time and end time
trimmedObj.DataCommon.UTCref = min(trimmedObj.eventTable(:,1));
[ val, ind ] = max( trimmedObj.eventTable(:,1) );
trimmedObj.DataCommon.timeEnd = val * 86400 + trimmedObj.eventTable(ind,2);
