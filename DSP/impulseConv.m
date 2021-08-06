function gammaSeries = impulseConv( dataObj, xferFunc )
%
% Slide samples, compute coherence. 

xferImpulse = impulseResponse( xferFunc );
%return
sizor = size( xferImpulse );


xferImpulse = xferImpulse(1:floor(sizor(1)/2),:);
%xferImpulse = xferImpulse(floor(sizor(1)/2)+1:end,:);
%figure; plot(xferImpulse) 

% Scale to volts
scale2Volts = 0.0;

staNumber = sscanf( dataObj.station, '%d' );

if( strcmp( dataObj.network, 'CMN' ) )
    if( staNumber >= 600 )
        switch( dataObj.channel )
            case {'CHANNEL1','CHANNEL2','CHANNEL3'}
                scale2Volts = 40.0/(2^24);
            case {'CHANNEL4','CHANNEL5'}
                scale2Volts = 20.0/(2^24);
            otherwise
                error( 'Channel scale not found' );
        end
    else
        if( staNumber >= 500 )
            scale2Volts = 10.0/(2^16);
        else
            scale2Volts = 10.0/(2^12);
        end
    end
elseif( strcmp( dataObj.network, 'BK' ) )
    scale2Volts = 40.0/(2^24);
else
    error('Only set up for CMN & BK so far!');
end


gammaSeries = removeDC(dataObj) .* scale2Volts;

samps = conv( gammaSeries.samples, xferImpulse );

%gammaSeries.samples = samps( sizor(1)+1 : end );
gammaSeries.samples = samps;

%gammaSeries.UTCref = gammaSeries.UTCref + ( sizor(1) / gammaSeries.sampleRate ) / 86400;
gammaSeries.valueUnit = 'Gammas';

