


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