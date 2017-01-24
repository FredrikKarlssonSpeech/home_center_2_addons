--[[
%% properties
355 lastBreached
379 lastBreached
183 lastBreached
390 lastBreached
476 lastBreached
%% events
%% globals
--]]

local toDebugBefore = fibaro:getGlobal("lastMoveDown")
fibaro:debug("Senast lagrade rörelsen nere var ".. toDebugBefore .. " (" .. os.date("%Y-%m-%d %X",toDebugBefore) .. ")")

local trigger = fibaro:getSourceTrigger()
local triggeringID = tonumber(trigger['deviceID'])
local movement = tonumber(fibaro:getValue(triggeringID, "lastBreached"))

fibaro:setGlobal("lastMoveDown",movement);

local toDebugAfter = fibaro:getGlobal("lastMoveDown")
fibaro:debug("Senast lagrade rörelsen nere är nu ".. toDebugAfter .. " (" .. os.date("%Y-%m-%d %X",toDebugAfter) .. ")")