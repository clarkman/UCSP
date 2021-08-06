function num = str2datenum(str)
% Converts a date-time string to a Matlab serial date number. 
% Handles input strings in the following formats:  
%         yyyy/mm/dd hh:mm:ss.fffff
%         mm/dd/yyyy hh:mm:ss.fffff
%         mm/dd/yy hh:mm:ss.fffff (NLDN, XXX Clark)
if( length(strfind( str, '/' )) == 0 )
    switch str(3:5)
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
    end
    str = [mm,'/',str(1:2),'/',str(6:7),' ',str(9:end)];
end


[str1, remstr] = strtok(str, ['/'; ' '; ':']);
[str2, remstr] = strtok(remstr, ['/'; ' '; ':']);
[str3, remstr] = strtok(remstr, ['/'; ' '; ':']);
[str4, remstr] = strtok(remstr, ['/'; ' '; ':']);
[str5, remstr] = strtok(remstr, ['/'; ' '; ':']);
[str6, remstr] = strtok(remstr, ['/'; ' '; ':']);

% Convert to numbers
num1 = str2num(str1);
num2 = str2num(str2);
num3 = str2num(str3);
num4 = str2num(str4);
num5 = str2num(str5);
num6 = str2num(str6);


if num1 > 999  &&  num2 < 13  &&  num3 < 32
    year = num1;
    month = num2;
    day = num3;
elseif num1 < 13  &&  num2 < 32  &&  num3 > 999
    year = num3;
    month = num1;
    day = num2;
elseif num1 < 13  &&  num2 < 32  &&  num3 < 99 %(NLDN, XXX Clark)
    year = num3 + 2000;
    month = num1;
    day = num2;
else
    error(' Unsupported date string format');
end

% Put it into Matlab date vector format
vec = [year month day num4 num5 num6];

num = datenum(vec);
    
