--- This module collects functions that make it easier to reason about events.

function entryCounter(activatedID, moveInsideID,moveOutsideID, doorID,variableName)
    local function localSet(name,value) print("DEBUG: Variable ".. name .. " set to ".. tostring(value).. "." );end;
    local function localGet(name,value) print("DEBUG: Variable ".. name .. " was retrieved and is ".. tostring(value).. "." );end;
    local setVariable = (fibaro or {}).setGlobalValue or localSet;
    local getVariable = (fibaro or {}).getGlobalValue or localGet;
    local incrCounter = setVariable(variableName,getVariable(variableName) + 1 );
    local decrCounter = setVariable(variableName,math.max(getVariable(variableName) - 1 ,0);
    -- First, the case where the door is opened and someone enters
    
end;

--- A function that produces a sequence of activations of devices.
-- @tparam table ids An array of device IDs.
-- @tparam string property The property to check modication times of.
-- @treturn table A table of 
function activationSequence (ids,property)
    local prop = property or "state"
    local timeTable = {};
    -- Insert the modification times for each device into a table
    for i,id = pairs(ids) do
        time = fibaro:getModificationTime(id,prop);
        -- times are indices so that reverse sording by time is possible
        table.insert(timeTable,tonumber(time),tonumber(id));
    end;
    -- OBS! Fungerar inte!°!
    table.sort(timeTable);
    return timeTable;
end;

--- This function records events to a variable in a format that can be replayed at a later time
-- The function assumes that what should be recorded is what caused the scene to run, and its state. 
-- @param string storageVariable the name of the global variable into which the sequence of events should be recorded

function dayrecorder( storageVariable)
    local startOfDayEpoch = tableToEpochtime(timestringToTable("00:00:01"));
    local startSource = startedByDevice();
    local id = tonumber(startSource["deviceID"]);
    local property = tostring(startSource["propertyName"]);
    local value, modificationTime = fibaro:get(id, property);
    local adjModTime = modificationTime - startOfDayEpoch;
    local toStore = {id,property, value};
    -- Now insert the event into the global variable
    fibaro:debug("Storing value ".. value .. " of property ".. property .. " for device " .. id);
    local storageTable = json.decode(fibaro:getGlobal(tostring(storageVariable)));
    table.insert(storageTable,toStore);
    local out = json.encode(storageTable);
    fibaro:setGlobal(tostring(storageVariable),out);
    fibaro:debug("Stored value ".. value .. " of property ".. property .. " for device " .. id);
end;

--- A function that simply logs the time when ran last into a global variable
-- This simple function may be used in a simple "last movement seen" scene that keeps track of when
-- movement was last seen in the house. This information may then be used to check wheter movement has been observerved 
-- in X minutes or so by a different function "hasBeenActivity".
-- 
-- This function requires an "ACTIVITY_LAST_SEEN" global variable.
-- @tparam string variableName an optional name of a global variable to be used. Defailts to "ACTIVITY_LAST_SEEN"

function logLastActivity(variableName)
    local var = tostring(variableName) or "ACTIVITY_LAST_SEEN";
    local now = os.time();
    -- Store the time in variable
    fibaro:setGlobal(var,tostring(now));
end;

--- A simple function that fascilitates checking of when the activity was last observed. 
-- What the function will do is to 
-- This function requires an "ACTIVITY_LAST_SEEN" global variable.
-- @tparam number timeWindow the number of minutes to go back to check activity.
-- @tparam string variableName an optional name of a global variable to be used. Defailts to "ACTIVITY_LAST_SEEN"
-- @treturn boolean has there been activity in the last 'timeWindow' minutes?

function hasBeenActivity(timeWindow, variableName)
    local var = tostring(variableName) or "ACTIVITY_LAST_SEEN";
    local now = os.time();
    local lastActivity = tonumber(fibaro:setGlobal(var));
    local timeDiffMinutes = (now - lastActivity)/60;
    return (timeDiffMinutes < tonumber(timeWindow));
end;

--- A simple function that answers the question of whether a device property has been changed within a specified time window
-- @tparam number id the id of the device to be checked.
-- @tparam string property the property to be checked.
-- @tparam number seconds  the number of seconds to go back when checking for a change in the property value.
-- @tparam number minutes  an optional number of minutes to go back when checking for a change in the property value. Defaults to zero.
-- @tparam number hours  an optional number of hours to go back when checking for a change in the property value. Defaults to zero.
-- @tparam number debugChangeTimeEpoch a time point used when debugging the function. If this time point, specified as an Epoch time stamp, is given, the function will not check the device property modification time, but instead check whether the time point given here is within the time window counted from current time. 
-- @treturn boolean has a change occured in the property later than 'seconds', 'minutes' and 'hours' ago?
-- @usage print(hasChangedSince(1,"dded",3,0,0,tonumber(os.time())- 4));
-- @usage print(hasChangedSince(1,"dded",0,1,0,tonumber(os.time())- 4));
-- @usage print(hasChangedSince(1,"dded",4,0,0,tonumber(os.time())- 4));
-- @usage print(hasChangedSince(1,"dded",2,0,0,tonumber(os.time())- 4));

function hasChangedSince(id,property,seconds,minutes,hours,debugChangeTimeEpoch)
    local min = minutes or 0;
    local h = hours or 0;
    local lastchange = tonumber(debugChangeTimeEpoch) or tonumber(fibaro:getModificationTime(id,property));
    local now = os.time();
    return(lastchange >= (now - seconds - min * 60 - h * 60 * 60));
end;
