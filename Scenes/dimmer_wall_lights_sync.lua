--[[
%% properties
268 value
476 value
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

function lightSelect(currentLuxLevel, conditionsTable)
    local currentLux = tonumber(luxLevel);
    out = {};
    for id, lux in pairs(conditionsTable) do
        if tonumber(currentLuxLevel) <= tonumber(lux) then
            table.insert(out,id);
        end;
    end;
    return(out);
end;


local HT = loadHomeTable("HomeTable");
local dimmer = HT.Vardagsrummetnere.Dimmerbrasan;

local left = HT.Vardagsrummetnere["Vänstervägglampa"]
local right = HT.Vardagsrummetnere["Högervägglampa"]
local lightSensor = HT.Vardagsrummetnere["Ljusvidsoffan"]
local movement = HT.Vardagsrummetnere.Sensorvidkaminen

fibaro:debug("Dimmerns ID= ".. dimmer);
fibaro:debug("ID vänster = ".. left);
fibaro:debug("ID höger = ".. right);

local luxtab = {}
luxtab[tostring(dimmer)] = 30
luxtab[tostring(left)] = 20
luxtab[tostring(right)] = 20

local currentLux = fibaro:getValue(lightSensor,"value");
local move = fibaro:getValue(movement,"value");

if tonumber(move) == 1 then
    local ids = lightSelect(currentLux, luxtab);
    for k, id in pairs(ids) do
        fibaro:debug("Turning on device ".. id)
        fibaro:call(id,"turnOn")
    end;
elseif tonumber(move) == 0 then
    for id,lux in pairs(luxtab) do
        fibaro:debug("Turning of device ".. id)
        fibaro:call(id,"turnOff")
    end
end;
