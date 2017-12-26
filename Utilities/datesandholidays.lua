

--- The function below are concerned with parsing and handling of dates, and with holidays.
-- @section holidayanddates


--- A holiday structure template that works for Sweden in 2018.
-- @table THIS_YEARS_HOLIDAYS
-- @field name The name of the holiday
-- @field start The date on which the holiday starts. It could be specified in a full specification "YYYY-MM-DD" or in a yearless format "DD/MM". 
-- @field end The date on which the holiday starts. It could be specified in a full specification "YYYY-MM-DD" or in a yearless format "DD/MM". The ending date is inclusive and will be interpreted correctly until "23:59:59" that day.
THIS_YEARS_HOLIDAYS = {
    {["name"]="Jul",["start"]="24/12",["end"]="26/12"},
    {["name"]="Nyår",["start"]="31/12",["end"]="1/1"},
    {["name"]="Trettondedag Jul",["start"]="6/1",["end"]="6/1"},
    {["name"]="Påsk",["start"]="2018-03-30",["end"]="2018-04-02"},
    {["name"]="Första Maj",["start"]="1/5",["end"]="1/5"},
    {["name"]="Kristi himmelfärdsdag",["start"]="2018-05-10",["end"]="2018-05-10"},
    {["name"]="Pingstdagen",["start"]="2018-05-20",["end"]="2018-05-20"},
    {["name"]="Sveriges Nationaldag",["start"]="6/6",["end"]="6/6"},
    {["name"]="Midsommar",["start"]="2018-06-23",["end"]="2018-06-23"},
    {["name"]="Alla helgons dag",["start"]="2018-11-03",["end"]="2018-11-03"},
}

--- The main function for setting Holiday mode for the house.
-- Input to the function is a structure containg the specifications of which days are holidays this year. 
-- An example structure is priovided in @{\\THIS_YEARS_HOLIDAYS}.
-- @tparam table holidayStructure An array of tables, where each subtable should have "name", "start" and "end" fields.

function setHolidayStates(holidayStructure)
    local setValue =tostring(fibaro:getGlobalValue("PartOfWeekToday"));
    if isHoliday(holidayStructure) and setValue ~= "Holiday" then
        fibaro:setGlobal("PartOfWeekToday","Holiday");
    end;
    setValue =tostring(fibaro:getGlobalValue("PartOfWeekTomorrow"))
    if isHolidayTomorrow(holidayStructure) and setValue ~= "Holiday" then
        fibaro:setGlobal("PartOfWeekTomorrow","Holiday");
    end;
end;

--- Gets the name of the Holiday that is currently celebrated according to the _holidayStructure_ structure.
-- @tparam table holidayStructure An array of tables, where each subtable should have "name", "start" and "end" fields.
-- @return The name of the currently celebrated holiday, or _nil_ if we are not having a special celebration.
function getHoliday(holidayStructure)
    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(today(),hstr["start"],hstr["end"]) then
            return(hstr["name"]);
        end;
    end;
    return(nil);
end;

--- Answers the question of whether today is a holiday.
-- @tparam table holidayStructure An array of tables, where each subtable should have "name", "start" and "end" fields.
-- @treturn boolean An answer to the question of whether today is a holiday.
function isHoliday(holidayStructure)

    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(today(),hstr["start"],hstr["end"]) then
            return(true);
        end;
    end;
    return(false);
end;

--- Answers the question of whether tomorrow is a holiday.
-- @tparam table holidayStructure An array of tables, where each subtable should have "name", "start" and "end" fields.
-- @treturn boolean An answer to the question of whether tomorrow is a holiday.
function isHolidayTomorrow(holidayStructure)  
    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(tomorrow(),hstr["start"],hstr["end"]) then
            return(true);
        end;
    end;
    return(false);
end;

--- A simple date parser.
-- @tparam string dateString The date to be parser. Could either be in the format "YYYY-MM-DD" for a specific date, or "DD/MM" for a date that is valid every year. The date formats are how you usually specify dates in Swedish.
-- @tparam boolean startOfDay The structure returned by this function will contain 'hour', 'min' and 'sec' in addition to 'year', 'day' and 'month'. This argument tells the function whether the _time_ speficication should be based on the _beginning_ ("00:00:00") of the day (true) or end of the day ("23:59:59") (false).
-- @treturn table A structure containging 'year', 'day', 'month', 'hour', 'min' and 'sec' fields  corresponding with the supplied arguments.
function parseDate (dateString,startOfDay)
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(dateString, "%d+");

    local first = g() ;
    local second = g();
    local third = g() or nil;
    local dateTable = {};
    if first == "" or second == "" then
        return(nil);
    end;
    if third ~= nil then
        -- we have a full date
        dateTable["year"] = first;
        dateTable["month"] = tostring(tonumber(second));
        dateTable["day"] = tostring(tonumber(third));
    else
        dateTable["year"] = os.date("%Y");
        dateTable["month"] = tostring(tonumber(second));
        dateTable["day"] = tostring(tonumber(first));
    end;
    if startOfDay == true then
        dateTable['hour'] = 0;
        dateTable['sec'] = 0;
        dateTable['min'] = 0;
    else
        dateTable['hour'] = 23;
        dateTable['sec'] = 59;
        dateTable['min'] = 59;
    end;

    return(dateTable);
end;

--- A function that answers the question of whether a date is inbetween two other dates.
-- @tparam string date A date specification, either as "YYYY-MM-DD" or "DD/MM". 
-- @tparam string startDateString The starting date of the interval, either as "YYYY-MM-DD" or "DD/MM".
-- @tparam string endDateString The ending date of the interval, either as "YYYY-MM-DD" or "DD/MM".
-- @see parseDate

function isBetweenDates (date,startDateString, endDateString)
    local startDateTable = parseDate(startDateString,true);
    local endDateTable = parseDate(endDateString,false);
    local startDateEpoch = tableToEpochtime (startDateTable);
    local endDateEpoch = tableToEpochtime (endDateTable);

    local now = tableToEpochtime(parseDate(date));
    return ( (startDateEpoch <= now ) and (endDateEpoch >= now));
end;

--- Correctly formated description of todays date.
-- @treturn string A date corrensponding to today in the "YYYY-MM-DD" format.
function today()
  return(os.date("%Y-%m-%d",tonumber(os.time())));
end;


--- Correctly formated description of tomorrows date.
-- @treturn string A date corrensponding to tomorrow in the "YYYY-MM-DD" format.
function tomorrow()
  return(os.date("%Y-%m-%d",tonumber(os.time()+24*3600)));
end;

--- Correctly formated description of todays date, but in a yearless format.
-- @treturn string A date corrensponding to today in the "DD/MM" format.
function todayMD()
  return(os.date("%d/%m",tonumber(os.time())));
end;

--- Correctly formated description of tomorrows date, but in a yearless format.
-- @treturn string A date corrensponding to tomorrow in the "DD/MM" format.
function tomorrowMD()
  return(os.date("%d/%m",tonumber(os.time()+24*3600)));
end;