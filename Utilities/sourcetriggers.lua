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