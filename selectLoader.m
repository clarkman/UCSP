function [ loader, chan ] = selectLoader( ch )

switch chMoniker
  case 'mic' % All microphone signals
    chan = 0;
    loader = '[ peaks ] = getPeaks( arr, sensors )';
  case 'piezo'
    chan = 0;
    loader = '[ peaks ] = getPeaks( arr, sensors )';
