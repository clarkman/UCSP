function [ audio, offSec ] = slideAudio( audio, mult, Fs )

incr = Fs/10;
lo = Fs/2-incr;
hi = Fs/2+incr;
noiseRMS = std(audio(lo:hi));
threshold = noiseRMS*mult;
lo = Fs-incr;
hi = Fs+incr;
for s = lo : hi
if( audio(s) > threshold )
  break;
end
end
if s == hi
  warning('Knowles shift did not work!')
end
 tOffset = s - 24000;
if tOffset > 0 % Shift left
  audio = audio(tOffset:end);
elseif tOffset < 0 % Shift right
  audioLen = numel(audio);
  newAudio = zeros(audioLen-tOffset,1); % Minus a minus
  newAudio(-(tOffset-1):end) = audio; % Leave beginnings as zeros
  audio = newAudio(1:audioLen);
  %else % == 0, do nothing
end

offSec = s/Fs;
