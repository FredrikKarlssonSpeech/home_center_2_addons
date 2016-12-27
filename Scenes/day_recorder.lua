--[[
%% properties
355 "value"
476 "value"
183 "value"
268 "value"
%% events
%% globals
--]]

function tableToEpochtime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end;

function timestringToTable (time)
    local dateTable = os.date("*t");
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(time, "%d+");

    local hour = g() ;
    local minute = g() or 0;
    local second = g() or 0;
    -- Insert sunset inforation istead
    dateTable["hour"] = hour;
    dateTable["min"] = minute;
    dateTable["sec"] = second;
    return(dateTable);
end;

function startedByDevice ()
    local startSource = fibaro:getSourceTrigger();
    -- startSource ={type="property",deviceID="11",propertyName="tet"}
    if startSource["type"] == "property" then
        return ({deviceID=startSource["deviceID"], propertyName=startSource["propertyName"]});
    else
        return false;
    end;
end;


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

dayrecorder("RECORDED_DAY");