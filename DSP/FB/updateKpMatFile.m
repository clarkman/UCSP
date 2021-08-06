function success = updateKpMatFile(kpDiffTxtFile)
% function success = updateKpMatFile(kpDiffTxtFile)
% 
% Loads kp .mat file and kpDiff .txt file. Then, it appends the data from 
% the .txt file to the .mat file, overwriting the values with the same 
% datenum. This .mat file is used for future fast loads of Kp data.

% Kp env variables.
[status, kprmf] = system( 'echo -n $KPOUTPUTMAT' );
if( length( kprmf ) == 0 )
    display( 'ERROR: env must contain KPOUTPUTMAT variable found in $QFDC/include/qfpaths.bash' );
    display( 'ENVIRONMENT' );
    success = -1;
    return
end

% This file is not here!!! Parent directory "html" has been removed
% [status, kpamf] = system( 'echo -n $KPALLMAT' );
% if( length( kpamf ) == 0 )
%     display( 'ERROR: env must contain KPALLMAT variable found in $QFDC/include/qfpaths.bash' );
%     display( 'ENVIRONMENT' );
%     success = -1;
%     return
% end

% Load .mat file that needs to be updated.
try
    display( sprintf('Loading .mat file: %s', kprmf) )
    cmd = sprintf( 'load %s', kprmf );
    eval( cmd );
catch
    display( 'Error loading .mat file!' )
    display( 'BAD_LOAD' )
    success = -1;
    return
end

% Read in entries from .txt file
try
	display( sprintf('Reading .txt file: %s',kpDiffTxtFile) )
	[kpdateDiff,kptimeDiff,kp10Diff,kpstatusDiff] = textread(kpDiffTxtFile, '%s %s %f %s');
	kpspDiff    = char(32*ones(size(kpdateDiff))); % vert. array of spaces
	kpdtDiff    = datevec([cell2mat(kpdateDiff) kpspDiff cell2mat(kptimeDiff)]);
	kpdtnumDiff = datenum( kpdtDiff );
	kpDiff      = kp10Diff/10;  % div by 10 to get it to proper Kp value
catch
    display( 'Error reading .txt file!')
    display( 'BAD_READ' )
    success = -1;
    return
end

% Search for overlap (updated) entries based on datenum
% Append entry if there is no overlap
for i=1:size(kpdtnumDiff,1)
    ikpdtnumDiff = kpdtnumDiff(i,1);
    updateInd = find( kpdtnum == ikpdtnumDiff );
    if( ~isempty(updateInd) )
        display( sprintf('Updating entry with index %d, datenum %d',updateInd,ikpdtnumDiff) )
        kp(updateInd,:) = kpDiff(i,:);
        kp10(updateInd,:) = kp10Diff(i,:);
        kpdate(updateInd,:) = kpdateDiff(i,:);
        kpdt(updateInd,:) = kpdtDiff(i,:);
        kpdtnum(updateInd,:) = kpdtnumDiff(i,:);
        kpsp(updateInd,:) = kpspDiff(i,:);
        kpstatus(updateInd,:) = kpstatusDiff(i,:);
        kptime(updateInd,:) = kptimeDiff(i,:);
    else
        kp = [kp;kpDiff(i,:)];
        kp10 = [kp10;kp10Diff(i,:)];
        kpdate = [kpdate;kpdateDiff(i,:)];
        kpdt = [kpdt;kpdtDiff(i,:)];
        kpdtnum = [kpdtnum;kpdtnumDiff(i,:)];
        kpsp = [kpsp;kpspDiff(i,:)];
        kpstatus = [kpstatus;kpstatusDiff(i,:)];
        kptime = [kptime;kptimeDiff(i,:)];
    end % if( ~isempty(updateInd) )
end % for i=1:size(kpdtnumDiff,1)

% Save entries to .mat file
try
    display( sprintf('Saving .mat file: %s', kprmf) )
    cmd = sprintf( 'save %s kp kp10 kpamf kpatf kpdate kpdt kpdtnum kprmf kprtf kpsp kpstatus kptime', kprmf );
    eval( cmd );
catch
    display( 'Error saving .mat file!' )
    display( 'BAD_WRITE' )
    success = -1;
    return
end

display('Updated .mat file')
display('SUCCESS')
success = 0;
return

