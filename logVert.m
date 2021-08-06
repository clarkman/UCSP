function vLog = logVert( sig )

sz = size(sig);
if sz(2) ~= 1 
  error('nx1 arrays only!')
end

numSamps = sz(1);

pos = zeros(1,numSamps);
neg = pos;

for s = 1 : numSamps
  samp = sig(s);
  if samp >= 0
  	pos(s) = samp;
  else
  	neg(s) = samp;
  end
end

pos_dB = log10(pos).*20.0;
plot(pos_dB)
figure
%plot(neg*-1)
neg_dB = log10(neg*-1)*-1;
plot(neg_dB)

vLog = (pos_dB + neg_dB)';
plot(vLog)
