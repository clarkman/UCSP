function genFBDailyPlots( network, sites, bands, channels, date, outFileName, viewPlots )
%
% function genFBDailyPlots( network, site, date, ENABLE_SAVE )
%
% - Calculates a daily plot of filter bank output from a single site.


RESIZE   = '760x440!';
QUALITY  = 80;

if outFileName == 0,
	ENABLE_SAVE = 0;
else
	ENABLE_SAVE = 1;
end

for fb=bands
	for site=sites


		try

            if( viewPlots )
                [ab] = plotFBssmcsb(network,site,fb,channels,date,date,'pT','','plotQuartiles','logPlot','viewPlots');
            else
                [ab] = plotFBssmcsb(network,site,fb,channels,date,date,'pT','','plotQuartiles','logPlot');
            end

            if ENABLE_SAVE,
                fNamePng = sprintf('%s.png',outFileName)
                fNameGif = sprintf('%s.gif',outFileName)
                saveas(gcf,fNamePng,'png');
                system( sprintf( 'chmod a+w %s', fNamePng ) );
                system( sprintf( 'convert %s %s ', fNamePng, fNameGif ) );
                system( sprintf( 'convert -resize %s -quality %d %s %s ', RESIZE, QUALITY, fNameGif, fNameGif ) );
                system( sprintf( 'rm %s', fNamePng ) );
            end

		catch
			display('FAILURE')
        end
    
	end
end
display('genFBDailyPlots.m successful')
display('SUCCESS')
return

