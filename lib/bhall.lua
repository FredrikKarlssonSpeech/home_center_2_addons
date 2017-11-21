--- The Boolean Home Automation Lua Library 
-- @author Fredrik Karlsson https://github.com/dargosch


local BHALL_LIB_VERSION=0.1;



--- Functions that deal with sequences of events
-- @section eventsequences

--- A function that produces a sequence of activations of devices.
-- @tparam table ids An array of device IDs.
-- @tparam string property The property to check modication times of.
-- @treturn table A table of

function activationSequence (ids,property)
    local prop = property or "state"
    local timeTable = {};
    -- Insert the modification times for each device into a table
    for i,id in pairs(ids) do
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
-- @tparam string storageVariable the name of the global variable into which the sequence of events should be recorded

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
    local printFunc = print;
    if (fibaro or {}).debug then
       function printFunc(...) ;
          return fibaro:debug(...);
       end;
    end;
    printFunc("Testing device time " .. lastchange.. " Epoch time, which is ".. os.date("%Y-%m-%d %X",lastchange));
    printFunc("against current time ".. now .. " Epoch time, which is ".. os.date("%Y-%m-%d %X",now));
    return(lastchange >= (now - seconds - min * 60 - h * 60 * 60));
end;


-- --- This function is designed do handle turning spcific lights on or off depending on movement
--
-- -- TODO: Fortsätt på denna funktion.
-- function movementHandler(movementSendorId,onTable, offTable)
--     local offTable = offTable or {};
--     local onTable = onTable or {};
--     if (fibaro or {}).call then
--        function callFunc(...) ;
--           return fibaro:call(...);
--        end;
--     else
--         function callFunc(...)
--             print(...);
--        end;
--     end;
--     if (fibaro or {}).getValue then
--        function movementDetected(id)
--           return (tonumber(fibaro:getValue(id,"value")) == 1);
--        end;
--     else
--         function movementDetected(id)
--             print("Cheking movement status of ID ".. id);
--             -- If in development environment, movement is ALVWAYS detercted
--             return(true);
--        end;
--     end;
--
--     if movementDetected(movementSendorId) and onTable ~= {} then
--         for i,command in pairs(onTable) do
--             callFunc(unpack(command));
--         end;
--     elseif not movementDetected(movementSendorId) and offTable ~= {} then
--         for i,command in pairs(offTable) do
--             callFunc(unpack(command));
--         end;
--     end;
-- end;
--- Functions that deal with valus from temperature and humidity sensors.
-- @section temphum


-- function D_Phi(humidity)

--     local hum = tonumber(humidity);

--     if (hum >= 75 ) then
--         -- highest risk level
--         D= math.exp(15.53*(math.log(hum/90)));

--     elseif (hum > 60 and hum < 75 ) then
--         D = (-2.7 + 1.1*(hum / 30));
--     else
--         D= -0.5;
--     end;
--     return D;
-- end;

-- function D_T(temperature)
--     local temp = tonumber(temperature)
--     -- here we expand the truth a little bit. In the original report, the definition is given up to 30 degrees C (not 50)
--     if (temp >= 0.1 and temp < 50) then
--         DT = math.exp(0.74*(math.log(temp/20)));
--     elseif temp < 0.1 then
--         DT = -0.5;
--     end;
--     return DT
-- end;

-- function D(temperature, humidity)
--     local hum = tonumber(humidity);
--     local temp = tonumber(temperature);

--     if temp > 0.1 then
--         D = D_Phi(hum) * D_T(temp);
--     else
--         D= -0.5;

--     end;

--     return D;
-- end;


--- Function that checks whether there is a risk of mold growth, and assessess the level of threat.
-- The calculations are based on temperature and humidity estimates, as well as a rough mathmatical approximation of risk regions.
-- developed from this http://www.penthon.com/wp-content/uploads/2014/08/Mogelriskdiagram.png image.
-- @tparam number hum the humidity percentage, measured at the site where a mold growth risk estimate should be computed.
-- @tparam number temp the temperature at the location where the humidity measure was made.
-- @tparam table levelDescriptions A table of risk names. Defaults to {"Risk of mold growth","Mold growth happening (8v)","Mold growth happening (4v)"}.
-- @return 'false' if there is no risk of mould, and a string value describing the level of risk if there is one.
-- @usage
-- > print(riskOfMold(77,10)) -- results in a "false" printout.
-- > print(riskOfMold(82,10)) -- results in a ""Risk of mold growth" printout.

function riskOfMold(hum, temp, levelDescriptions)
    local ld = levelDescriptions or {"Risk of mold growth","Mold growth happening (8v)","Mold growth happening (4v)"};
    -- high risk
    function high15Plus (temp) lhum= (89-91)/10*temp + 95;return(lhum);end;
    function high15Minus (temp) lhum= (91.5-100)/15*temp + 104;return(lhum);end;
    -- medium risk
    function med10Plus (temp) lhum= (81-87)/(50-15)*temp + 93;return(lhum);end;
    function med10Minus (temp) lhum= (87.5-100)/(15-0)*temp + 100;return(lhum);end;
        -- lowest risk
    function low15Plus (temp) lhum= 80;return(lhum);end;
    function low15Minus (temp) lhum= (80-100)/(15-0)*temp + 98;return(lhum);end;     
    -- First make sure that it is warm enough
    if(temp <= 0) then
        return(false);
    end;
    -- Check highest risk level
    if ( ( temp > 15 and hum >= high15Plus(temp) ) or ( temp <= 15 and hum >= high15Minus(temp) )  )  then
        return(ld[3]);
    elseif ( ( temp > 10 and hum >= med10Plus(temp) ) or ( temp <= 10 and hum >= med10Minus(temp) )  )  then
        return(ld[2]);
    elseif ( ( temp > 15 and hum >= low15Plus(temp) ) or ( temp <= 15 and hum >= low15Minus(temp) )  )  then
        return(ld[1]);
    else
        return(false);
    end;

end;



--- Functions that maupulates lighting.
-- @section lighting


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


--- This function takes a lux level reading and a set of conditions, and selects which lights to turn on
-- If the 'luxLevel' is less or equal to the *lux* in on of the subtables of this parameter, the coresponding id will be returned.
-- @tparam number currentLuxLevel a LUX reading that should determine which lights should be turned on
-- @tparam tab conditionsTable This selects ON/OFF devices based on the current lux level and a threshold for each device. The argument should be a table of {id,lux} tuples that performs the selection of devices to turn on. Alternativelly, 'conditionsTable' can be a table of {id,{lux,level}} nested tuples. If 'currentLuxLevel' is smaller than the 'lux' value in the table, the device is set to 'level'.
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

--- This function executes lighting commands from a table.
-- This function will take a set of numeric IDs or a {id, level} tuple, or a mix of numerics and tuples, and execute the lighting commands. If the table entry is a numeric ID, then the corrensponding device will be turned ON. If the table entry is a tuple, then the device will be dimmed to the corresponding level.
-- This function is designed to work from the output of the @lightSelect function.
-- @tparam table onTable a table containing either IDs numeric values or or {id,level} tuples (tables).
function runLigthingSetup(onTable)
  -- first some functions that fascilitates debugging outside of HC2.
  if (fibaro or {}).call then
    function callFunc(...) ;
      return fibaro:call(...);
    end;
  else
    function callFunc(...)
      print(...);
    end;
  end;
  -- now, run the ON commands in the onTable
  local IDOrONCommand = nil;
  for _,IDOrONCommand in pairs(onTable) do
    -- check for dimmer
    if type(IDOrONCommand) == "table" then
      IDOrONCommand = {IDOrONCommand[1],"setLevel",IDOrONCommand[2]};
    else
      IDOrONCommand = {IDOrONCommand,"turnOn"};
    end;
    callFunc(unpack(IDOrONCommand));
  end;
