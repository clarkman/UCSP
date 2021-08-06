function rangeArr = parseRangeCSV( fName )

fid = fopen( fName )

daLine = fgetl( fid )

numFound = 0;
while 1
  daLine = fgetl( fid );
  if daLine == -1
  	break
  end
  numFound = numFound + 1;
  strs = strsplit( daLine, ',' )
  fp = sscanf(strs{1},'%d')
  sn = sscanf(strs{2},'%s')
  ft = sscanf(strs{3},'%g')
  los = sscanf(strs{4},'%d')
  s(numFound) = struct('fp',fp,'sn',sn,'ft',ft,'los',los)
end

fclose( fid );

rangeArr = s;