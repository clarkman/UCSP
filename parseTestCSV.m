function testArr = parseTestCSV( fName )

fid = fopen( fName )

daLine = fgetl( fid );

lbls = strsplit( daLine, ',' );

numFound = 0;
while 1
  daLine = fgetl( fid );
  if daLine == -1
  	break
  end
  numFound = numFound + 1;
  strs = strsplit( daLine, ',' );
  tIdx = sscanf(strs{1},'%d');
  fp = sscanf(strs{2},'%d');
  gun = sscanf(strs{3},'%s');
  taps = sscanf(strs{4},'%d');
  dBAccel = sscanf(strs{5},'%d');
  dBMic = sscanf(strs{6},'%d');
  dBPbS = sscanf(strs{7},'%d');
  dBSi = sscanf(strs{8},'%d');
  CEL = sscanf(strs{9},'%g');
  angl = sscanf(strs{10},'%d');
  s(numFound) = struct(lbls{1},tIdx,lbls{2},fp,lbls{3},gun,lbls{4},taps,lbls{5},dBAccel,lbls{6},dBMic,lbls{7},dBPbS,lbls{8},dBSi,lbls{9},CEL,lbls{10},angl);
end

fclose( fid );

testArr = s;