end;
--- Functions that deal with triggered events.
-- The idea of these functions is that they encapsulate the Fibaro library functions and other structures into functions that work well when applied in boolean logic sequences.
-- @section triggers


--- A function that tests whether the scene was started manually
-- @treturn boolean A truth value (true /false)

function startedManually ()
    local startSource = fibaro:getSourceTrigger();
    return( startSource["type"] == "other");
end;

--- A function that tests whether the scene was started by a change in a global variable
-- @treturn string If started by a global variable, the name of the variable is returned.
-- @treturn boolean If started by something else, 'false' is returned.


function startedByVariable ()
    local startSource = fibaro:getSourceTrigger();
    if startSource["type"] == "global" then
        return (startSource["name"]);
    else
        return false;
    end;
end;

--- A function that tests whether the scene was started by a change in the state or property of a device.
-- @treturn table A table containting two fields:
--  'deviceID', indicating the ID of the triggering device
--  'propertyName' the property of the device that changed, causing the scene to trigger.
-- @treturn boolean A truth value (true /false).
function startedByDevice ()
    local startSource = fibaro:getSourceTrigger();
    -- startSource ={type="property",deviceID="11",propertyName="tet"}
    if startSource["type"] == "property" then
        return ({deviceID=startSource["deviceID"], propertyName=startSource["propertyName"]});
    else
        return false;
    end;
end;

--- A function that tests whether the scene is currently running.
-- Please note that the testing is stated in the negative. What is tested is whether the scene is NOT
-- running, as this is the most probable use case.
-- @treturn boolean A truth value (true /false).
function sceneNotCurrentlyRunning()
    local sceneCount = tonumber(fibaro:countScenes());
    return (sceneCount == 1);
end;

--- A function that checks that a device is drawing power, if on
-- The use case for this function is for instance a car heater. If it is turned on, it should draw power.
-- If not, it is unplugged. Of course, this function requires a device that has power reporting.
-- @tparam number id The ID of the device.
-- @tparam number threshold The power consumption threshold. If the power consumption is above this value, it is regarded to draw power. Defaults to 15W.
-- @treturn number A boolean indicating wheter the device is ON but not active (not plugged in)
function onButUnplugged(id,threshold)
    local t = threshold or 15;
    local state = tonumber(fibaro:getValue(id, "value"));
    local pow = tonumber(fibaro:getValue(id, "power"));

    return(state == 1 and pow > t);
end;

--- A function which transforms a sceneActivation to a boolean value.
-- The idea is that the scene developer could just specify what kind of keypress should be tested for. The function then takes a scene controller specific table
-- in which available key presses and a description of them is stored.
-- @tparam number id The ID of the scene controller sending sceneActivation commands.
-- @tparam string descriptionstring A textual description of the event to look for.
-- @tparam table descriptiontable A scene controller specific table of available codes and textual descriptions.
-- @see nodonSceneTable
-- @see nodonSceneTableVerbose
-- @see zwavemeSceneTable
-- @see zwavemeSceneTableVerbose

function buttonPressed(id,descriptionstring,descriptiontable)
  local dtab = descriptiontable or nodonSceneTableVerbose;
  local inDesc = tostring(descriptionstring) ;
  local scene = tonumber(fibaro:getValue(id, "sceneActivation"));
  local desc = tostring(dtab[scene]);
  return(inDesc == desc);
end;

--- Scene controller specific tables of available key presses and sceneActivation codes.
-- @section sceneActivationTables

--- A table of mappings between NodOn remote scene codes and a text description.
-- @table nodonSceneTableVerbose
-- @field 10 Button 1 Single Press
-- @field 20 Button 2 Single Press
-- @field 30 Button 3 Single Press
-- @field 40 Button 4 Single Press
-- @field 13 Button 1 Double Press
-- @field 23 Button 2 Double Press
-- @field 33 Button 3 Double Press
-- @field 43 Button 4 Double Press
-- @field 12 Button 1 Hold Press
-- @field 22 Button 2 Hold Press
-- @field 32 Button 3 Hold Press
-- @field 42 Button 4 Hold Press
-- @field 11 Button 1 Hold Released
-- @field 21 Button 2 Hold Released
-- @field 31 Button 3 Hold Released
-- @field 41 Button 4 Hold Released
-- @see buttonPressed
-- @within sceneActivationTables
nodonSceneTableVerbose = {
    [10]="Button 1 Single Press",
    [20]="Button 2 Single Press",
    [30]="Button 3 Single Press",
    [40]="Button 4 Single Press",
    [13]="Button 1 Double Press",
    [23]="Button 2 Double Press",
    [33]="Button 3 Double Press",
    [43]="Button 4 Double Press",
    [12]="Button 1 Hold Press",
    [22]="Button 2 Hold Press",
    [32]="Button 3 Hold Press",
    [42]="Button 4 Hold Press",
    [11]="Button 1 Hold Released",
    [21]="Button 2 Hold Released",
    [31]="Button 3 Hold Released",
    [41]="Button 4 Hold Released"
};

--- Compressed table for mappings between scene codes and NodOn button pressed, and manner in which it was pressed.
-- In the short forms stored, the 'SP' indicates a single press, 'DP' a double press. 'HP' indicates that the button is pressed and held, and 'HR' that it is released.
-- @table nodonSceneTable
-- @field 10 (1SP) Button 1 Single Press
-- @field 20 (2SP) Button 2 Single Press
-- @field 30 (3SP) Button 3 Single Press
-- @field 40 (4SP) Button 4 Single Press
-- @field 13 (1DP) Button 1 Double Press
-- @field 23 (2DP) Button 2 Double Press
-- @field 33 (3DP) Button 3 Double Press
-- @field 43 (4DP) Button 4 Double Press
-- @field 12 (1HP) Button 1 Hold Press
-- @field 22 (2HP) Button 2 Hold Press
-- @field 32 (3HP) Button 3 Hold Press
-- @field 42 (4HP) Button 4 Hold Press
-- @field 11 (1HR) Button 1 Hold Released
-- @field 21 (2HR) Button 2 Hold Released
-- @field 31 (3HR) Button 3 Hold Released
-- @field 41 (4HR) Button 4 Hold Released
-- @see buttonPressed
nodonSceneTable = {
    [10]="1SP",
    [20]="2SP",
    [30]="3SP",
    [40]="4SP",
    [13]="1DP",
    [23]="2DP",
    [33]="3DP",
    [43]="4DP",
    [12]="1HP",
    [22]="2HP",
    [32]="3HP",
    [42]="4HP",
    [11]="1HR",
    [21]="2HR",
    [31]="3HR",
    [41]="4HR"
};

