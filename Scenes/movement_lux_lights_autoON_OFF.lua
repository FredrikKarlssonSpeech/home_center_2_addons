--[[
%% properties
476 lastBreached
%% events
%% globals
--]]

function loadHomeTable (variableName)
    local var = tostring(variableName) or "HomeTable";
    local jT = json.decode(fibaro:getGlobalValue(var));
    -- Check what we got
    if jT == {} then
        fibaro:debug("Could not load content from the HomeTable variable \'".. var .. "\'. Please make sure the variable exists.");
        return(false);
    else
        fibaro:debug("Got HomeTable");
        return(jT);
    end;
end;

-- SETUP
local HT = loadHomeTable ();
local autoOffTime = 1 * 60; -- 20 minutes  delay

-- Table of id, thershold pairs
local lTab = {}
lTab[HT.Vardagsrummetnere.Dimmerbrasan] = 40
lTab[HT.Vardagsrummetnere.Hogervagglampa] = 30
lTab[HT.Vardagsrummetnere.Vanstervagglampa] = 30

-- debuging information
fibaro:debug("Last breached at ".. tostring(fibaro:getValue(HT.Vardagsrummetnere.Sensorvidkaminen,"lastBreached")) .. " (" .. os.date("%Y-%m-%d %X",tonumber(fibaro:getValue(HT.Vardagsrummetnere.Sensorvidkaminen,"lastBreached"))) .. ")");
-- only one instance.
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end;

local currentLux = tonumber(fibaro:getValue(HT.Vardagsrummetnere.Ljusvidsoffan, "value")); -- ljusnivå
-- get movement time
local lastBreach = tonumber(fibaro:getValue(HT.Vardagsrummetnere.Sensorvidkaminen, "lastBreached"));

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
  newLastBreach = tonumber(fibaro:getValue(HT.Vardagsrummetnere.Sensorvidkaminen,"lastBreached"))
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
