function colr = getColor(idx,pale)

if nargin < 2
  pale = 0;
end

colrs = zeros(6,3);
colrs(1,:) = [126 47 142];
colrs(2,:) = [217 83 25];
colrs(3,:) = [77 190 238];
colrs(4,:) = [0 114 189];
colrs(5,:) = [119 172 48];
colrs(6,:) = [237 177 32];

colrs = colrs ./ 256;

colr = colrs(idx,:);

if pale
  hsv = rgb2hsv(colr);
  colr = hsv2rgb([hsv(1), hsv(2)/1.6, 0.95]);
end