--- A table for Zwave.me wall controller (actually keyfob) scene codes.
-- @table zwavemeSceneTableVerbose
-- @field 11 Button 1 Single Click
-- @field 21 Button 2 Single Click
-- @field 31 Button 3 Single Click
-- @field 41 Button 4 Single Click
-- @field 12 Button 1 Double Click
-- @field 22 Button 2 Double Click
-- @field 32 Button 3 Double Click
-- @field 42 Button 4 Double Click
-- @field 13 Button 1 Press and hold
-- @field 23 Button 2 Press and hold
-- @field 33 Button 3 Press and hold
-- @field 43 Button 4 Press and hold
-- @field 14 Button 1 Click and then Press and hold
-- @field 24 Button 2 Click and then Press and hold
-- @field 34 Button 3 Click and then Press and hold
-- @field 44 Button 4 Click and then Press and hold
-- @field 15 Button 1 Click and then Press and hold
-- @field 25 Button 2 Click and then Press and hold
-- @field 35 Button 3 Click and then Press and hold
-- @field 45 Button 4 Click and then Press and hold
-- @field 16 Button 1 Click and then Press and hold
-- @field 26 Button 2 Click and then Press and hold
-- @field 36 Button 3 Click and then Press and hold
-- @field 46 Button 4 Click and then Press and hold
-- @see buttonPressed
zwavemeSceneTableVerbose = {
    [11]="Button 1 Single Click",
    [21]="Button 2 Single Click",
    [31]="Button 3 Single Click",
    [41]="Button 4 Single Click",
    [12]="Button 1 Double Click",
    [22]="Button 2 Double Click",
    [32]="Button 3 Double Click",
    [42]="Button 4 Double Click",
    [13]="Button 1 Press and hold",
    [23]="Button 2 Press and hold",
    [33]="Button 3 Press and hold",
    [43]="Button 4 Press and hold",
    [14]="Button 1 Click and then Press and hold",
    [24]="Button 2 Click and then Press and hold",
    [34]="Button 3 Click and then Press and hold",
    [44]="Button 4 Click and then Press and hold",
    [15]="Button 1 Click and then Press and hold",
    [25]="Button 2 Click and then Press and hold",
    [35]="Button 3 Click and then Press and hold",
    [45]="Button 4 Click and then Press and hold",
    [16]="Button 1 Click and then Press and hold long time",
    [26]="Button 2 Click and then Press and hold long time",
    [36]="Button 3 Click and then Press and hold long time",
    [46]="Button 4 Click and then Press and hold long time"
};



--- Compressed table for mappings between scene codes and Zwave.me button pressed, and manner in which it was pressed.
-- In the short forms stored, the 'SC' indicates a single click, 'DC' a double click. 'PH' indicates that the button is pressed and held. In cases when two actions are performed, like in the case of a click followed by a press that is held, then the two actions are separated by a '_' in the code.
-- @table zwavemeSceneTable
-- @field 11 (1SC) Button 1 Single Click
-- @field 21 (2SC) Button 2 Single Click
-- @field 31 (3SC) Button 3 Single Click
-- @field 41 (4SC) Button 4 Single Click
-- @field 12 (1DC) Button 1 Double Click
-- @field 22 (2DC) Button 2 Double Click
-- @field 32 (3DC) Button 3 Double Click
-- @field 42 (4DC) Button 4 Double Click
-- @field 13 (1PH) Button 1 Press and hold
-- @field 23 (2PH) Button 2 Press and hold
-- @field 33 (3PH) Button 3 Press and hold
-- @field 43 (4PH) Button 4 Press and hold
-- @field 14 (1C_PH) Button 1 Click and then Press and hold
-- @field 24 (2C_PH) Button 2 Click and then Press and hold
-- @field 34 (3C_PH) Button 3 Click and then Press and hold
-- @field 44 (4C_PH) Button 4 Click and then Press and hold
-- @field 15 (1PLH) Button 1 Click and then Press and hold
-- @field 25 (2PLH) Button 2 Click and then Press and hold
-- @field 35 (3PLH) Button 3 Click and then Press and hold
-- @field 45 (4PLH) Button 4 Click and then Press and hold
-- @field 16 (1C_PLH) Button 1 Click and then Press and hold
-- @field 26 (1C_PLH) Button 2 Click and then Press and hold
-- @field 36 (1C_PLH) Button 3 Click and then Press and hold
-- @field 46 (1C_PLH) Button 4 Click and then Press and hold
-- @see buttonPressed
zwavemeSceneTable = {
    [11]="1SC",
    [21]="2SC",
    [31]="3SC",
    [41]="4SC",
    [12]="1DC",
    [22]="2DC",
    [32]="3DC",
    [42]="4DC",
    [13]="1PH",
    [23]="2PH",
    [33]="3PH",
    [43]="4PH",
    [14]="1C_PH",
    [24]="2C_PH",
    [34]="3C_PH",
    [44]="4C_PH",
    [15]="1PLH",
    [25]="2PLH",
    [35]="3PLH",
    [45]="4PLH",
    [16]="1C_PLH",
    [26]="1C_PLH",
    [36]="1C_PLH",
    [46]="1C_PLH"
};




--- These functions are used to either run something at a specific time, or to determine whether some action should be performed based on time information.
-- @section timers 

--- A function that tests whether the current time is within a specified time window from a given time.
-- In order to work well with the output of fibaro:call(1,"sunsetHour") and similar use cases, time is specified in the
-- form of a string ("08:10" for ten minutes past eight in the morning) in a 24 hour clock format, and an offset (in minutes).
-- When called as isTime("08:10",0,10) the function will return 'true' from 08:09:50 to 08:10:10, and 'false' outside of this time range.
-- Please note that the function will return true every time it is checked within the time range, so the calling function
-- needs to make sure that there is an appropriate delay between checks.
--
-- A call isTime("08:10",45,10) will return 'true' from 08:54:50 to 08:55:10, and 'false' earlier or later than this.
-- @tparam string timeString The textual specification of the time to test against (e.g. "08:10").
-- @tparam number offsetMinutes The number of minutes to add to the 'timeString' time.
-- @tparam number secondsWindow The size of the time window (in secons) in which the function will return 'true'. A zero (0) will cause the function to return 'true' only at 08:10:00 (and not 08:10:01) when called as isTime("08:10",0,0) so calls like that should be avoided.
-- @treturn boolean A boolean (true or false) indicating whether the current time is within the specificed time range.


function isTime (timeString, offsetMinutes, secondsWindow)
    local timeTable = timestringToTable(timeString);
    local timeEpoch = tableToEpochtime (timeTable);
    local timeWithOffset = timeEpoch + (offsetMinutes * 60);
    local now = os.time();
    return ( math.abs(timeWithOffset - now) <= secondsWindow );
end;

--- Functions that may be used for boolean tests of current date or time.
-- @section timetriggers

--- A function that checks whether the current time is within a range given as two text strings.
-- This function is often more convenient than 'isTime' as you don't have to calculate the time and offset yourself.
-- Please note that the function will return true every time it is checked within the time range, so the calling function
-- needs to make sure that there is an appropriate delay between checks.
--
-- @tparam string startTimeString a time specification in the form of "HH:MM" (e.g. "08:10") indicating the start of the time range.
-- @tparam string endTimeString a time specification in the form of HH:MM (e.g. "08:10") indicating the end of the time range.
-- @treturn boolean A boolean (true or false) indicating whether the current time is within the specificed time range.
function timeIsInRange (startTimeString, endTimeString)
    local startTimeTable = timestringToTable(startTimeString);
    local endTimeTable = timestringToTable(endTimeString);
    local startTimeEpoch = tableToEpochtime (startTimeTable);
    local endTimeEpoch = tableToEpochtime (endTimeTable);
    local newEndTimeTable = endTimeTable;
    -- allow for end time being in the upcoming day, but before startTime then
    if (endTimeEpoch < startTimeEpoch) then
        endTimeEpoch = endTimeEpoch + 24*3600;  -- add 24 hours
        -- Now, we make a new table object, to find out whether the DST status of the new end time is
        newEndTimeTable = os.date("*t",endTimeEpoch);
    end;
        -- Now, we adjust for Daylight saving time effects
    if (startTimeTable.isdst == false and newEndTimeTable.isdst == true) then
        -- In this case, start time is Not summer, and end time is in summer time
        -- which means that we are going from spring into summer
        -- then advance the clock one more hour from the end time
        endTimeEpoch = endTimeEpoch + 3600;
    elseif (startTimeTable.isdst == true and newEndTimeTable.isdst == false) then
        -- Here, we are coming into fall (from summer)
        -- then remove one hour from the time end time
         endTimeEpoch = endTimeEpoch - 3600;
    end;
    local now = os.time();
    return ( (startTimeEpoch <= now ) and (endTimeEpoch >= now));
