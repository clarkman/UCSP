function samplesPersecond = getSampleRate( sid )

[staNum, sid] = makeSid( sid );

if( sid < 400 ) % High School
    samplesPersecond = 20;
elseif( sid < 500 ) % UCB
    samplesPersecond = 40;
elseif( sid < 600 ) % NASA
    samplesPersecond = 20;
elseif( sid < 700 ) % DTEE/ QF1005
    samplesPersecond = 32.005325686194;
else % Modern
    samplesPersecond = 50;
end