function [ inds, tPeriods ] = countEvents( obj, tPer, ovlpFactor, tBounds, hourBounds )
% Count events base on time in col 1.
% tPer must be in hours
% ovlpFactor is denominator, ie. 4 means 75% overlap, 1 means no overlap

sz=size(obj);
if ~sz(1)
 % inds = [];
 % tPeriods = [];
  warning( 'Empty object, nothing to count! Here:')
 % return
end

if nargin < 4
  miny = min( obj.eventTable(:,1) );
  maxy = max( obj.eventTable(:,1) );
  begDN = floor( miny );
  finDN = ceil( maxy )+1;
else
  if( tBounds(2) < tBounds(1) )
  	error( 'Backwards tBounds!' )
  end
  %begDN = floor( tBounds(1) );
  %finDN = ceil( tBounds(2) );
  begDN = tBounds(1);
  finDN = tBounds(2);
end  
period = tPer / 24;
step = period * ( 1 / ovlpFactor);
outputRow = 0;
begTempDN = begDN;

tPeriodsTmp = zeros(100000,2);

if nargin < 5
  
  while( begTempDN < finDN )

	  finTempDN = begTempDN + period;
		
	  outputRow = outputRow + 1;
       
    tPeriodsTmp(outputRow,1) = begTempDN;
	  tPeriodsTmp(outputRow,2) = finTempDN;
    
    sz = size(obj.eventTable);
    if sz(1)
 	    outInds{outputRow} = find(obj.eventTable(:,1) >= begTempDN & obj.eventTable(:,1) <= finTempDN);
    else
      outInds{outputRow} = [];
    end
      
	  begTempDN = begTempDN + step;
	
  end
  
  tPeriods = tPeriodsTmp(1:outputRow,:);

else

  while( begTempDN <= finDN )
	% need to add tPeriods (as added above)

	finTempDN = begTempDN + period;
		
	outputRow = outputRow + 1;
	fInds = find(obj.eventTable(:,1) >= begTempDN & obj.eventTable(:,1) <= finTempDN);

	gtemp = extractRows(obj.eventTable, fInds);
	%sz = size(gtemp) 
	if( ~isempty(gtemp) )
		offr = floor(min(gtemp(:,1)));

        hrs = ( gtemp(:,1) - offr ) .* 24;
        hits = find( hrs >= hourBounds(1) & hrs <= hourBounds(2) );
        if ~isempty(hits)
          outputRow = outputRow + 1;
          outInds{outputRow} = hits;
        end
    end
    
	begTempDN = begTempDN + step;
	
  end

end

inds = outInds;
