--[[
%% autostart
%% properties
396 sceneActivation
%% globals
--]]

function startedByDevice ()
    local startSource = fibaro:getSourceTrigger();
    -- startSource ={type="property",deviceID="11",propertyName="tet"}
    if startSource["type"] == "property" then
        return ({deviceID=startSource["deviceID"], propertyName=startSource["propertyName"]})
    else
        return false
    end
end

function onLamps()
    fibaro:call(375, "turnOn")
    fibaro:call(375, "setValue", "20") -- Dimmer vårt rum
    fibaro:call(268, "turnOn") -- Dimmer utanför vårt rum
    fibaro:call(268, "setValue", "30")
end;

function offLamps()

    fibaro:call(375, "turnOff")-- Dimmer vårt rum
    fibaro:call(268, "turnOff")
end;

if (startedManually() ) then
    onLamps();

elseif ( startedByDevice () ) then
    local info = startedByDevice();
    local scene = tonumber(fibaro:getValue(info["deviceID"], "sceneActivation"));
    if (scene == 10) then
        onLamps();
    elseif (scene == 30) then
        offLamps();
    end;
end;