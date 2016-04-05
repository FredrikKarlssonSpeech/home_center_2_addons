--- A module joining together a group of functions that makes testing for and handling of source triggers more managable.
-- The design of the functions allow for them to be called in a context where one would like to know if
-- what caused the scene to trigger (i.e. in the context of an conditions testing of an if-statement ).
-- If called outside of a context where truth value is not evaluated, then you may get more detailed
-- on the trigger.
--
-- Since all values that are not 'false' or 'nil' are evaluated at true, this works.



--- A function that tests whether the scene was started manually
-- @treturn boolean A truth value (true /false)

function startedManually ()
    local startSource = fibaro:getSourceTrigger();
    return( startSource["type"] == "other")
end

--- A function that tests whether the scene was started by a change in a global variable
-- @treturn string If started by a global variable, the name of the variable is returned.
-- @treturn boolean If started by something else, 'false' is returned.

function startedByVariable ()
    local startSource = fibaro:getSourceTrigger();
    if startSource["type"] == "global" then
        return (startSource["name"])
    else
        return false
    end
end

--- A function that tests whether the scene was started by a change in the state or property of a device.
-- @treturn table A table containting two fields:
--  'deviceID', indicating the ID of the triggering device
--  'propertyName' the property of the device that changed, causing the scene to trigger.
-- @treturn boolean A truth value (true /false).
function startedByDevice ()
    local startSource = fibaro:getSourceTrigger();
    -- startSource ={type="property",deviceID="11",propertyName="tet"}
    if startSource["type"] == "property" then
        return ({deviceID=startSource["deviceID"], propertyName=startSource["propertyName"]})
    else
        return false
    end
end

--- A function that tests whether the scene is currently running.
-- Please note that the testing is stated in the negative. What is tested is whether the scene is NOT
-- running, as this is the most probable use case.
-- @treturn boolean A truth value (true /false).


function notCurrentlyRunning()
    local sceneCount = fibaro:countScenes();
    return (sceneCount == 1);
end


--- A table of mappings between NodOn remote scene codes and a text description.
nodonSceneTableVerbose = {
    [10]="Button 1 Single Press",   -- Button 1 Single Press
    [20]="Button 2 Single Press",   -- Button 2 Single Press
    [30]="Button 3 Single Press",   -- Button 3 Single Press
    [40]="Button 4 Single Press",   -- Button 4 Single Press
    [13]="Button 1 Double Press",   -- Button 1 Double Press
    [23]="Button 2 Double Press",   -- Button 2 Double Press
    [33]="Button 3 Double Press",   -- Button 3 Double Press
    [43]="Button 4 Double Press",   -- Button 4 Double Press
    [12]="Button 1 Hold Press",     -- Button 1 Hold Press
    [22]="Button 2 Hold Press",     -- Button 2 Hold Press
    [32]="Button 3 Hold Press",     -- Button 3 Hold Press
    [42]="Button 4 Hold Press",     -- Button 4 Hold Press
    [11]="Button 1 Hold Released",  -- Button 1 Hold Released
    [21]="Button 2 Hold Released",  -- Button 2 Hold Released
    [31]="Button 3 Hold Released",  -- Button 3 Hold Released
    [41]="Button 4 Hold Released"   -- Button 4 Hold Released
}

--- Compressed table for mappings between scene codes and NodOn button pressed, and manner in which it was pressed.
-- In the short forms stored, the 'SP' indicates a single press, 'DP' a double press. 'HP' indicates that the button is pressed and held, and 'HR' that it is released.
nodonSceneTable = {
    [10]="1SP",  -- Button 1 Single Press
    [20]="2SP",  -- Button 2 Single Press
    [30]="3SP",  -- Button 3 Single Press
    [40]="4SP",  -- Button 4 Single Press
    [13]="1DP",  -- Button 1 Double Press
    [23]="2DP",  -- Button 2 Double Press
    [33]="3DP",  -- Button 3 Double Press
    [43]="4DP",  -- Button 4 Double Press
    [12]="1HP",  -- Button 1 Hold Press
    [22]="2HP",  -- Button 2 Hold Press
    [32]="3HP",  -- Button 3 Hold Press
    [42]="4HP",  -- Button 4 Hold Press
    [11]="1HR",  -- Button 1 Hold Released
    [21]="2HR",  -- Button 2 Hold Released
    [31]="3HR",  -- Button 3 Hold Released
    [41]="4HR"   -- Button 4 Hold Released
}