end;

--- A function that indicates whether today is one of the weekdays named in the given list.
-- A call 'isDayofWeek({"Mon","Tues"})' will return true on Wednesdays and Tuesdays, but not other days.
-- @tparam {string} dayList A list of names of weekdays in a long (e.g. "Friday") or short (e.g. "Fri") format.
-- @treturn boolean A boolean (true /false) indicating whether the short name of today is given in the list.
-- @usage print(isDayOfWeek{"Sun"})
-- -- This will print "true" on Sundays, but not on other weekdays
--  

function isDayOfWeek (dayList)
    local today = os.date("%a",os.time());
    local longToday = os.date("%A",os.time());
    for i, v in ipairs(dayList) do
        if today == v or longToday == v then
            return(true);
        end;
    end;
    return(false);
end;

--- Simple function that returns true if today is a weekday.
-- A weekday is defined as Monday-Friday.
-- @treturn boolean A boolean (true/false)

function isWeekDay ()
    local today = tonumber(os.date("%w",os.time()));
    -- Please note that this specification is 0-6 range, sunday=0
    return (not (today == 0 or today == 6));
end;

-- Simple function that returns true if tomorrow is a weekday.
-- A weekday is defined as Monday-Friday.
-- @treturn boolean A boolean (true/false)

function isWeekDayTomorrow ()
    local today = tonumber(os.date("%w",os.time()));
    -- Please note that this specification is 0-6 range, sunday=0
    return (not (today == 5 or today == 6));
end;

--- Simple function that returns true if today is part of the weekend.
-- A weekday is defined as Saturday or Sunday
-- @treturn boolean A boolean (true/false)


function isWeekEnd ()
    local today = tonumber(os.date("%w",os.time()));
    return (today == 0 or today == 6);
end;

--- Simple function that returns true if tomorrow is part of the weekend.
-- A weekday is defined as Saturday or Sunday
-- @treturn boolean A boolean (true/false)


function isWeekEndTomorrow ()
    local today = tonumber(os.date("%w",os.time()));
    return (today == 5 or today == 6);
end;

--- Check whether current time is before a specified time.
-- The function is designed to work well in a chain of checks, and therefore also makes sure that
-- time is not before the start of the day.  This functions is primarily designed to be used with "sunriseTime" or similar variables.
-- @tparam string time A time specification string, e.g. "08", "08:10" or "08:10:10"
-- If not specified, seconds is assumed to be 00, so that "08:10" is equivalent to giving "08:10:00"
-- as an argument. Thus, this function will then return 'true' up until "08:09:59" .
-- @tparam number offset an offset that should be applied to the time (in number of seconds). Negative values will cause the function to return true x seconds before the indicated time of day.
-- @treturn boolean A truth value (true/false)
-- @see os.time

function beforeTime(time, offset)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local startOfDay = tableToEpochtime(timestringToTable("00:00"));
    local off = offset or 0;
    timeEpoch = timeEpoch + off;
    local now = os.time();
    return( (now < timeEpoch) and (now >= startOfDay ));
end;

--- Check whether current time is after a specified time.
-- The function is designed to work well in a chain of checks, and therefore also makes sure that
-- time is not after the end of the day.
-- @tparam string time A time specification string, e.g. "08", "08:10" or "08:10:10".
-- If not specified, seconds is assumed to be 00, so that "08:10" is equivalent to giving "08:10:00"
-- as an argument. Thus, this function will then return 'true' from "08:10:01" and onwards.
-- @tparam number offset an offset that should be applied to the time (in number of seconds). Negative values will cause the function to return true x seconds before the indicated time of day.
-- @treturn boolean A truth value (true/false)
-- @see os.time

function afterTime(time, offset)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local endOfDay = tableToEpochtime(timestringToTable("23:59:59"));
    local off = offset or 0;
    timeEpoch = timeEpoch + off;
    local now = os.time();
    return( (now > timeEpoch) and (now <= endOfDay ));
end;

--- A function that selects the earlierst time specification from a list of times.
-- @param ... a list of times in string format, e.g. "HH:MM" or "HH:MM:SS". 
-- @return The time that occurs earliest in the day.
-- @usage
-- print(earliest("22","20:30:01","21","20:30"));
-- -- will return "20:30" since tis is synonumous with "20:30:00"
-- sunsetHour = tostring(fibaro:getValue(1, "sunsetHour") or "22:30:01");
-- -- This code then selects the time that occurs earliest - sunset or 22:30.
-- print(earliest(sunsetHour,"22:30"));

function earliest(...)
    local arg = {...};
    local out = nil;
    local currEpoch = nil;
    local outEpoch = nil;
    for k,time in ipairs(arg) do
        if out == nil then
            out = time;
            outEpoch = tableToEpochtime(timestringToTable(time));
        else
            currEpoch = tableToEpochtime(timestringToTable(time));
            if currEpoch < outEpoch then
                out = time;
            end;
        end;
    end;
    return(out);
end;

--- A function that selects the latest time specification from a list of times.
-- @param ... a list of times in string format, e.g. "HH:MM" or "HH:MM:SS". 
-- @return The time that occurs latest in the day.
-- @usage
-- print(earliest("22","20:30:01","21","20:30"));
-- -- will return "22".
-- sunsetHour = tostring(fibaro:getValue(1, "sunsetHour") or "22:30:01");
-- -- This code then selects the time that occurs latest - sunset or 22:30.
-- print(earliest(sunsetHour,"22:30"));

function latest(...)
    local arg = {...};
    local out = nil;
    local currEpoch = nil;
    local outEpoch = nil;
    for k,time in ipairs(arg) do
        if out == nil then
            out = time;
            outEpoch = tableToEpochtime(timestringToTable(time));
        else
            currEpoch = tableToEpochtime(timestringToTable(time));
            if currEpoch > outEpoch then
                out = time;
            end;
        end;
    end;
    return(out);
end;

--- A function that lets you specify date and time in a very flexible way through a table
-- The table should use only fields that are returned by a call to @{os.time} (year, month, day, hour, min, sec), 'wday' (1-7 scale, Sunday is 1) or 'yday' (day within the year, Jan 1st is 1).
-- @tparam table dateTable A table giving a time specification.  For instance, {day=6,hour=15} returns 'true' on Sundays at 3 pm, {year=2016,month=2, hour=9} will return 'true' every day in February 2016 at 9 am, and 'false' at any time where parts of specification is not met. In each field, a table may be given, in which case any one of the options given will be accepted.
-- @treturn boolean A boolean (true/false) indicating the complete match of the table against current time and date.
-- @see os.time
-- @usage datetimeTableTrue({month=2,minute=2})
-- -- # will return 'true' every other minute in february.
-- datetimeTableTrue({wday=2,yday=2})
-- -- # will return 'true' when tested on the January 2nd, if it is a Monday.
-- datetimeTableTrue({month=1,day=14,hour=6, min=30})
-- -- Will return 'true' when I wake up on my birthday
-- datetimeTableTrue({month=1,day={14,15,16},hour=6, min={0,30}})
-- -- Will return 'true' on the 14th,15th or 16th of January at 6:00 or 6:30.

