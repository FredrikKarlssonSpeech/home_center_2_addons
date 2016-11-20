-- A module for handling functions related to management of lighting.

--- A function that manages gradual dimming up of a device.
-- The function will see to it that  the device will gradually be dimmed up from a start level to an endpoint level within a 
-- specified time frame. 
-- @tparam number dimmerID The ID of the dimmer device.
-- @tparam number startLevel The dimmer level set at the onset of the sequence.
-- @tparam number stopLevel The dimmer level to reach.
-- @tparam number durationSeconds The time window for reaching the stopLevel.
-- @tparma number delayBetweenSteps Optional parameter inficating the time inbetwen steps. Defaults to 2. If you specify this, the time frame calculations will not be correct.

function startLevelChangeWithDur(dimmerID,startLevel,stopLevel,durationSeconds,delayBetweenSteps)
    local currentLevel = startLevel;
    local timeStepSeconds = delayBetweenSteps or 2;
    local deltaPerSecond = (stopLevel - startLevel) / durationSeconds *timeStepSeconds; 
    local newLevel = currentLevel + deltaPerSecond;
    local currentLevelFromDevice = 0;

    fibaro:debug("STARTING light increase");
    repeat
        fibaro:debug("Setting level value ".. newLevel);
        fibaro:call(dimmerID,"setValue",newLevel);
        currentLevel = newLevel;
        -- wait for timeStepSeconds seconds
        fibaro:sleep(timeStepSeconds* 1000);
        -- check actual setting of the device now
    --    currentLevelFromDevice = tonumber(fibaro:getValue(dimmerID, "value"));
        newLevel = currentLevel + deltaPerSecond;
        -- continue only if the level to be set is smaller or equal to the stop level
        -- AND the level has not been manually decreased in the waiting period
    until ( newLevel > stopLevel )
  -- or ( currentLevelFromDevice < currentLevel );

    fibaro:debug("DONE light increase");
end;