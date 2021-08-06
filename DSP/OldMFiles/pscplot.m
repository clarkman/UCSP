function pscplot(indata, plotTitle, xtitle, ytitle, symbol)
% Plots indata against its index.
% Adds plotTitle as the plot title, and labels the x and y axes using
% ztitle and ytitle.
% Optional:  Uses "symbol" (as defined in the Matlab "plot" function) as
% the symbol for each plotted point.

figure;
if (nargin == 5)
    plot(1:length(indata), indata, symbol);
else
    plot(indata);
end

title(plotTitle);
xlabel(xtitle);
ylabel(ytitle);
grid on;

orient landscape;
