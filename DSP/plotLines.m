function plotLines(dns)

numLines = numel(dns)

for t = 1 : numLines
  line([dns(t), dns(t)], get(gca,'YLim'), 'Color', [0 0 0])
end