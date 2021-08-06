function [ fullExps, fullExpsLbls, sensors, fps, fpLbls ] = reload()

!cat Experiments2.csv | sed 's/,0:/,00:/' > ExperimentMatrix.csv

display( 'Raw Load')
[ exps, expLbls, sensors, fps, fpLbls ] = loadem();
display( 'Table Trim')
exps = exps(1:end-1,:);
display( 'Fillout')
[ fullExps, fullExpsLbls ] = fillExpArray( exps, expLbls, sensors, fps );