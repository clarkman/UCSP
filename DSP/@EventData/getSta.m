function [staNum, sid] = getSta( pObj )

staNum = pObj.DataCommon.station;
sid = sscanf( staNum, '%d');