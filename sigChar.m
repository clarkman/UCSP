function [params,fn] = sigChar( tok )

if isempty(tok)
  [stat, files] = system( 'ls | grep -v '').wav'' | grep ''wav$''' )
else
  files = ls(['*' tok '*']);
end

strs = strsplit(files,'\n');

numFiles = numel(strs);
data = zeros(numFiles-1,6);
for f = 1 : numFiles
  file = strs{f};
  if isempty(file)
  	break
  end
  toks = strsplit(file,'_');
  fn{f} = [ '0', toks{4} ];
  datum = audioread(file);
  data(f,1) = sscanf(toks{4},'%d');
  data(f,2) = mean(datum);
  data(f,3) = 20*log10((2*sqrt(2)*std(datum))/2.0);
  data(f,4) = max(datum)-min(datum);
  data(f,5) = 20*log10((max(datum)-min(datum))/2.0);
  data(f,6) = skewness(datum);
end


params = data;
