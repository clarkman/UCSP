function [ tdObj ] = readLJDat( fname, sampRate )
%UNTITLED Read LabJack Data files
%   Detailed explanation goes here

fid = fopen(fname)
if( fid == -1 )
    error(['Could not open: ', fname])
end

hline = fgetl(fid); disp(hline);
hline = fgetl(fid); disp(hline);
hline = fgetl(fid); disp(hline);
hline = fgetl(fid); disp(hline);
hline = fgetl(fid); disp(hline);
hline = fgetl(fid); disp(hline);

arrTmp=zeros(1000000,5);
r=0;

while 1
  tline = fgetl(fid);
  if ~ischar(tline), break, end
  %disp(tline)
  S=sscanf(tline,'%f');
  r=r+1;
  arrTmp(r,:) = S(1:5);
end
  
arr=arrTmp(1:r,:);

fclose(fid)

end

