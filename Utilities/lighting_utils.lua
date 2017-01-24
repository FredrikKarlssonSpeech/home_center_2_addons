-- A module for handling functions related to management of lighting.
-- @module lighting

--- A function that manages gradual dimming up of a device.
-- The function will see to it that  the device will gradually be dimmed up from a start level to an endpoint level within a
-- specified time frame.
-- @tparam number dimmerID The ID of the dimmer device.
-- @tparam number startLevel The dimmer level set at the onset of the sequence.
-- @tparam number stopLevel The dimmer level to reach.
-- @tparam number durationSeconds The time window for reaching the stopLevel.
-- @tparam number delayBetweenSteps Optional parameter inficating the time inbetwen steps. Defaults to 2. If you specify this, the time frame calculations will not be correct.

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


--- This function takes a lox level reading and a set of conditions, and selects which lights to turn on
-- If the 'luxLevel' is less or equal to the *lux* in on of the subtables of this parameter, the coresponding id will be returned.
-- @tparam number currentLuxLevel a LUX reading that should determine which lights should be turned on
-- @tparam {number,number} conditionsTable This selects ON/OFF devices based on the current lux level and a threshold for each device. The argument should be a table of {id,lux} tuples that performs the selection of devices to turn on.
-- @tparam {number,{number,number}} conditionsTable a table of {id,{lux,level}} nested tuples. If 'currentLuxLevel' is smaller than the 'lux' value in the table, the device is set to 'level'.
-- @treturn table an array of device IDs that should be activated.
-- @usage a = {}; a[10] = 90; a[30] = 80;
-- @usage debugTable(lightSelect(80,a));
-- @usage debugTable(lightSelect(85,a));
-- @usage debugTable(lightSelect(100,a));
-- @usage b = {}; b[10] = {90,40}; b[30] = 80;
-- @usage debugTable(lightSelect(20,b));

function lightSelect(currentLuxLevel, conditionsTable)
    local currentLux = tonumber(currentLuxLevel);
    out = {};
   if (not type(conditionsTable) == "table")  then
       error("Array of arrays expected as 'conditionsTable' argument.")
   end;
    for id, lux in pairs(conditionsTable) do
        if type(lux) == "table" then
          for nlux,level in pairs(lux) do
            nout = {};
            nout[nlux] = level;
            table.insert(out,nout);
          end;
        elseif type(lux) == "number" then
          if tonumber(currentLuxLevel) <= tonumber(lux) then
              table.insert(out,id);
          end;
        else
          error("The value stored in the table should be either a numeric value or a {lux,level} table ")
        end;

    end;
    return(out);
end;
