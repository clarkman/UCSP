function dnArray = spoolTimeArray( fileList )

fid = fopen(fileList);
if fid == -1
  error('FileNotFound');
end

dnArrayTmp = zeros(100000,1);

rowth = 0;
while 1
    nextl = fgetl(fid);
    if ~ischar(nextl)
        display(sprintf('Read %d data rows',rowth))
        break
    end
    rowth = rowth + 1;
    dnArrayTmp(rowth) = spoolNameToDN(nextl);
end

dnArray = sortrows(dnArrayTmp(1:rowth),1);

fclose(fid);

end