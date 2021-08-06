function newObj = upOldTDs( oldObj )

newObj = TimeData;
newObj

newObj.source     = oldObj.source; 
newObj.title      = oldObj.title;       
newObj.network    = 'BK';
newObj.station    = 'PKD'
newObj.channel    = 'BQ'
newObj.UTCref     = oldObj.UTCref;
newObj.timeOffset = oldObj.timeOffset; 
newObj.history    = oldObj.history;
newObj.sampleRate = oldObj.sampleRate;
newObj.axisLabel  = oldObj.axisLabel;
newObj.valueType  = oldObj.valueType;
newObj.valueUnit  = oldObj.valueUnit
newObj.samples    = oldObj.samples

return
  
BK_PKD_BQ2_2004_09_28_1 = upOldTDs( BK_PKD_BQ2_2004_09_28 )
BK_PKD_BQ3_2004_09_28_1 = upOldTDs( BK_PKD_BQ3_2004_09_28 )
BK_PKD_BQ4_2004_09_28_1 = upOldTDs( BK_PKD_BQ4_2004_09_28 )
BK_PKD_BQ5_2004_09_28_1 = upOldTDs( BK_PKD_BQ5_2004_09_28 )
