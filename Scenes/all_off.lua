--[[
%% autostart
%% properties
54 sceneActivation
%% globals
--]]


function myFunc ()
    fibaro:call(24, "setValue", "0");
    fibaro:call(21, "setValue", "0");
    fibaro:call(56, "turnOff");
    fibaro:call(58, "turnOff");
    fibaro:call(60, "setValue", "0");
    fibaro:call(43, "turnOff");
end;


if (startedManually() ) then
    myFunc();
    fibaro:debug(tostring(fibaro:getValue(1, "sunsetHour")));
elseif ( startedByDevice () ) then
    local info = startedByDevice();
    local scene = tonumber(fibaro:getValue(info["deviceID"], "sceneActivation"));
    if (scene == 43) then
        myFunc();
    end;
end;



