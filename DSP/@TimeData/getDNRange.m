function dnRange = getDNRange( pObj )

begDN = pObj.DataCommon.UTCref;
finDN = begDN + pObj.DataCommon.timeEnd/86400;

dnRange = [ begDN, finDN ];