function datetimeTableTrue (dateTable)
    local nowTodayTable = os.date("*t");
    local scorekeeper = false;
    for k,v in pairs(dateTable) do
        -- Here I intentionally disregard the boolean isdst value, as the dateTable time specification should always be "true" time
        if type (v) == "number" then
            if not (nowTodayTable[k] == dateTable[k]) then
                return(false);
            end;
        elseif type (v) == "table" then
            -- Here the logic is different. We cannot return 'false' until we have checked all elements in the list.
            for ki, vi in pairs(v) do
                if (nowTodayTable[k] == v[ki]) then
                    scorekeeper = true;
                end;
            end;
            if not scorekeeper then
                return(false)
            end;
            scorekeeper = false;
        else
            if not debug == nil then
                fibaro:debug("List of options in a field in the table should only contain numbers")
            else
                error("List of options in a field in the table should only contain numbers")
            end;
        end;
    end;
    return(true);
end;

--- A funtion that applies a time adjustment to a time specified in a string format
-- What is supplied to the function is a time in a standard format (eg "08:25", "8:25", "08:25:05").
-- A numer of minutes (or optional seconds) are then added to the time, and the time is returned as a new time string.
-- The adjustment is applied at the Epoch time level, which means that adjustments that also leads to change of date will be correctly handled.
-- For the conversion, the time specification is assumed to be refering to *today*.
-- @tparam string stringTime the time specification.
-- @tparam number adjustmentMinutes the number of minutes to be added to the time. Negative values means subtraction of time.
-- @tparam number extraSecondsAdjustment an optional number of seconds to be added too (that is, in additional to the minutes). Negative numbers means subtraction.

function stringTimeAdjust(stringTime,adjustmentMinutes,extraSecondsAdjustment)
    local extraSecs = extraSecondsAdjustment or 0;
    local timeEpoch = tableToEpochtime(timestringToTable(stringTime));
    local adjustSeconds = tonumber(adjustmentMinutes) * 60 + tonumber(extraSecs);
    local newEpochTime = timeEpoch + adjustSeconds;
    local newTime = tostring(os.date("%X",newEpochTime));
    return(newTime);
end;


--- Function that simplifies running a scene on a timer and specify the delay needed.
-- The basic structure of the function is that it takes a truth value indicating whether the scene should run.
-- The idea is that this truth value should be the result of a series of time or source evaluations combined
-- into one evaluation by 'and' and 'or' joiners, possibly with nesting.
-- The function @{runIf} will then evaluate the function supplied as the second argument, if the first argument is evaluated to 'true'. @{runIf} could also be a table of integers, which should then be the Scene IDs of scenes that should be executed.
-- 
-- After running the function constituting the scene, or the scenes with the scene ID's supplies as the'toRun' argument,  a delay may be imposed.
-- 
-- @tparam boolean shouldRun A truth value. If evaluated to 'true', then the function will be run and the delay imposed.
-- @tparam func toRun The function summarising the actions of the scene.
-- @tparam {int} toRun if instead an array is passed to the function, this is assumed to be an array of scene IDs to run.
-- @tparam[opt=0] int sleepSeconds Optional number of seconds delay that should be imposed after having performed the scene (defaults to 60). If the scene is not executed, there is not delay. Please note that the whole scene is put to sleep 'sleepSeconds' seconds, which may affect the execution of other timers.
-- @usage
-- function f () fibaro:call(12,"powerON"); end
-- -- A very simple scene function
-- runIf ( sceneNotCurrentlyRunning() and isTime("08:10",0,20) and isDayOfWeek("Mon","Tues"), f, 2*60)
-- -- This call will turn on switch 12 when tested from 08:09:40 to 08:10:20 on Mondays and Tuesdays
-- -- and then sleep for 2 minutes in order to ensure that the scene is not run constantly,
-- -- or more than once, as the 2 minutes delay combined with the call to @{sceneNotCurrentlyRunning} makes
-- -- sure that it is not evaluated again within the 20 seconds time window allowed by the call to @{isTime}.



function runIf(shouldRun, toRun, sleepSeconds )
  local delay = sleepSeconds or 0;
  if (type(toRun) == "function" and shouldRun ) then
    toRun();
  elseif ( type(toRun) == "table"  and shouldRun ) then
    for k,v in pairs(toRun) do
        v = tonumber(v);
        if ( fibaro:isSceneEnabled(v)) then
          fibaro:startScene(v);
        else
          fibaro:debug("Not running disabled scene ID:".. tostring(k));
        end;
    end;
  end;
  fibaro:sleep(delay*1000);
end;

--- A small function that just makes the script wait intil the start of the next minute.
-- Actually, the function name is a misnomer as the function rarely waits exactly one minute. 
-- It just waits until the next minute starts.

function waitUntilNextMinute()
    local currSec = os.time() % 60;
    local toWait = 60 - currSec;
    fibaro:sleep(toWait *1000);
end;

--- This function provides the basic functionality for timer schenes.
-- Essentially, it runs forever (or until the scene is stopped) and executed the supplied function every minute.
-- @tparam function fun A function that describes a set of actions to be performed. Usually this function contains a series of {runIf} calls. Please note that the argument is a function, not a call to a function. See Usage below.
-- @usage
-- funciton myFun() 
--   runIf(isWeekEnd() and timeIs("09:00"),99,0); -- Runs scene with ID 99 at 09:00 on weekends
--   runIf(isWeekEnd() and timeIs("06:30"),99,0); -- Runs scene with ID 99 at 07:30 on weekdays
-- end;
-- runEveryMinute(myFun);


function runEveryMinute(fun)
    while(true) do
        fun();
        waitUntilNextMinute();
    end;
end;

--- Function that determines whether its time to turn off the heater.
-- The determination is based on the time when the heater was turned on, an auto off time and a
-- filter boolean that makes it possible to block turning the AC off.
-- @tparam number heaterOnTime An Epoch time stamp indicating when the heater was turned on
-- @tparam number autoOffTime The number of hours after which the heater should automatically be turned off.
-- @tparam boolean blockedByOutsideTemperature A true/false value. If 'true' automatic shutoff will be blocked. The idea is that this value should be based on an expression involving the outside temperature
-- @usage
-- shouldStopHeater (fibaro:getModificationTime(193, "value"), 3, tonumber(fibaro:getValue(3, "Temperature")) <= -20 )
-- -- This call will return when checked 3 hours or more after the time when the state of
-- -- device 193 was last changed, provided that the current outside temperature is not <= -20 degrees.
-- -- If the temperature is <= -20 degrees, the function will always return 'false'
-- -- so that the heater is not stopped.

function shouldStopHeater (heaterOnTime, autoOffTime, blockedByOutsideTemperature)
    local now = os.time();
    -- Here, I negate the boolean so that a true in the block results in a false in
    -- response to the question whether the shutoff should be blocked
    local notblock = (not blockedByOutsideTemperature) or false;
    return (  notblock  or  ( now - heaterOnTime ) >= (3600 * autoOffTime) );
end;

--- Convenience funtion for printing an epoch timestamp in ISO 8601:1988 format.
-- @param timestamp a epoch time stamp, such as a time indication associated with a Fibaro event.
-- @treturn string a text representation "YYYY-MM-DD hh:mm" of the epoch timestamp, in the local timezone.

