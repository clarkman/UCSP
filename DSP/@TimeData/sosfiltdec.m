function outObj = sosfiltdec( obj, sos, dec )

outObj = obj;

samps =  sosfilt( sos, obj.samples );

outObj.samples =  samps(1:dec:end);

outObj.sampleRate = outObj.sampleRate / dec;

