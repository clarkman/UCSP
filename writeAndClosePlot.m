function writeAndClosePlot( hndl, typer, fName, tag, ext )

saveDir = [ 'results/', typer ];
if system( [ 'mkdir -p ', saveDir ] )
  error([ 'Problem making dir', saveDir ])
end
savePath = [ saveDir, '/', fName, '.', tag, '.' ext ];
saveas( hndl, savePath, 'jpeg' );
close( hndl );
