function dnRange = getDNRange(eObj)

if isempty(eObj.eventTable(:,1))
	dnRange=[];
	return
end

begDN = min( eObj.eventTable(:,1) );
[ finDN, idx ] = max( eObj.eventTable(:,1) );
finDN = finDN + eObj.eventTable(idx,2) / 86400;

dnRange = [ begDN, finDN ];