function arr = fixUp(vals,sensors)

sz = size(vals);
numRows = sz(1);
numCols = sz(2);

sz = size(sensors);
numSensors = sz(1);
sensorIDs = cell2mat( {sensors{:,1}} );
friendlyNums = cell2mat( {sensors{:,2}} );

arrTmp = zeros(numRows,numCols);

for row = 1 : numRows
  sensor = cell2mat(vals(row,1));
  sensorIdx = find( sensorIDs == sensor );
  arrTmp(row,1) = friendlyNums(sensorIdx);
end


for col = 2 : numCols
	%colVals = cell2mat( {vals{:,col}} );
	arrTmp(:,col) = cell2mat( {vals{:,col}} );
end

arr = sortrows(arrTmp,2);