--- A table for Zwave.me wall controller (actually keyfob) scene codes.
zwavemeSceneTableVerbose = {
    [11]="Button 1 Single Click",   -- Button 1 Single Click
    [21]="Button 2 Single Click",   -- Button 2 Single Click
    [31]="Button 3 Single Click",   -- Button 3 Single Click
    [41]="Button 4 Single Click",   -- Button 4 Single Click
    [12]="Button 1 Double Click",   -- Button 1 Double Click
    [22]="Button 2 Double Click",   -- Button 2 Double Click
    [32]="Button 3 Double Click",   -- Button 3 Double Click
    [42]="Button 4 Double Click",   -- Button 4 Double Press
    [13]="Button 1 Press and hold", -- Button 1 Press and hold
    [23]="Button 2 Press and hold", -- Button 2 Press and hold
    [33]="Button 3 Press and hold", -- Button 3 Press and hold
    [43]="Button 4 Press and hold", -- Button 4 Press and hold
    [14]="Button 1 Click and then Press and hold", -- Button 1 Click and then Press and hold
    [24]="Button 2 Click and then Press and hold",     -- Button 2 Click and then Press and hold
    [34]="Button 3 Click and then Press and hold",     -- Button 3 Click and then Press and hold
    [44]="Button 4 Click and then Press and hold",     -- Button 4 Click and then Press and hold
    [15]="Button 1 Press and hold long time",          -- Button 1 Press and hold long time
    [25]="Button 2 Click and then Press and hold",     -- Button 2 Press and hold long time
    [35]="Button 3 Click and then Press and hold",     -- Button 3 Press and hold long time
    [45]="Button 4 Click and then Press and hold",     -- Button 4 Press and hold long time
    [16]="Button 1 Click and then Press and hold long time",     -- Button 1 Click and then Press and hold long time
    [26]="Button 2 Click and then Press and hold long time",     -- Button 2 Click and then Press and hold long time
    [36]="Button 3 Click and then Press and hold long time",     -- Button 3 Click and then Press and hold long time
    [46]="Button 4 Click and then Press and hold long time",     -- Button 4 Click and then Press and hold long time
}

--- Compressed table for mappings between scene codes and Zwave.me button pressed, and manner in which it was pressed.
-- In the short forms stored, the 'SC' indicates a single click, 'DC' a double click. 'PH' indicates that the button is pressed and held. In cases when two actions are performed, like in the case of a click followed by a press that is held, then the two actions are separated by a '_' in the code.
zwavemeSceneTable = {
    [11]="1SC",   -- Button 1 Single Click
    [21]="2SC",   -- Button 2 Single Click
    [31]="3SC",   -- Button 3 Single Click
    [41]="4SC",   -- Button 4 Single Click
    [12]="1DC",   -- Button 1 Double Click
    [22]="2DC",   -- Button 2 Double Click
    [32]="3DC",   -- Button 3 Double Click
    [42]="4DC",   -- Button 4 Double Press
    [13]="1PH",   -- Button 1 Press and hold
    [23]="2PH",   -- Button 2 Press and hold
    [33]="3PH",   -- Button 3 Press and hold
    [43]="4PH",   -- Button 4 Press and hold
    [14]="1C_PH", -- Button 1 Click and then Press and hold
    [24]="2C_PH", -- Button 2 Click and then Press and hold
    [34]="3C_PH", -- Button 3 Click and then Press and hold
    [44]="4C_PH", -- Button 4 Click and then Press and hold
    [15]="1PLH",  -- Button 1 Press and hold long time
    [25]="2PLH",  -- Button 2 Press and hold long time
    [35]="3PLH",  -- Button 3 Press and hold long time
    [45]="4PLH",  -- Button 4 Press and hold long time
    [16]="1C_PLH",-- Button 1 Click and then Press and hold long time
    [26]="1C_PLH",-- Button 2 Click and then Press and hold long time
    [36]="1C_PLH",-- Button 3 Click and then Press and hold long time
    [46]="1C_PLH"-- Button 4 Click and then Press and hold long time
}




