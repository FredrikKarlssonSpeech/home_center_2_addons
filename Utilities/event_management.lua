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

