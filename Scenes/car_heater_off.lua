--[[
%% properties
193 value
%% events
%% globals
--]]

if (fibaro:countScenes() <= 4) then
    local tempDeviceState0, deviceLastModification0 = fibaro:get(193, "value");
    fibaro:sleep(10800*1000)
    local temperature = tonumber(fibaro:getValue(3, "Temperature"));
    local tempDeviceState1, deviceLastModification1 = fibaro:get(193, "value");
    if( (deviceLastModification1 == deviceLastModification0) and (temperature > tonumber(-20) ) )  then

        fibaro:call(193, "turnOff");

    end;
end;
