function ap = play(td)

normer = max( abs(min(td)), abs(max(td)) );

apTmp = audioplayer(td.samples./normer,td.sampleRate);

display(sprintf('Playing %s for %s, chan %s',td.DataCommon.source,td.DataCommon.station,td.DataCommon.channel))

if nargout > 0
	ap = apTmp;
else
	apTmp.playblocking();
    display(sprintf('A total of %d at %d samples per second were played.',length(td),td.sampleRate))
end