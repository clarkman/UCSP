function expsOut = getCasellaExps( exps )

% Select only Casella exps first
casellaIdxs = find( exps(:,11) > 0 );
exps = extractRows( exps, casellaIdxs );
%sz = size(exps);

% Now filter out everything but sensors near Casella.  Do Library separately.
idCol = 4;
cInds1 = find( exps(:,idCol) == 205 | exps(:,idCol) == 1024 | exps(:,idCol) == 1067 | exps(:,idCol) == 784 | exps(:,idCol) == 1020 | exps(:,idCol) == 1042 | exps(:,idCol) == 1033 | exps(:,idCol) == 1034 | exps(:,idCol) == 1054 | exps(:,idCol) > 9000 );

% Library had two Casella positions
dnMove = datenum('2015/09/23 00:00:00');
cInds2 = find( exps(:,idCol) == 1061 & exps(:,10) < dnMove );
cInds3 = find( exps(:,idCol) == 1062 & exps(:,10) > dnMove );

cInds = [ cInds1 ; cInds2 ; cInds3 ];
cInds=unique(sort(cInds));
expsOut = extractRows( exps, cInds );
