function outputSpectrum = segSpectrum( obj, centerTime, halffft )
%
% Computes the spectrum of a segment of the TimeData object
% supplied as "obj".  The segment is centered at "centerTime"
% and has half-width "halffft"


centerSample = fix( centerTime * obj.sampleRate );
urkl=obj;
orkl=urkl.samples;
arkl=orkl(centerSample-halffft:centerSample+halffft);
urkl.samples=arkl;
outputSpectrum=spectrum( urkl, fix(halffft*2) );
