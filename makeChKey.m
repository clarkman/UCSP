function chKey = makeChKey()
%MAKEDIRKEY Returns a consistent order of channels across Aretmis analyses.
% 
% Add new channels to end.

chKey(1).moniker = 'mic';
chKey(1).fullname = 'Microphone';
chKey(2).moniker = 'piezo';
chKey(2).fullname = 'Piezo';
chKey(3).moniker = 'accelX';
chKey(3).fullname = 'Accelerometer - X axis';
chKey(4).moniker = 'accelY';
chKey(4).fullname = 'Accelerometer - Y axis';
chKey(5).moniker = 'accelZ';
chKey(5).fullname = 'Accelerometer - Z axis';
chKey(6).moniker = 'rev4IR';
chKey(6).fullname = 'Old Rev4 IR';
chKey(7).moniker = 'swIR';
chKey(7).fullname = 'Thorlabs SW IR';
chKey(8).moniker = 'mwIR';
chKey(8).fullname = 'Thorlabs MW IR';
chKey(9).moniker = 'Casella';
chKey(9).fullname = 'Casella Impulse Meter';
chKey(10).moniker = 'rev4Mic';
chKey(10).fullname = 'Rev4 Microphone';
chKey(11).moniker = 'revAMic';
chKey(11).fullname = 'RevA Microphone';
chKey(12).moniker = 'knowles';
chKey(12).fullname = 'Knowles Hi-Headroom Microphone';
chKey(13).moniker = 'accelXNoFloat';
chKey(13).fullname = 'Accelerometer - X axis mounted';
chKey(14).moniker = 'accelYNoFloat';
chKey(14).fullname = 'Accelerometer - Y axis mounted';
chKey(15).moniker = 'accelZNoFloat';
chKey(15).fullname = 'Accelerometer - Z axis mounted';
