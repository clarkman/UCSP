function fName = makeFileName( fpIdx, srcIdx, sensorNumber, fileIdx, name, ext )

fpKey = makeFpKey;
srcKey = makeSrcKey;

fpName = fpKey(fpIdx).name;
srcName = srcKey(srcIdx).name;
% Removed: hexName = makeHexName(sensorNumber);
sensNum = sprintf('%d',sensorNumber);
fileNum = sprintf('%d',fileIdx);

fName = [ fpName, '-', srcName, '-', sensNum, '-', fileNum, '-', name, ext ];

