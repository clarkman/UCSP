function plotAudio( ar2, sens )

cCol = 11;
rangeCol = 14;

srcKey = makeSrcKey;

% All ...
% figure;
% plot(ar2(:,14),ar2(:,11),'Marker','o','LineStyle','none')
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'All Casella measurements')
numCasellas = numel(find( ar2(:,11) > 0 ))

%Caliber compare dB ...
polyDeg=1;
denom=20;
srcNum = findSrcKey( srcKey, '0.40' );
inds = find( ar2(:,11)>110 & ar2(:,12)==srcNum) ;
ar40 = extractRows( ar2, inds );

%P40 = polyfit(ar40(:,14),undB(ar40(:,11)),polyDeg)
P40 = polyfit(ar40(:,14),10.^(ar40(:,11)/denom),polyDeg)
%P40 = polyfit(ar40(:,14),exp(ar40(:,11)),polyDeg)
X40 = sort(ar40(:,14));
Y40 = polyval(P40,X40);
srcNum = findSrcKey( srcKey, '0.22' );
inds = find( ar2(:,11)>100 & ar2(:,12)==srcNum) ;
ar22 = extractRows( ar2, inds );
%P22 = polyfit(ar22(:,14),undB(ar22(:,11)),polyDeg)
P22 = polyfit(ar22(:,14),10.^(ar22(:,11)/denom),polyDeg)
%P22 = polyfit(ar22(:,14),exp(ar22(:,11)),polyDeg)
X22 = sort(ar22(:,14));
Y22 = polyval(P22,X22);
srcNum = findSrcKey( srcKey, 'StrtrPstl' );
inds = find( ar2(:,11)>100 & ar2(:,12)==srcNum) ;
arSt = extractRows( ar2, inds );
PSt = polyfit(arSt(:,14),10.^(arSt(:,11)/denom),polyDeg)
%PSt = polyfit(arSt(:,14),exp(arSt(:,11)),polyDeg)
XSt = sort(arSt(:,14));
YSt = polyval(PSt,XSt);
srcNum = findSrcKey( srcKey, 'frcrckr' );
inds = find( ar2(:,11)>100 & ar2(:,12)==srcNum) ;
arFc = extractRows( ar2, inds );
PFc = polyfit(arFc(:,14),10.^(arFc(:,11)/denom),polyDeg)
%PFc = polyfit(arFc(:,14),exp(arFc(:,11)),polyDeg)
XFc = sort(arFc(:,14));
YFc = polyval(PFc,XFc);

figure;
plot(ar40(:,14),undB(ar40(:,11)),'Marker','o','LineStyle','none')
hold on;
%plot(X,Y)
plot(ar22(:,14),undB(ar22(:,11)),'Marker','d','LineStyle','none')
plot(arSt(:,14),undB(arSt(:,11)),'Marker','+','LineStyle','none')
plot(arFc(:,14),undB(arFc(:,11)),'Marker','*','LineStyle','none')
legend({'.40 cal','.22 cal','Starter','Firecracker'})
xlabel('range - ft.')
ylabel('sound pressure level - dB')
title( [ 'Comparing ', sprintf('%d',numCasellas), ' Casella measurements re. Caliber' ] )
ax=get(gca,'XLim')
%set(gca,'YLim',[100 160])
set(gca,'XGrid','on')
set(gca,'YGrid','on')
ay=get(gca,'YLim')

plot(X40,Y40,'Color',[0, 114, 189]./255,'LineStyle',':');
plot(X22,Y22,'Color',[217, 83, 25]./255,'LineStyle',':');
plot(XSt,YSt,'Color',[237, 117, 32]./255,'LineStyle',':');
plot(XFc,YFc,'Color',[126, 47, 142]./255,'LineStyle',':');

% plot(X40,denom.*log10(abs(Y40)),'Color',[0, 114, 189]./255,'LineStyle',':');
% plot(X22,denom.*log10(abs(Y22)),'Color',[217, 83, 25]./255,'LineStyle',':');
% plot(XSt,denom.*log10(abs(YSt)),'Color',[237, 117, 32]./255,'LineStyle',':');
% plot(XFc,denom.*log10(abs(YFc)),'Color',[126, 47, 142]./255,'LineStyle',':');

return

% Caliber compare linear ...
srcNum = findSrcKey( srcKey, '0.40' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum & ar2(:,5)>0 );
ar40 = extractRows( ar2, inds );
peaks = getPeaks( ar40, sens );
dBV_Audio = 20*log10(peaks(:,1));
dBV_Piezo = 20*log10(peaks(:,2));
figure;
plot(ar40(:,14),dBV_Audio,'Marker','o','LineStyle','none')
hold on;
plot(ar40(:,14),dBV_Piezo,'Marker','d','LineStyle','none')
legend({'audio','piezo'});
xlabel('range - ft.')
ylabel('amplitude - dBV')
title( 'Signal peaks from .40 Caliber')
%set(gca,'YLim',[80 160]);
set(gca,'XLim',ax)
set(gca,'YLim',ay-160)

srcNum = findSrcKey( srcKey, '0.22' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum & ar2(:,5)>0 );
ar22 = extractRows( ar2, inds );
peaks = getPeaks( ar22, sens );
dBV_Audio = 20*log10(peaks(:,1));
dBV_Piezo = 20*log10(peaks(:,2));
figure;
plot(ar22(:,14),dBV_Audio,'Marker','o','LineStyle','none')
hold on;
plot(ar22(:,14),dBV_Piezo,'Marker','d','LineStyle','none')
legend({'audio','piezo'});
xlabel('range - ft.')
ylabel('amplitude - dBV')
title( 'Signal peaks from .22 Caliber');
set(gca,'XLim',ax)
set(gca,'YLim',ay-160)

srcNum = findSrcKey( srcKey, 'StrtrPstl' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum & ar2(:,5)>0 );
arSp = extractRows( ar2, inds );
peaks = getPeaks( arSp, sens );
dBV_Audio = 20*log10(peaks(:,1));
dBV_Piezo = 20*log10(peaks(:,2));
figure;
plot(arSp(:,14),dBV_Audio,'Marker','o','LineStyle','none')
hold on;
plot(arSp(:,14),dBV_Piezo,'Marker','d','LineStyle','none')
legend({'audio','piezo'});
xlabel('range - ft.')
ylabel('amplitude - dBV')
title( 'Signal peaks from Starter Pistol');
set(gca,'XLim',ax)
set(gca,'YLim',ay-160)

srcNum = findSrcKey( srcKey, 'frcrckr' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum & ar2(:,5)>0 );
arFc= extractRows( ar2, inds );
peaks = getPeaks( arFc, sens );
dBV_Audio = 20*log10(peaks(:,1));
dBV_Piezo = 20*log10(peaks(:,2));
figure;
plot(arFc(:,14),dBV_Audio,'Marker','o','LineStyle','none')
hold on;
plot(arFc(:,14),dBV_Piezo,'Marker','d','LineStyle','none')
legend({'audio','piezo'});
xlabel('range - ft.')
ylabel('amplitude - dBV')
title( 'Signal peaks from firecracker');
set(gca,'XLim',ax)
set(gca,'YLim',ay-160)

return
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


