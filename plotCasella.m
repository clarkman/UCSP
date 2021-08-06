function plotCasella( arr )

cCol = 11;
rangeCol = 14;

srcKey = makeSrcKey;

% All ...
inds = find(arr(:,11)>0);
ar2 = extractRows( arr, inds );
% figure;
% plot(ar2(:,14),ar2(:,11),'Marker','o','LineStyle','none')
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'All Casella measurements')

% Caliber compare dB ...
% srcNum = findSrcKey( srcKey, '0.40' )
% inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
% ar40 = extractRows( ar2, inds );
% srcNum = findSrcKey( srcKey, '0.22' )
% inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
% ar22 = extractRows( ar2, inds );
% srcNum = findSrcKey( srcKey, 'StrtrPstl' )
% inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
% arSt = extractRows( ar2, inds );
% srcNum = findSrcKey( srcKey, 'frcrckr' )
% inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
% arFc = extractRows( ar2, inds );
% figure;
% plot(ar40(:,14),ar40(:,11),'Marker','o','LineStyle','none')
% hold on;
% plot(ar22(:,14),ar22(:,11),'Marker','d','LineStyle','none')
% plot(arSt(:,14),arSt(:,11),'Marker','+','LineStyle','none')
% plot(arFc(:,14),arFc(:,11),'Marker','*','LineStyle','none')
% legend({'.40 cal','.22 cal','Starter','Firecracker'})
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'Comparing Casella measurements re. Caliber')

% Caliber compare linear ...
srcNum = findSrcKey( srcKey, '0.40' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
ar40 = extractRows( ar2, inds );
srcNum = findSrcKey( srcKey, '0.22' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
ar22 = extractRows( ar2, inds );
srcNum = findSrcKey( srcKey, 'StrtrPstl' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
arSt = extractRows( ar2, inds );
srcNum = findSrcKey( srcKey, 'frcrckr' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum) ;
arFc = extractRows( ar2, inds );
figure;
plot(ar40(:,14),10.^(ar40(:,11)./20),'Marker','o','LineStyle','none')
hold on;
plot(ar22(:,14),10.^(ar22(:,11)./20),'Marker','d','LineStyle','none')
plot(arSt(:,14),10.^(arSt(:,11)./20),'Marker','+','LineStyle','none')
plot(arFc(:,14),10.^(arFc(:,11)./20),'Marker','*','LineStyle','none')
legend({'.40 cal','.22 cal','Starter','Firecracker'})
xlabel('range - ft.')
ylabel('sound pressure level - Lin')
title( 'Comparing Casella measurements re. Caliber')
set(gca,'YScale','log')
set(gca,'XGrid','on')
set(gca,'YGrid','on')
set(gca,'YLim',[1e5 1e8])


% Room compare ...
% inds = find( ar40(:,1)==1 ); % Principal's office
% arFp1 = extractRows( ar40, inds );
% fp1Ampl = 20*log10(10.^(arFp1(:,11)/20)./arFp1(:,14));
% inds = find( ar40(:,1)==2 ); % Principal's office
% arFp2 = extractRows( ar40, inds );
% fp2Ampl = 20*log10(10.^(arFp2(:,11)/20)./arFp2(:,14));
% inds = find( ar40(:,1)==8 ); % Principal's office
% arFp8 = extractRows( ar40, inds );
% fp8Ampl = 20*log10(10.^(arFp8(:,11)/20)./arFp8(:,14));
% inds = find( ar40(:,1)==9 ); % Principal's office
% arFp9 = extractRows( ar40, inds );
% fp9Ampl = 20*log10(10.^(arFp9(:,11)/20)./arFp9(:,14));

% figure;
% plot(arFp1(:,14),fp1Ampl,'Marker','o','LineStyle','none')
% hold on;
% plot(arFp2(:,14),fp2Ampl,'Marker','d','LineStyle','none')
% plot(arFp8(:,14),fp8Ampl,'Marker','+','LineStyle','none')
% plot(arFp9(:,14),fp9Ampl,'Marker','*','LineStyle','none')
% legend({'Admin Office sm/quiet','Cafeteria lg/loud','Atrium sm/loud','Library lg/quiet'})
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'Comparing Casella measurements re. Room')


