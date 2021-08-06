function ok = testLoads( arr, sens )

sz = size(arr);

for s = 1 : sz(1)
  if arr(s,3) ~= -9999
  	s
    [ data, fNames ] = loadData( arr, s, sens );
  end
end

ok = 1;
