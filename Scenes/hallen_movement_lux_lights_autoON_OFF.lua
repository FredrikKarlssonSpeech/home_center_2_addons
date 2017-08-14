--[[
%% properties
355 lastBreached
%% events
%% globals
--]]


-- Table of id, thershold pairs
local lTab = {}
lTab["500"] = 40 -- taklampan

-- debuging information
fibaro:debug("Last breached at ".. tostring(fibaro:getValue(355,"lastBreached")) .. " (" .. os.date("%Y-%m-%d %X",tonumber(fibaro:getValue(355,"lastBreached"))) .. ")");
-- only one instance.
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end;

local currentLux = tonumber(fibaro:getValue(357, "value")); -- ljusnivå
-- get movement time
local lastBreach = tonumber(fibaro:getValue(355, "lastBreached"));

function timeIsInRange (startTimeString, endTimeString)
    local startTimeTable = timestringToTable(startTimeString);
    local endTimeTable = timestringToTable(endTimeString);
    local startTimeEpoch = tableToEpochtime (startTimeTable);
    local endTimeEpoch = tableToEpochtime (endTimeTable);
    local newEndTimeTable = endTimeTable;
    -- allow for end time being in the upcoming day, but before startTime then
    if (endTimeEpoch < startTimeEpoch) then
        endTimeEpoch = endTimeEpoch + 24*3600;  -- add 24 hours
        -- Now, we make a new table object, to find out whether the DST status of the new end time is
        newEndTimeTable = os.date("*t",endTimeEpoch);
    end;
        -- Now, we adjust for Daylight saving time effects
    if (startTimeTable.isdst == false and newEndTimeTable.isdst == true) then
        -- In this case, start time is Not summer, and end time is in summer time
        -- which means that we are going from spring into summer
        -- then advance the clock one more hour from the end time
        endTimeEpoch = endTimeEpoch + 3600;
    elseif (startTimeTable.isdst == true and newEndTimeTable.isdst == false) then
        -- Here, we are coming into fall (from summer)
        -- then remove one hour from the time end time
         endTimeEpoch = endTimeEpoch - 3600;
    end;
    local now = os.time();
    return ( (startTimeEpoch <= now ) and (endTimeEpoch >= now));
end;

function timestringToTable (time)
    local dateTable = os.date("*t");
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(time, "%d+");

    local hour = g() ;
    local minute = g() or 0;
    local second = g() or 0;
    -- Insert sunset inforation istead
    dateTable["hour"] = hour;
    dateTable["min"] = minute;
    dateTable["sec"] = second;
    return(dateTable);
end;

function tableToEpochtime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end;

function lightSelect(currentLuxLevel, conditionsTable)
    local currentLux = tonumber(currentLuxLevel);
    out = {};
   if (not type(conditionsTable) == "table")  then
       error("Array of arrays expected as 'conditionsTable' argument.")
   end;
    for id, lux in pairs(conditionsTable) do
        if type(lux) == "table" then
          for nlux,level in pairs(lux) do
            nout = {};
            nout[nlux] = level;
            table.insert(out,nout);
          end;
        elseif type(lux) == "number" then
          if tonumber(currentLuxLevel) <= tonumber(lux) then
              table.insert(out,id);
          end;
        else
          error("The value stored in the table should be either a numeric value or a {lux,level} table ")
        end;

    end;
    return(out);
end;
-- select the lights to turn on
local selectedLights = lightSelect(currentLux, lTab);

-- now run the loop

for i, id in pairs(selectedLights) do
  fibaro:call(tonumber(id),"turnOn")
  fibaro:debug("Turned on lamp with ID ".. id);
end;

-- SETUP

local autoOffTime = 1 * 60; -- 20 minutes  delay
if (timeIsInRange ("06:30", "23:00")) then
  autoOffTime = 20 * 60;
end

-- now handle auto OFF
fibaro:sleep(autoOffTime*1000);
local newLastBreach = 0
while (true) do
  newLastBreach = tonumber(fibaro:getValue(355,"lastBreached"))
  if( tonumber(newLastBreach) == tonumber(lastBreach) ) then
    for i, id in pairs(selectedLights) do
      fibaro:call(tonumber(id),"turnOff")
      fibaro:debug("Turned off lamp with ID ".. id );
    end;
    fibaro:abort()
  end;
  lastBreach = newLastBreach;
  fibaro:sleep(autoOffTime*1000);
end;