function iso8601DateTime(timestamp)
  return(os.date("%Y-%m-%d %X",tonumber(timestamp)));
end;



--- A function that determines whether the heater of a car should be turned on.
-- The determination is base on the time when you want to leave, the temperature outside and an optional value indicating whether the heater is on already or not.
-- @tparam string readyTime A time specification where the cars should be ready, e.g. "07:30" for half past 7 in the morning.
-- @tparam number tempOutside The temperature outside or inside the car (if available).
-- @tparam[opt=true] boolean eco Should eco settings be used? If not, the car motor health will be considered more important.
-- @tparam[opt=0] number manualMinutesOffset A manual offset in number of minutes. Should be negative if the heater should start ahead of time, and positive if starting should be delayed some minutes.
-- @treturn boolean A truth value (true/false).

function timeToStartCarHeater (readyTime, tempOutside, eco,manualMinutesOffset)
    local timeEpoch = tableToEpochtime(timestringToTable(readyTime));
    local offset = manualMinutesOffset or 0;
    local now = os.time();
    local startTime = timeEpoch;
    if (eco) then
        if (tempOutside <= -15) then
            -- 2 Hours before time
            startTime = timeEpoch - (3600*2) ;
        elseif (tempOutside <= -10) then
            -- 1 Hour before time
            startTime = timeEpoch - (3600*1) ;
        elseif (tempOutside <= 0) then
            -- 1 Hours before time
            startTime = timeEpoch - (3600*1);
        elseif (tempOutside <= 10) then
            -- 0.5 Hours before time
            startTime = timeEpoch - (3600*0.5);
        else
            -- if not <=10 degrees C, do not start the heater.
            return(false);
        end;
    else
        if (tempOutside <= -20) then
            -- 3 Hours before time
            startTime = timeEpoch - (3600*3);
        elseif (tempOutside <= -10) then
            -- 2 Hours before time
            startTime = timeEpoch - (3600*2);
        elseif (tempOutside <= 0) then
            -- 1 Hours before time
            startTime = timeEpoch - (3600*1);
        elseif (tempOutside <= 10) then
            -- 1Hours before time
            startTime = timeEpoch - (3600*1);
        else
            -- if not <=10 degrees C, do not start the heater.
            return(false);
        end;
    end;
    -- Now calculate whether the heater should start NOW
    return (  ( (startTime + manualMinutesOffset*60) <= now) and (now <= timeEpoch));
end;

--- Utility functions related to date and time conversions.
-- These small local functions are used heavilly by the functions in the previous section, and should therefore be included in scenes as soon as they are.
-- @section datetimeutilities

--- A function that creates a @{os.date} table from a time specified as a string. 
-- Provided that the function is not called exactly at midnight, the function will return a table that mathces the output of an os.date("*t")
-- @tparam string time A text representation (e.g. "08:10") of the time of today to concert to a @{os.date} date table. Allowed formats are "HH", "HH:MM" or "HH:MM:SS". "HH" is a short form for "HH:00" and "HH:MM" is a short for "HH:MM:00".
-- @treturn table A table with year, month,day, hour min, sec and isdst fields.
-- @see os.date
-- @usage
-- timestringToTable("08:10")
-- -- Will return 'true' when between 08:10  and 08:59
-- timestringToTable("08")
-- -- Will return 'true' the entire hour
-- timestringToTable("08:10:10")
-- -- Will return 'true' exactly at the indicated second
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


-- Utility function that computes the number of seconds since Epoch from a date and time table in the form given by os.date
-- @tparam table t A time specification table with the fields year, month, day, hour, min, sec, and isdst.
-- @treturn number An integer inficating the Epoch time stamp corresponding to the date and time given in the table.

function tableToEpochtime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end;


--- Functions that together provide a timed auto-off/on functionality, and other housekeeping type actions.
-- Useful for devices that do not have this functionality themselves, or for delayed OFF or ON that are outside of the time range offered by the device internally.
-- These functions all require that a HOUSEKEEPING variable is set up.
-- @section housekeeping


--- Utility function to check the integrety of hte HOUSEKEEPING variable.
function checkHousekeepingIntegrity()
    local houseVariable = tostring(fibaro:getGlobalValue("HOUSEKEEPING"));
    local parsedVariable = json.decode(houseVariable);
    for time,cmdList in pairs(parsedVariable) do
        -- check that all keys are interpertable as epoch time stamps 
        if tonumber(k) == nil then
            return(false);
        end;
        for k,cmdL in pairs(cmdList) do
            -- Check that the load is a table and that it has the manditory fields
            if type(cmdL) ~= "table" and cmdL["id"] == nil or cmdL["cmd"] == nil then
                return(false);
            end;
            -- basic checks of structure:
            -- here we check that the time stamp is a number, and that it is larger than the 
            -- time stamp of the time when the function was written
            -- which is unlikely to be an epoch rep. of a time event that should be executed. 
            if tonumber(cmdL["id"]) == nil or tonumber(cmdL["id"]) <= 1510469428 then
                return(false);
            end;
            -- Check that commands that require a paramter gets one
            -- commnads I know about are these: 
            local oneArg ={"setValue","setSetpointMode","setMode","setFanMode","setVolume","setInterval","pressButton","setFanMode"};
            if tableValueExists(oneArg,cmdL["cmd"] ) and cmdL["value"] == nil then
                return(false);
            end; 
            -- commands that I know have 2 arguments
            -- these should have a "arg1" and "arg2" specification in the command structure
            local twoArgs ={"setThermostatSetpoint","setSlider","setProperty"};
            if tableValueExists(twoArgs,cmdL["cmd"] ) and (cmdL["arg1"] == nil or cmdL["arg2"] == nil) then
                return(false);
            end;
        end       
    end;
    -- Is the function has not returned due to en error before, the structure seems fine.
    return(true);
end;



function initiateHousekeepingVariable()
    fibaro:debug("Initiating the variable HOUSEKEEPING to {}")
    local EMPTY = {};
    --EMPTY["turnOff"] = {};
    fibaro:setGlobal('HOUSEKEEPING',json.encode(EMPTY))
end;


--- This function sets a housekeeping task schedule for a set of devices.
-- The function requires that a HOUSEKEEPING global variable is initiated using the {@initiateHousekeepingVariable} and is fully functional.
-- This function will then insert a time when the task 'command' should be performed on devices. The time is specified by the user as a delay (relative to the current time).
-- The housekeeping task will then be performed after 'delaySeconds' seconds has elapsed, or whenever the houekeeping routine is performed after that. This makes sure that timers are not interrupted if you decide to restart your Home Center when timers are running.
-- @param deviceIDs A singe device ID or an array of IDs which should recieve the 'command' command after  'delaySeconds' seconds.
-- @tparam int delaySeconds The number of seconds that should pass before the 'command' is sent.
-- @tparam[opt='turnOff'] string command The command to be sent. The command could also be a {commad,value} tuple.
-- @usage
-- registerHousekeepingTask({10,11,13},25,"turnOn")
-- -- This will turn devices 10,11 and 13 on after 25 seconds.
-- registerHousekeepingTask({10,11,13},25,"turnOn")
-- -- This will turn devices 10,11 and 13 on after 25 seconds.
-- TODO: kolla så att denna funktion verkligen fungerar!

