function plotStereoTimeData(tds,titl,offset,ylims)

%Time Domain
tdLeft = tds{1};
tdRight = tds{2};

sampsL = tdLeft.samples;
sampsR = tdRight.samples;

sz = size(sampsL);
FS=tdLeft.sampleRate;
t=0:1/FS:sz(1)/FS; t=t(1:end-1);

figure;
hold on;
plot(t,sampsL+offset,'Color',[0.6 0 0.6]);
plot(t,sampsR,'Color',[0 0.5 0.0]);

xlabel('secs')
ylabel('amplitude')
set(gca,'XLim',[t(1),t(end)])
title(titl)
legend({sprintf('Violet (Left) + %3.2f',offset),'Green (Right)'})

if nargin > 3
	set( gca, 'YLim', ylims )
end

