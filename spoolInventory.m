function [ spoolNames, spoolTS, spoolIdxs ] = spoolInventory()

% depends on mkFiles.bash running first:
%
% #!/bin/bash
%
% PRG=$(echo $0 | awk -F/ '{print $NF}')
%
% ls > $PRG.tmp
%
% while read SENSOR
% do
%   if ! [ 'SCP' ==  ${SENSOR:0:3} ]; then
%     continue
%   fi
%   echo "doing "$SENSOR
%   find $SENSOR -type f | awk '{print $0}' > $SENSOR.paths
%   find $SENSOR -type f | awk -F/ '{print $NF}' > $SENSOR.files
% done < $PRG.tmp
%
% rm $PRG.*
%
% exit 0;
%
% The result is a per-sensor list of files

listings = strsplit(ls('*.files'));
numListings = numel(listings);

for l = 1 : numListings
  listing = listings{l};
  if isempty(listing)
    continue
  end
  spoolNames{l} = listing;
  dnArray = spoolTimeArray( listing );
  segs = spoolContiguous( dnArray );
  spoolIdxs{l} = segs;
  numSegs = numel(segs);
  if numSegs < 1
  	spoolTSTmp{l} = {};
  else
    for s = 1 : numSegs
    	sl = segs{s};
    	segl{s} = [ dnArray(sl(1)), dnArray(sl(2)) ]
    end
    spoolTSTmp{l} = segl;
  end
end

spoolTS = spoolTSTmp;


return

