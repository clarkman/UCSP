function nextIdx = writeTascams( thisIdx );

aa=get(gca,'XLim');
l=floor(aa(1));

Fs=48000;
fName = ['28D20000270D0000-', sprintf('%d',thisIdx), '-audio.wav']
wav4sec=knowles1(l-Fs:l+Fs*3,1);
audiowrite(fName,wav4sec,Fs);

fName = ['28D20000270E0000-', sprintf('%d',thisIdx), '-audio.wav'];
wav4sec=knowles1(l-Fs:l+Fs*3,2);
audiowrite(fName,wav4sec,Fs);
