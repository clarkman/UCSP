function plotFlashBang( flash, bang )

period = 1/12000;

len = length(flash)
if len ~= length(flash)
  error('whappened?')
end


tVec = period/2:period:period*len;
length(tVec)


flash = flash - mean(flash);
bang = bang - mean(bang);

figure;
plot(tVec, flash+0.01)
hold on;
plot(tVec, bang-0.01)

title('Incident 3731, Cafeteria North Entrance, sensor ISU-00-BEN-0112')
ylabel('normalized units')
xlabel('seconds')

set(gca, 'XLim', [0.5 3] )
set(gca, 'YLim', [-0.1 0.1] )
%datetick('x','SS.FFF')
