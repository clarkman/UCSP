function plotAutocorr( tds )

szData = size(tds);
numExps = szData(1);
numSens = szData(2);
numChns = szData(3);

numExps=22;
numChns=6;
for d = 22 : numExps
	for s = 1 : numSens
		for c = 6 : numChns
			td = tds{d,s,c};
			if ~isa( td, 'TimeData' )
				continue
			end
			fs = td.sampleRate;

			%datestr(td.UTCref)

			t = (0:length(td) - 1)/fs;
			plot(t,td.samples)

			p = -1;
			while 1

			  [x1Tmp, y1Tmp, button] = ginput(1);
			  if( p ~= -1 )
			  	delete(p);
			  end
			  if( button == 3 ) % done
			  	close('all')
			    break;
			  end
			  [x2Tmp, y2Tmp, button] = ginput(1);
			  if( button == 3 ) % done
			  	close('all')
			    break;
			  end

			  if( button == 1 ) % done
			  	x1=x1Tmp; x2=x2Tmp;
			  	y1=y1Tmp; y2=y2Tmp;
			    xs = [ x1, x1, x2, x2, x1 ];
			    ys = [ y1, y2, y2, y1, y1 ];
			    p = patch('XData',xs,'YData',ys,'EdgeColor','k','FaceColor','none','LineWidth',1);
			  end

			end

			sigLength = abs(x2-x1);
			display(sprintf('Analyzing a segment %0.3f seconds long.',sigLength))
			if sigLength < 0.5
				td
				close('all')
				warning('Selected signal too short');
				continue
			end

			if x2 > x1
				xSecs = x2-x1;
				x1Samps = ceil(x1*fs);
				x2Samps = floor(x2*fs);
			elseif x1 > x2
				xSecs = x1-x2;
				x1Samps = ceil(x2*fs);
				x2Samps = floor(x1*fs);
			else
				td
				error('x1 and x2 are equal!');
			end

			samps = td.samples - mean(td); 
			samps = samps(x1Samps:x2Samps);

			td.samples = samps;
			spect = spectrum(td,4096*2)
			plot(spect);

            yLim = [5e-5 10];
			set(gca,'YLim',yLim);
			set(gca,'XGrid','on');
			set(gca,'YGrid','on');
			set(gca,'XScale','log');
			set(gca,'YScale','log');
			set(gca,'XLim', [ spect.freqResolution, td.sampleRate/2 ]);

			title( [ 'Spectrum plot for: ', td.station, '/', td.channel ], 'Interpreter', 'none' );

			line([60 60],yLim,'Color','k','LineStyle','--');
			line([120 120],yLim,'Color','k','LineStyle','--');
			plotHt = yLim(2) - yLim(1);
			htPct = 0.75;
			txtHt = yLim(1) + plotHt * htPct;
			text(60,txtHt,'60 Hz','HorizontalAlignment','center');
			text(120,txtHt,'120 Hz','HorizontalAlignment','center');

			set(gcf, 'OuterPosition', [ 400 500 600*7/6 600 ] )
			while 1

				[x1, y1, button] = ginput(1);

				if( button == 3 ) % done
				%	idNo = parseSerialNo( td.source )
					nameRoot = [ 'spectra/spectrum-', td.station, '-', td.channel ]
					print( gcf,'-djpeg100', [ nameRoot, '.jpg' ] );
					savefig( [ nameRoot, '.fig' ] )
					close('all')
					break;
				end
				if( button == 2 ) % done
					return;
				end

			end
		end
	end
end

