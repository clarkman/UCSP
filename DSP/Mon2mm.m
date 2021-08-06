function mm = Mon2mm( Mon )
%
switch Mon
    case 'Jan', mm = '01';
    case 'Feb', mm = '02';
    case 'Mar', mm = '03';
    case 'Apr', mm = '04';
    case 'May', mm = '05';
    case 'Jun', mm = '06';
    case 'Jul', mm = '07';
    case 'Aug', mm = '08';
    case 'Sep', mm = '09';
    case 'Oct', mm = '10';
    case 'Nov', mm = '11';
    case 'Dec', mm = '12';
    case 'JAN', mm = '01';
    case 'FEB', mm = '02';
    case 'MAR', mm = '03';
    case 'APR', mm = '04';
    case 'MAY', mm = '05';
    case 'JUN', mm = '06';
    case 'JUL', mm = '07';
    case 'AUG', mm = '08';
    case 'SEP', mm = '09';
    case 'OCT', mm = '10';
    case 'NOV', mm = '11';
    case 'DEC', mm = '12';
    otherwise error( [ 'Bad Month !!! = ', Mon ] );
end
