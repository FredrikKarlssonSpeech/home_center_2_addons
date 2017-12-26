-- TODO: do documentation for this file
-- TODO: check these functions in HC2
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

function setHolidayStates(holidayStructure)
    local setValue =tostring(fibaro:getGlobalValue("PartOfWeekToday"))
    if isHoliday(holidayStructure) and setValue ~= "Holiday" then
        fibaro:setGlobalValue("PartOfWeekToday","Holiday")
    end;
    setValue =tostring(fibaro:getGlobalValue("PartOfWeekTomorrow"))
    if isHolidayTomorrow(holidayStructure) and setValue ~= "Holiday" then
        fibaro:setGlobalValue("PartOfWeekTomorrow","Holiday")
    end;
end;


function getHoliday(holidayStructure)
    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(today(),hstr["start"],hstr["end"]) then
            return(hstr["name"]);
        end;
    end;
    return(nil);
end;

function isHoliday(holidayStructure)

    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(today(),hstr["start"],hstr["end"]) then
            return(true);
        end;
    end;
    return(false);
end;

function isHolidayTomorrow(holidayStructure)  
    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(tomorrow(),hstr["start"],hstr["end"]) then
            return(true);
        end;
    end;
    return(false);
end;


function parseDate (datestring,startOfDay)
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(datestring, "%d+");

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

function isBetweenDates (date,startDateString, endDateString)
    local startDateTable = parseDate(startDateString,true);
    local endDateTable = parseDate(endDateString,false);
    local startDateEpoch = tableToEpochtime (startDateTable);
    local endDateEpoch = tableToEpochtime (endDateTable);

    local now = tableToEpochtime(parseDate(date));
    return ( (startDateEpoch <= now ) and (endDateEpoch >= now));
end;

function today()
  return(os.date("%Y-%m-%d",tonumber(os.time())));
end;

function tomorrow()
  return(os.date("%Y-%m-%d",tonumber(os.time()+24*3600)));
end;

function todayMD()
  return(os.date("%d/%m",tonumber(os.time())));
end;