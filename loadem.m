function [ exps, expLbls, sensors, fps, fpLbls, bldgNames, bldgNumbers, roomNames ] = loadem()

expsFile = 'ExperimentMatrix.csv';
sensorsFile = 'Sensors.csv';
fpsFile = 'FiringPositions.csv';

srcKey = makeSrcKey;

% Experiments ===================================================
efid = fopen( expsFile );
if efid == -1 
  error([ 'Could not open: ', expsFile ]);
end

numRead = 0;
while 1
  daLine = fgetl( efid );
  if( daLine == -1 )
    break;
  end
  numRead = numRead + 1;
end
frewind( efid );

ncol=13;
expArray = zeros(numRead,ncol);
row = zeros(1,ncol);	
lbls = cell(1,ncol);	

% Make header names
daLine = fgetl( efid );
cs = strfind(daLine,',');
lbls{1} = daLine(cs(4)+1:cs(5)-1);
lbls{2} = daLine(cs(5)+1:cs(6)-1);
lbls{3} = daLine(cs(8)+1:cs(9)-1);
lbls{4} = daLine(cs(9)+1:cs(10)-1);
lbls{5} = daLine(cs(10)+1:cs(11)-1);
lbls{6} = daLine(cs(11)+1:cs(12)-1);
lbls{7} = daLine(cs(12)+1:cs(13)-1);
lbls{8} = daLine(cs(13)+1:cs(14)-1);
lbls{9} = daLine(cs(14)+1:cs(15)-1);
lbls{10} = 'datenum';
lbls{11} = daLine(cs(17)+1:cs(18)-1);
lbls{12} = daLine(cs(6)+1:cs(7)-1);
lbls{13} = daLine(cs(18)+1:end);

for s = 1 : numRead
%for s = 201 : numRead

  daLine = fgetl( efid );

  if numel(daLine) <= 1
  	break;
  end

  cs = strfind(daLine,',');

  if(cs(2)-cs(1)==1) % Numbers puts out empty lines, arg
    break;
  end

  bldgNames{s} = daLine(cs(1)+1:cs(2)-1);
  bldgNumbers{s} = daLine(cs(2)+1:cs(3)-1);
  roomNames{s} = daLine(cs(3)+1:cs(4)-1);

  row(1,1) = sscanf( daLine(cs(4)+1:cs(5)-1), '%d' );
  row(1,2) = sscanf( daLine(cs(5)+1:cs(6)-1), '%d' );
  row(1,3) = sscanf( daLine(cs(8)+1:cs(9)-1), '%d' );
  row(1,4) = sscanf( daLine(cs(9)+1:cs(10)-1), '%d' );
  row(1,5) = sscanf( daLine(cs(10)+1:cs(11)-1), '%d' );
  row(1,6) = sscanf( daLine(cs(11)+1:cs(12)-1), '%g' );
  row(1,7) = sscanf( daLine(cs(12)+1:cs(13)-1), '%g' );
  row(1,8) = sscanf( daLine(cs(13)+1:cs(14)-1), '%g' );
  row(1,9) = sscanf( daLine(cs(14)+1:cs(15)-1), '%g' );
  row(1,10) = datenum( [ daLine(cs(15)+1:cs(16)-1), ' ', daLine(cs(16)+1:cs(17)-1) ] );
  row(1,11) = sscanf( daLine(cs(17)+1:cs(18)-1), '%g' );
  row(1,12) = findSrcKey( srcKey, daLine(cs(6)+1:cs(7)-1) );
  row(1,13) = sscanf( daLine(cs(18)+1:end), '%d' );

  expArray(s,:) = row;

end
exps = expArray;
expLbls = lbls;

fclose( efid )


% Sensors =====================================================
sfid = fopen( sensorsFile );
if sfid == -1 
  error([ 'Could not open: ', sensorsFile ]);
end

numRead = 0;
while 1
  daLine = fgetl( sfid );
  if( daLine == -1 )
    break;
  end
  numRead = numRead + 1;
end
frewind( sfid );

daLine = fgetl( sfid );
for s = 1 : numRead

  daLine = fgetl( sfid );

  if numel(daLine) <= 1
  	break;
  end

  cs = strfind(daLine,',');

  sens(s).sensId = sscanf( daLine(cs(7)+1:cs(8)-1), '%d' );
  sens(s).sensHex = daLine(cs(8)+1:cs(9)-1);
  sens(s).orient = daLine(cs(9)+1:cs(10)-1);
  sens(s).mounting = daLine(cs(10)+1:cs(11)-1);
  sens(s).height = sscanf( daLine(cs(11)+1:cs(12)-1), '%g' );

end
sensors = sens;
fclose( sfid );


% Firing Positions ==============================================
fpfid = fopen( fpsFile );
if fpfid == -1 
  error([ 'Could not open: ', fpsFile ]);
end

numRead = 0;
while 1
  daLine = fgetl( fpfid );
  if( daLine == -1 )
    break;
  end
  numRead = numRead + 1;
end
frewind( fpfid );

ncol=4;
fpArray = zeros(numRead,ncol);
row = zeros(1,ncol);
lbls = cell(1,ncol);	

% Make header labels
daLine = fgetl( fpfid );
cs = strfind(daLine,',');
lbls{1} = daLine(cs(4)+1:cs(5)-1);
lbls{2} = daLine(cs(5)+1:cs(6)-1);
lbls{3} = daLine(cs(6)+1:cs(7)-1);
lbls{4} = daLine(cs(7)+1:end);


for s = 1 : numRead

  daLine = fgetl( fpfid );

  if numel(daLine) <= 1
  	break;
  end

  cs = strfind(daLine,',');

  row(1,1) = sscanf( daLine(cs(4)+1:cs(5)-1), '%d' );
  row(1,2) = sscanf( daLine(cs(5)+1:cs(6)-1), '%d' );
  row(1,3) = sscanf( daLine(cs(6)+1:cs(7)-1), '%d' );
  row(1,4) = sscanf( daLine(cs(7)+1:end), '%d' );

  fpArray(s,:) = row;

end
fps = fpArray;
fpLbls = lbls;

fclose( fpfid );




