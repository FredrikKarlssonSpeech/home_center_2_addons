--[[
%% properties
476 lastBreached
%% events
%% globals
--]]

-- SETUP

local autoOffTime = 20 * 60; -- 20 minutes  delay

-- Table of id, thershold pairs
local lTab = {}
lTab["268"] = 40
lTab["407"] = 30
lTab["408"] = 30

-- debuging information
fibaro:debug("Last breached at ".. tostring(fibaro:getValue(476,"lastBreached")) .. " (" .. os.date("%Y-%m-%d %X",tonumber(fibaro:getValue(476,"lastBreached"))) .. ")");
-- only one instance.
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end;

local currentLux = tonumber(fibaro:getValue(478, "value")); -- ljusnivå
-- get movement time
local lastBreach = tonumber(fibaro:getValue(476, "lastBreached"));

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

-- now handle auto OFF
fibaro:sleep(autoOffTime*1000);
local newLastBreach = 0
while (true) do
  newLastBreach = tonumber(fibaro:getValue(476,"lastBreached"))
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
