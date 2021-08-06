function [sqldate] = doy2sql(ydoy)
  % This function returns a human-readable date in the format yyyy-mmm-dd
  % (where mmm is the abbreviated name of a month) when given a
  % year-day-of-year date.
  %
  % ex: doy2sql('2012001') -> 2012-Jan-01

  if ~ischar(ydoy)
    ydoy = num2str(ydoy);
  end

  year = str2double(ydoy(1:4));
  days = str2double(ydoy(5:7));

  % Adding days to Jan 1st of the year in question in order to figure
  % out the date. Need to add the day-of-year minus one because there
  % is no day zero. 
  jan1 = datenum(year, 1, 1);
  the_date = jan1 + (days - 1);

  sqldate = datestr(the_date, 'yyyy-mmm-dd');
end

