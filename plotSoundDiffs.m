function plotSoundDiffs( exps )

srcKey = makeSrcKey;
src40 = findSrcKey( srcKey, '0.40' );
src22 = findSrcKey( srcKey, '0.22' );
srcBN = findSrcKey( srcKey, 'Balloon' );
srcSP = findSrcKey( srcKey, 'StrtrPstl' );
srcFC = findSrcKey( srcKey, 'frcrckr' );

exps40Inds = find( exps(:,12) == src40 );
exps22Inds = find( exps(:,12) == src22 | exps(:,12) == srcSP );
expsBNInds = find( exps(:,12) == srcBN );
expsFCInds = find( exps(:,12) == srcFC );

expCounts40 = numel(exps40Inds);
expCounts22 = numel(exps22Inds);
expCountsBN = numel(expsBNInds);
expCountsFC = numel(expsFCInds);

exps40 = extractRows( exps, exps40Inds );
exps22 = extractRows( exps, exps22Inds );
expsBN = extractRows( exps, expsBNInds );
expsFC = extractRows( exps, expsFCInds );

result40 = findDoublets( exps40, expCounts40 );
result22 = findDoublets( exps22, expCounts22 );
resultBN = findDoublets( expsBN, expCountsBN );
resultFC = findDoublets( expsFC, expCountsFC );

result40 = sortrows( result40, 4 );
result22 = sortrows( result22, 4 );
resultBN = sortrows( resultBN, 4 );
resultFC = sortrows( resultFC, 4 );

plot(result40(:,4),undB(abs(result40(:,8)-result40(:,7))))
hold on
plot(result22(:,4),undB(abs(result22(:,8)-result22(:,7))))
plot(resultBN(:,4),undB(abs(resultBN(:,8)-resultBN(:,7))))
plot(resultFC(:,4),undB(abs(resultFC(:,8)-resultFC(:,7))))

legend({'.40','.22','Balloon','Firecracker'})

function result = findDoublets( arr, num )
    currFP = 0;
    currMeterIdx = 0;
    currDir = 0;
    currRange = 0;
    currSrc = 0;
    currdB = 0;
    rTmp = zeros(num,8);
    nextRow = 0;
	for e = 1 : num
		if( arr(e,13) == 0 | arr(e,11) == 0 )
		  continue
		end
		if( arr(e,13) > currMeterIdx )
			lastMeterIdx = currMeterIdx;
			currMeterIdx = arr(e,13);
			if( currFP == arr(e,1) & currDir == arr(e,2) & currRange == arr(e,14) & currSrc == arr(e,12) )
				display( sprintf( 'doublet found for %d/%g & %d/%g', lastMeterIdx, currdB, arr(e,13), arr(e,11) ) )
				nextRow = nextRow + 1;
				rTmp(nextRow,1) = currSrc;
				rTmp(nextRow,2) = currFP;
				rTmp(nextRow,3) = currDir;
				rTmp(nextRow,4) = currRange;
				rTmp(nextRow,5) = currMeterIdx;
				rTmp(nextRow,6) = arr(e,13);
				rTmp(nextRow,7) = currdB;
				rTmp(nextRow,8) = arr(e,11);
			else
				currSrc = arr(e,12);
				currFP = arr(e,1);
				currDir = arr(e,2);
				currRange = arr(e,14);
				currdB = arr(e,11);
            end
        end
	end

result = rTmp(1:nextRow,:);