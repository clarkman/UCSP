function pscTimeOverlay(indata1, indata2, fs, plotTitle, ytitle)
% Overlays indata1 and indata2 on the same plot.
%  Plots them against time.
% Adds plotTitle as the plot title, and labels the y axis using
% ytitle. 

figure;
len = min(length(indata1), length(indata2));
T = 0: 1/fs: (len-1)/fs;
plot(T, indata1(1:len), T, indata2(1:len));
title(plotTitle);
xlabel('Time (sec)');
ylabel(ytitle);
grid on;
