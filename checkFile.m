function fileName = checkFile( fName )

fid = fopen(fName);
if fid == -1 
  error( [ 'File: ', fName, ' not FOUND!!!'] )
end

fclose(fid);
fileName = fName;