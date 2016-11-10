--[[
%% autostart
%% properties
412 sceneActivation
%% events
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


function leftON ()
    fibaro:call(408, "turnOn");
end;


function leftOFF ()
    fibaro:call(408, "turnOff");
end;

function bothON ()
    fibaro:call(407, "turnOn");
    fibaro:call(408, "turnOn");
end;


function bothOFF ()
    fibaro:call(407, "turnOff");
    fibaro:call(408, "turnOff");
end;



if ( startedByDevice () ) then
    local info = startedByDevice();
    local scene = tonumber(fibaro:getValue(info["deviceID"], "sceneActivation"));
    if (scene == 10 or scene == 11 or scene == 12) then
        leftON();
    elseif (scene == 30 or scene == 31 or scene == 32) then
        leftOFF();
    elseif (scene == 13 ) then
        bothON();
    elseif (scene == 33) then
        bothOFF();
    end;
elseif (fibaro:countScenes() < 2) then
    local sunsetHour = "19:00";
    while (true) do

        sunriseHour = tostring(fibaro:getValue(1, "sunriseHour"));
        --fibaro:debug("Sunset hour = ".. sunsetHour);
        fibaro:sleep(60*1000);
    end;
end;