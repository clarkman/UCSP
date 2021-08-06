function mspecTest( obj, minFrequ, maxFrequ, filterlengths )

corder = get(gca,'ColorOrder');     % use the standard color ordering matrix
ncolors = size(corder);
ncolors = ncolors(1,1);

numLengths = length( filterlengths );

%minFrequ = 1199;
%maxFrequ = 1201;
%minFrequ = 599;
%maxFrequ = 601;
%set(get(gcf,'CurrentAxes'),'XLim',[minFrequ maxFrequ]);

icolor = 1;
for ith = 1 : numLengths
    [freqs, mags] = mspecSweep( minFrequ, maxFrequ, 0.05, filterlengths(ith), obj );
    
    hold on;
    plot( freqs, mags, 'Color', corder(icolor,:) );
    hold off;
    
    % Rotate through the colors
    icolor = mod(icolor, ncolors);
    icolor = icolor + 1;
    
    legends{ith} = sprintf( '%f sec', filterlengths(ith) );
end
legend( legends );

return;

figure; mspecTest( MG3XXASouthUS03May0028B, 1199, 1201, [0.1, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 5.0, 10.0] );
figure; mspecTest( MG3XXASouthUS03May0028B, 599, 601, [0.1, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 5.0, 10.0] );

