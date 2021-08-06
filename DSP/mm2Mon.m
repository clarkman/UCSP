function Mon = mm2Mon( mm )
%
switch mm
    case '01', Mon = 'JAN';
    case '02', Mon = 'FEB';
    case '03', Mon = 'MAR';
    case '04', Mon = 'APR';
    case '05', Mon = 'MAY';
    case '06', Mon = 'JUN';
    case '07', Mon = 'JUL';
    case '08', Mon = 'AUG';
    case '09', Mon = 'SEP';
    case '10', Mon = 'OCT';
    case '11', Mon = 'NOV';
    case '12', Mon = 'DEC';
    otherwise error( [ 'Bad Month !!! = ', mm ] );
end
