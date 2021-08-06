function serialNo = idNo2SerialNo( idNo )

hexNo = sprintf('%x', idNo );

serialNo = [ 'ISU-00-BEN-', hexNo(9:12) ];
