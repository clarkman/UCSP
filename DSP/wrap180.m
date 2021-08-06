function wrapped = wrap180( deg )

numDeg = length(deg);
if( numDeg == 1 )
  if( deg <= 180 )
    wrapped = deg + 180;
  else
    wrapped = deg - 180;
  end
else
  wr = zeros( numDeg, 1 );
  for d = 1 : numDeg
    if( deg(d) <= 180 )
      wr(d) = deg(d) + 180;
    else
      wr(d) = deg(d) - 180;
    end
  end
  wrapped = wr;
end
