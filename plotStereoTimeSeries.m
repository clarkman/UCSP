function plotStereoTimeSeries(ch1,ch2,FS,offset,titl,ylims)

%Time Domain
sz = size(ch1);
t=0:1/FS:sz(1)/FS; t=t(1:end-1);

figure;
hold on;
plot(t,ch2+offset,'Color',[0 0 0.8]);
plot(t,ch1,'Color',[0.8 0 0]);

xlabel('secs')
ylabel('amplitude')
set(gca,'XLim',[t(1),t(end)])
title(titl)
legend({'ch1',sprintf('ch2+%3.2f',offset)})

if nargin > 5
	set( gca, 'YLim', ylims )
end