function registerHousekeepingTask(deviceIDs, delaySeconds, command )
    local command = command or "turnOff";

    local timeToSet = (os.time() + delaySeconds);
    -- Reinitiate variable if it is not parable as json and is well structured
    if not pcall(checkHousekeepingIntegrity) then 
        initiateHousekeepingVariable();
    end;
    -- Get data
    local houseVariable = tostring(fibaro:getGlobalValue('HOUSEKEEPING'));
    local parsedVariable = json.decode(houseVariable)  ; 
    -- make sure that we have an array of device ids.
    if type(deviceIDs) ~= "table" then
        deviceIDs = {deviceIDs};
    end;
    local cmdList = {};
    for k,id in pairs(deviceIDs) do
        -- command to be inserted
        local cmdTable = {["id"]=command};
        cmdTable = {["cmd"]=command};
        -- This is for one argument commands
        if type(command) == "table" and #command == 2 then
            cmdTable["value"] = command[2];
        end;
        if type(command) == "table" and #command == 3 then
            cmdTable["arg1"] = command[2];
            cmdTable["arg2"] = commant[3];
        end;
        cmdList[#cmdList+1] = cmdTable;
    end;
    -- insert the new schedule
    parsedVariable[tostring(timeToSet)] = cmdList;
    -- print and store housekeeping 
    local outString = json.encode(parsedVariable);
    fibaro:debug("Setting Housekeeping tasks: "..outString);
    fibaro:setGlobal('HOUSEKEEPING',outString);
end;

--- A procedure that performs housekeeping tasks
-- It uses the HOUSEKEEPING variable and interprets the time schedule in there. Keys in the table should be the time when tasks should be perfomrmed.
-- The value should be a list of command specification lists (nested list).

function doHousekeeping()
    if not pcall(checkHousekeepingIntegrity) then 
        fibaro:debug("ERROR: HOUSEKEEPING tasks are not well structured. Performing reset. No taks will be performed, so you need to initiate them again.")
        initiateHousekeepingVariable();
        return(false);
    end;
    -- Get data
    local houseVariable = tostring(fibaro:getGlobalValue('HOUSEKEEPING'));
    local parsedVariable = json.decode(houseVariable) ; 
    for time,cmdStruct in pairs(parsedvariable) do
        now = os.time();
        -- check whether the stored execution time is now or has passed.
        if tonumber(time) <= now then
            if #cmdStruct == 1 then fibaro:call(tonumber(cmdStruct["id"]),tostring(cmdStruct["cmd"]));
            elseif #cmdStruct == 2 then fibaro:call(tonumber(cmdStruct["id"]),tostring(cmdStruct["cmd"]),tostring(cmdStruct["value"]));
            elseif #cmdStruct == 3 then fibaro:call(tonumber(cmdStruct["id"]),tostring(cmdStruct["cmd"]),tostring(cmdStruct["arg1"]),tostring(cmdStruct["arg2"]));
            else
                fibaro:debug("ERROR: The HOUSEKEEPING structure is not well formed. Please check the one associated with time ".. tostring(time));
                printHousekeeing();
            end;
        end;
    end;
end;

--- A utility function that may be used for printing the current housekeeping schedule.
function printHousekeeing()
    debugTable(json.decode(tostring(fibaro:getGlobalValue("HOUSEKEEPING"))));
end;




--- Functions that manages the defined time of day.
-- @section timeofday

--- An example time of day scheme that may be used as a default
-- or altered to fit the indivdual's need. 
DEFAULT_TIME_OF_DAY = {
	{["days"]={2,3,4,5,6},["time"]="06:30",["tod"]="Morning"},
	{["days"]={1,7},["time"]="06:30",["tod"]="Morning"},
	{["days"]={2,3,4,5,6},["time"]="08:00",["tod"]="Day"},
	{["days"]={1,7},["time"]="10:00",["tod"]="Day"},
	{["days"]={1,2,3,4,5,6,7},["time"]="18:00",["tod"]="Evening"},
	{["days"]={2,3,4,5,6},["time"]="23:30",["tod"]="Night"},
	{["days"]={1,7},["time"]="23:59",["tod"]="Night"}
};

function setTimeOfDay(todStructure)
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and afterTime(str["time"],0) then
			fibaro:debug("Setting TimeOfDay to '".. str["tod"] .. "'")
			fibaro:getGlobalValue("TimeOfDay",str["tod"]);
			return(true);
		end;
	end;
	return(false);
end;

--- A function that checks whether it is daytime or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Day" if true.
-- @treturn bool An indication whether it currently is daytime or not.

function isDaytime()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "day");
end;

--- A function that checks whether it is nighttime or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Night" if true.
-- @treturn bool An indication whether it currently is nighttime or not.

function isNighttime()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "night");
end;

--- A function that checks whether it is morning or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Morning" if true.
-- @treturn bool An indication whether it currently is morning or not.

function isMorning()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "morning");
end;

--- A function that checks whether it is morning or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Evening" if true.
-- @treturn bool An indication whether it currently is evening or not.

function isEvening()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "evening");
end;


