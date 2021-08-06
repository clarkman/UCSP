function stripped = escape_underscores( instr )

stripped = instr;
b = 1;
for c = 1 : length( instr )
  if( instr(c) == '_' )
   stripped(b) = '\';
   b = b + 1;
  end
  stripped(b) = instr(c);
  b = b + 1;
end