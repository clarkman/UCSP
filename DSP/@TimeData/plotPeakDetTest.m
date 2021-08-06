function plotPeakDetTest( seg, maxtab, mintab, pulses, t, tail ) 

%[maxtab, mintab]=peakdet(d, t);

sz=size(maxtab);
numMax=sz(1);
sz=size(mintab);
numMin=sz(1);

figure;
plot(seg.samples);


aa=get(gca,'YLim');
aum = min( -aa(1), aa(2) );
set(gca,'YLim', [-aum, aum]);

numPassedMax = 0;
for i = 1: numMax
  %if( t < maxtab(i,2) )
    line( [maxtab(i,1), maxtab(i,1)],[0 aa(2)], 'Color', [0.818, 0.4, 0.4])
    numPassedMax = numPassedMax + 1;
  %end
end

numPassedMin = 0;
for i = 1: numMin
  %if( -t > mintab(i,2) )
    line( [mintab(i,1), mintab(i,1)],[aa(1) 0], 'Color', [0.4, 0.818, 0.4])
    numPassedMin = numPassedMin + 1;
  %end
end



sz=size(pulses);
numPulses = sz(1);
inPulse = 0;
clearColor = [0.5, 0.5, 0.85];
%redd=pulses(1:25,:)

numFrames=0;
for p = 1 : numPulses
  if( inPulse )
    if( pulses(p,5) >= 0 )
      inPulse = 0;
      numFrames=numFrames+1;
      hold on;
display( sprintf( 'Drawing Pulse at: %d-%d', left, pulses(p,1) ) )
        fill( [left, pulses(p-1,1), pulses(p-1,1), left], [-aum, -aum, aum, aum], clearColor, 'FaceAlpha', 0.5, 'EdgeColor', 'none'  );
      hold off;
    else
      continue;
    end
  else
    if( pulses(p,5) >= 0 )
      inPulse = 1;
      left = pulses(p,1);
      if( pulses(p,5) == 2 )
        clearColor = [0.85, 0.5, 0.85];
      else
        clearColor = [0.85, 0.85, 0.5];
      end
    end
  end
end
%  numFrames
hold on;
  plot(seg.samples);
hold off;
set(gca,'YLim', [-aum, aum]);

line( get(gca,'XLim'), [t t] )
line( get(gca,'XLim'), [-t -t] )

return
[x, y, button] = ginput(1);
close('all')
%  if( button == 3 )
%    mS1 = y;
%    close( 'all' );
%    continue;
%  end
%  if( button == 2 )
%    fact = fact * 2;
%    close( 'all' );
%    continue;
%  end

