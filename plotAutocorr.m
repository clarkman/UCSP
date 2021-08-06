function plotAutocorr( tds )

szData = size(tds);
numExps = szData(1);
numSens = szData(2);
numChns = szData(3);

numExps=22;
%numChns=1;
for d = 22 : numExps
	for s = 1 : numSens
		for c = 1 : numChns
			td = tds{d,s,c};
			fs = td.sampleRate;

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
			%[autocor,lags] = xcorr(samps,floor(xSecs/2*fs),'coeff');
			[autocor,lags] = xcorr(samps,'coeff');

			[pksh,lcsh] = findpeaks(autocor);
			short = mean(diff(lcsh))/fs;
			if ~isnan(short)
				freq = 1 / short;
				mPeak = ceil(short*fs);
				[pklg,lclg] = findpeaks(autocor,'MinPeakDistance',mPeak,'MinPeakheight',0.01);
				long = mean(diff(lclg))/fs;
				freqL = 1 / long;
				freqStr = sprintf('Short = %0.2f Hz\nLong = %0.2f Hz',freq,freqL);
			else
				freqStr = sprintf('Short = NaN Hz\nLong = NaN Hz');
			end

			plot(lags/fs,autocor)
			text(0,-0.5,freqStr,'HorizontalAlignment','center')
			set(gca,'XGrid','on');
			set(gca,'YGrid','on');
			set(gca,'YLim',[-1 1]);
			set(gca,'XLim',[lags(1) lags(end)]./fs);
			xlabel('Lag (seconds)')
			ylabel('Autocorrelation');
			title( [ 'Autocorrelation plot for: ', td.station, '/', td.channel ], 'Interpreter', 'none' );

			while 1

				[x1, y1, button] = ginput(1);

				if( button == 3 ) % done
				%	idNo = parseSerialNo( td.source )
					nameRoot = [ 'xcorr/xcorr-', td.station, '-', td.channel ]
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

