function outdata = pscAddPulseTrain(indata, pulseInterval)
 
% Choose a random starting phase for the pulse train
rand('state',sum(100*clock));
phase = rand(1) * pulseInterval;

outdata = indata;
lastpt = length(outdata);
for i = phase: pulseInterval: lastpt,
    index = round(i);
    if (index > lastpt)
        index = lastpt;
    end
    outdata(index) = outdata(index) + 1;       % Add amplitude = 1 for each pulse
end

