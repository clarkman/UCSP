function [out1, out2] = matchTrim( obj1, obj2 )

in1 = obj1;
in2 = obj2;
% Sanity Checking
if( in1.sampleRate ~= in2.sampleRate )
    error('mscoheregram: sample rates must match');
end
fs = in1.sampleRate;

lengthIn1=length(in1);
lengthIn2=length(in2);
if 1
    % Trim to 'identical'.
    if( in1.DataCommon.UTCref ~= in2.DataCommon.UTCref )
        display( 'correcting starttime mismatch' );
        tDiff = (in2.DataCommon.UTCref - in1.DataCommon.UTCref) * 86400
        if( tDiff > 10000 || tDiff < -10000 )
            error( [ 'mscoheregram: whacky timing diff = ', sprintf( '%d',tDiff ), ' seconds.' ]);
        end
        sampsDiff = round(tDiff * in1.sampleRate);
        if( sampsDiff > 0 )
           display( 'in2 starts later than in1' );
           in1 = slice(in1, sampsDiff, lengthIn1);
        else
           display( 'in1 starts later than in2' );
           in2 = slice(in2, sampsDiff*-1, lengthIn2);
        end
    end
    lengthIn1=length(in1);
    lengthIn2=length(in2);
    if( lengthIn1 > lengthIn2 )
        % in1 longer than in2
        in1 = slice( in1, 1, lengthIn2 );
    else
        % in2 longer than in1
        in2 = slice( in2, 1, lengthIn1 );
    end
    lengthIn1=length(in1);
    lengthIn2=length(in2);
    if( lengthIn1 ~= lengthIn2 )
        error('mscoheregram: signal lengths mismatched');
    end
else
    if( lengthIn1 > lengthIn2 )
        in1 = slice(in1,1, lengthIn2);
    else
        in2 = slice(in2,1, lengthIn1);
    end
end

in1 = offset( in1 );
in2 = offset( in2 );

out1 = in1;
out2 = in2;
