function stripped = strip_underscores( instr )

stripped = instr;
for c = 1 : length( stripped )
  if( stripped(c) == '_' )
   stripped(c) = ' ';
  end
end