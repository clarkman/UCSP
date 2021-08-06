function [H, F] = makeXferFunc( sigObj, refObj, fftLength, ovrLapFactor )


numPts = length( refObj )

if( numPts ~= length( sigObj ) ), error( 'Object length mismatch' ), end;

if( mod( fftLength, ovrLapFactor ) ), error( 'Overlap factor not even into fft length!!!' ), end;

overLapStep = fftLength / ovrLapFactor;

numFFts = floor( numPts/ overLapStep ) - ovrLapFactor + 1  % Last are fractional

firstSamp = 1;

% Plus one for last scragglers
fftStartIndices = zeros( numFFts+1, 1 );

for slice = 0 : numFFts-1
    fftStartIndices(slice+1) = firstSamp + slice * overLapStep; 
end

numResidPts = numPts - overLapStep * numFFts;
fftStartIndices(end) = numPts - fftLength + 1;

sigObj = removeDC( flip( sigObj ) );
refObj = removeDC( flip( refObj ) );

sigSamps = sigObj.samples;
refSamps = refObj.samples;

%testObj = sigObj; %xxx

for slice = 1 : numFFts

    thisSig = sigSamps(fftStartIndices(slice):fftStartIndices(slice)+fftLength-1);
    thisRef = refSamps(fftStartIndices(slice):fftStartIndices(slice)+fftLength-1);
        
    if( slice == 800 )
    
        %testObj.samples = thisSig;
        %plot( spectrum( testObj, fftLength ) )
        
        thisSigFFT = fft( thisSig );
        thisRefFFT = fft( thisRef );
                
                
       [H,F] = tfestimate(thisRef,thisSig,blackman(fftLength),overLapStep,fftLength,20);
      %  H = abs(thisSigFFT ./ thisRefFFT);
       % H = thisRefFFT .* thisSigFFT / thisRefFFT.^2;

        break;
    end
end