--- A utility function that returns the time today defined as the time when Morning starts.
-- @treturn string The time in text format (e.g. "06:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function wakeupTimeToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Morning" then
			return(str["time"]);
		end;
	end;
end;

--- A utility function that returns the time today defined when Nighttime is defined to start.
-- @treturn string The time in text format (e.g. "23:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function nightTimeToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Night" then
			return(str["time"]);
		end;
	end;
end;

--- A utility function that returns the time today defined when Evening is defined to start.
-- @treturn string The time in text format (e.g. "18:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function eveningStartsToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Evening" then
			return(str["time"]);
		end;
	end;
end;

--- A utility function that returns the time today defined when Daytime is defined to start.
-- @treturn string The time in text format (e.g. "18:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function daytimeStartsToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Day" then
			return(str["time"]);
		end;
	end;
end;


--- More derived, small, utility functions that just makes life simpler
-- @section timeofday_utils

--- A untility function that answers the question of whether it is currently dark outside, but not Nighttime (as defined by the user).
-- @tparam number sunsetOffsetMinutes The numbber minutes that should be used as an offset relative to sunset time. That is, a value of -45 here will result in subnset being considered to occur 45 minutes before actual sunset occurs when calculated from astronomical data.
-- @treturn boolean An indication of whether it is currently after the, possibly adjusted, sunset but also before the defined Nighttime.

function darkButNotNight(sunsetOffsetMinutes)
	local nightTime = nightTimeToday();
	local offset = sunsetOffsetMinutes or 0;
	local sunsetTime = stringTimeAdjust( tostring(fibaro:getValue(1, "sunsetHour")), offset );
	-- check if sunset occurs before the defined night time, and then check whether the current time is inbetween these times 
	if earliest(sunsetTime,nightTime) == sunsetTime then
		return(timeIsInRange(sunsetTime,nightTime));
	else
		-- By definition not true then
		return(false);

	end;
end;
-- A module that collects general programming utility functions



--- Function that prints out the content of a table.
-- The function works well both within  Fibaro Home center 2 and in an ordinary lua environment.
-- @tparam table node A table. Only simple tables (not nested) are supported.
-- @author Alundaio http://stackoverflow.com/questions/9168058/lua-beginner-table-dump-to-console/42062321#42062321

function debugTable(node)
  -- handing two printing functions
  local printFunc = print
  if (fibaro or {}).debug then
    function printFunc(...);
      return fibaro:debug(...);
    end;
  end;
  -- to make output beautiful
  local function tab(amt)
    local str = "";
    for i=1,amt do
      str = str .. "\t";
    end;
    return str;
  end;

  local cache, stack = {},{};
  local depth = 1;
  local output_str = "{\n";

  while true do
    if not (cache[node]) then
      cache[node] = {};
    end;

    local size = 0;
    for k,v in pairs(node) do
      size = size + 1;
    end;

    local cur_index = 1;
    for k,v in pairs(node) do
      if not (cache[node][k]) then
        cache[node][k] = {};
      end;

      -- caches results since we will be recursing child nodes
      if (cache[node][k][v] == nil) then
        cache[node][k][v] = true;

        if (string.find(output_str,"}",output_str:len())) then
          output_str = output_str .. ",\n";
        elseif not (string.find(output_str,"\n",output_str:len())) then
          output_str = output_str .. "\n";
        end;

        local key;
        if (type(k) == "userdata") then
          key = "[userdata]";
        elseif (type(k) == "string") then
          key = "['"..tostring(k).."']";
        else
          key = "["..tostring(k).."]";
        end;

        if (type(v) == "table") then
          output_str = output_str .. tab(depth) .. key .. " = {\n";
          table.insert(stack,node);
          table.insert(stack,v);
          break;
        elseif (type(v) == "userdata") then
          output_str = output_str .. tab(depth) .. key .. " = userdata";
        elseif (type(v) == "string") then
          output_str = output_str .. tab(depth) .. key .. " = '"..v.."'";
        else
          output_str = output_str .. tab(depth) .. key .. " = "..tostring(v);
        end;

        if (cur_index == size) then
          output_str = output_str .. "\n" .. tab(depth-1) .. "}";
        else
          output_str = output_str .. ",";
        end;
      else
        -- close the table
        if (cur_index == size) then
          output_str = output_str .. "\n" .. tab(depth-1) .. "}";
        end;
      end;
      cur_index = cur_index + 1;
    end;

    if (#stack > 0) then
      node = stack[#stack];
      stack[#stack] = nil;
      depth = cache[node] == nil and depth + 1 or depth - 1;
    else
      break;
    end;
  end;
  printFunc(output_str);
end;

--- Function that checks whether a value exists in a table
-- @tparam table tab The table
-- @tparam string value A value to check for.
-- @treturn boolean A value indicating whether the value existed in the table

function tableValueExists(tab, value)
  for k,v in pairs(tab) do
    if value == v then
      return true;
    end;
  end;
  return false;
end;

local function test_tableValueExists()
  local a = {};
  a[12] = "Tolvan";
  a["13"] = "Tretton";
  assert(tableValueExists(a,"Tolvan") == true,"Tolvan finns" );
  assert(tableValueExists(a,"Tretton") == true,"Tretton finns" );
end;

--- A function that finds the union of keys in two tables
-- @tparam table t1 The first table
-- @tparam table t2 The second table
-- @treturn table A table with keys that are the union (no replication) of keys from the two tables, and will a value 'true' assigned to each key.


function keyUnion(t1, t2)
    local outTab = {};
    for k1, v1 in pairs(t1) do
        for k2, v2 in pairs(t2) do
            outTab[k1] = true;
            outTab[k2] = true;
        end;
    end;
    return(outTab);
end;





--- A function that allows you to create an array containing integers ranging from 'start' to 'stop', optionally spaced by 'step' numbers.
-- @tparam integer start The integer which will be the first (head) of the sequence.
-- @tparam integer stop The integer which will either be the largest in the sequence (the tail) or integer setting the upper boundary for the sequence. In the latter case, the last element in the integer array will be the largets integer x the fullfills (x + 'step') < 'stop'.
-- @tparam integer step The spacing between numbers in the returned sequence.
function seq(start, stop, step)
    local myStep = myStep or 1;
    local out = {};
    local i = start;
    local store = start;
    while (store <= stop) do
        out[i] = store;
        i = i + 1;
        store = store + myStep;
    end;
    return out;
end;

--- Utility function that changes keys to values and vise versa for a table.
-- @tparam table t The table to be inverted.
-- @treturn table A table where all the keys in t has become values (and the oposite).
function tableToTable (t)
    local out = {}
    for k, v in pairs(t) do
        out[tostring(v)] = k;
    end;
    return out;
end;

--- A simple utility function which checks whether a value exists within an array
-- @tparam table tab the array.
-- @param value the value to check the presence of.
-- @treturn boolean is the value present in 'tab'?
-- @usage a={};table.insert(a,10);
-- @usage print(arrayContainsValue(a,10));
-- @usage print(arrayContainsValue(a,120));
function arrayContainsValue(tab, value)
    for k,v in pairs(tab) do
        if tostring(v) == tostring(value) then
            return(true);
        end;
    end;
    return(false);
end;


--- A simple utility function which checks whether a key exists in an array
-- @tparam table tab the array.
-- @param key the value to check the presence of.
-- @treturn boolean is the value present in 'tab'?
-- @usage a={};a["10"]=90;a["20"]=80;
-- @usage print(arrayContainsKey(a,10));
-- @usage print(arrayContainsKey(a,120));
function arrayContainsKey(tab, key)
    for k,v in pairs(tab) do
        if tostring(k) == tostring(key) then
            return(true);
        end;
    end;
    return(false);
end;

--- This utility function manages the loading of content from a HomeTable variable
-- @tparam string variableName an optional name of a variable from which the structure should be collected.
-- @treturn table a nested structure containing the HomeTable information.
-- @treturn boolean return value is false if the function fails to load any information, or the HomeTable is empty.
function loadHomeTable (variableName)
    local var = tostring(variableName) or "HomeTable";
    local jT = json.decode(fibaro:getGlobalValue(var));
    -- Check what we got
    if jT == {} then
        fibaro:debug("Could not load content from the HomeTable variable \'".. var .. "\'. Please make sure the variable exists.");
        return(false);
    else
        fibaro:debug("Got HomeTable");
        return(jT);
    end;
end;





-- Functions for weather information.
-- @section weatherinfo

--- A function that lets you access the outside temperature reported by the remote weather service set up for the Home Center 2.
-- @return The function returns the temperature as a number. If the function could not find a temperature value due to some error in the service, a 'nil' value is returned.



function getOutSideTemperature()
	local function isEmpty(s)
  		return s == nil or s == '';
	end;
	temp = tonumber(fibaro:getValue(3, "Temperature"));
	if(isEmpty(temp)) then
		return(nil);
	end;
	return(temp);
end;

--- A function that lets you access the outside humidity reported by the remote weather service set up for the Home Center 2.
-- @return The function returns the temperature as a number. If the function could not find a temperature value due to some error in the service, a 'nil' value is returned.

function getOutSideHumidity()
	local function isEmpty(s)
  		return s == nil or s == '';
	end;
	temp = tonumber(fibaro:getValue(3, "Temperature"));
	if(isEmpty(temp)) then
		return(nil);
	end;
	return(temp);
end;

--- A function that checks whether weather conditions are "clear".
-- @treturn boolean 'true' if the weather is clear, 'false' if not 

function weatherIsClear()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "clear")
end;

--- A function that checks whether weather conditions are "cloudy".
-- @treturn boolean 'true' if the weather is cloudy, 'false' if not 

function weatherIsCloudy()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "cloudy")
end;

--- A function that checks whether it is currently raining.
-- @treturn boolean 'true' if it is raining, 'false' if not 

function isRainyWeather()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "rainy")
end;


--- A function that checks it is currently snowing.
-- @treturn boolean 'true' if it is snowing, 'false' if not 

function isSnowing()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "snow")
end;


--- A function that checks whether there is a storm outside.
-- @treturn boolean 'true' if a storm is reported, 'false' if not 

function isStorming()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "storm")
end;


--- A function that checks whether there is a fog outside.
-- @treturn boolean 'true' if a fog is reported by the weather service, 'false' if not 

function isFog()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "fog")
end;