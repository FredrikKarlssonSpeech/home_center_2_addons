--[[
%% properties
529 lastBreached
%% events
%% globals
--]]

local toDebugBefore = fibaro:getGlobal("lastMoveUp")
fibaro:debug("Senast lagrade rörelsen uppe var ".. toDebugBefore .. " (" .. os.date("%Y-%m-%d %X",toDebugBefore) .. ")")

local trigger = fibaro:getSourceTrigger()
local triggeringID = tonumber(trigger['deviceID'])
local movement = tonumber(fibaro:getValue(triggeringID, "lastBreached"))

fibaro:setGlobal("lastMoveUp",movement);

local toDebugAfter = fibaro:getGlobal("lastMoveUp")
fibaro:debug("Senast lagrade rörelsen uppe är nu ".. toDebugAfter .. " (" .. os.date("%Y-%m-%d %X",toDebugAfter) .. ")")
