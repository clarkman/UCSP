function code = Zoom_Types( typer )

code = -1;

switch typer
    case 'SecsData'
        code = 9;
    case 'TimeData'
        code = 10;
    case 'FrequencyData'
        code = 11;
    case 'FrequencyTimeData'
        code = 12;
    case 'TimeDataAbsolute'
        code = 14;
end

