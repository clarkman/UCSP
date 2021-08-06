function out = normAudio( in )

aud = in - mean(in);

maxAud = max(aud);
minAud = min(aud);

trim = 1.0/max(abs(minAud),abs(maxAud));

out = in .* trim;

plot(out)