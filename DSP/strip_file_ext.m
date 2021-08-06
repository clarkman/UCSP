function stripped = strip_file_ext( instr )

stripped = instr;
dots = strfind( stripped, '.' );
if( length( dots ) == 0 )
  return;
end

stripped = stripped(1:dots(end)-1);
