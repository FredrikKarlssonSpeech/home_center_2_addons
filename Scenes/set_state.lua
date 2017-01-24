--[[
%% properties
%% events
%% globals
lastMoveUp
lastMoveDown
--]]


--local movementUpstairs = fibaro:getGlobal("lastMoveUp") 
--fibaro:debug("Senast lagrade rörelsen uppe var ".. movementUpstairs .. " (" .. os.date("%Y-%m-%d %X",movementUpstairs) .. ")")
local movementUpstairs = 0; -- for debuging
local movementDownstairs = fibaro:getGlobal("lastMoveDown"))
fibaro:debug("Senast lagrade rörelsen uppe var ".. movementDownstairs .. " (" .. os.date("%Y-%m-%d %X",movementDownstairs) .. ")")

local lastMovement = math.max(movementUpstairs,movementDownstairs)
fibaro:debug("Senast lagrade rörelsen var ".. lastMovement .. " (" .. os.date("%Y-%m-%d %X",lastMovement) .. ")")

local currentTime = os.time()
local awayDelay = 2 * 60 * 60; -- Ingen rörelse på 2 timmar

-- Om tidsdifferensen mellan nuvarande tid och senaste rörensen är mindre än 2 timmar så är vi hemma.
if ((currentTime - lastMovement) < awayDelay ) then
    fibaro:setGlobal("PresentState","Home")
    fibaro:debug("Status satt till hemmma (Home)")
else
    fibaro:setGlobal("PresentState","Away")
    fibaro:debug("Status satt till borta (Away)")
end

