function mm = numMoDays( Mon, leap )

if nargin == 1
    leap = 0;
end

if leap
    febLength = 29;
else
    febLength = 28;
end

switch Mon
    case 'Jan', mm = 31;
    case 'Feb', mm = febLength;
    case 'Mar', mm = 31;
    case 'Apr', mm = 30;
    case 'May', mm = 31;
    case 'Jun', mm = 30;
    case 'Jul', mm = 31;
    case 'Aug', mm = 31;
    case 'Sep', mm = 30;
    case 'Oct', mm = 31;
    case 'Nov', mm = 30;
    case 'Dec', mm = 31;
    case 'JAN', mm = 31;
    case 'FEB', mm = febLength;
    case 'MAR', mm = 31;
    case 'APR', mm = 30;
    case 'MAY', mm = 31;
    case 'JUN', mm = 30;
    case 'JUL', mm = 31;
    case 'AUG', mm = 31;
    case 'SEP', mm = 30;
    case 'OCT', mm = 31;
    case 'NOV', mm = 30;
    case 'DEC', mm = 31;
    otherwise error( [ 'Bad Month !!! = ', Mon ] );
end


return    
