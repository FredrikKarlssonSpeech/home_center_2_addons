--[[
%% properties
477 value
480 value
491 value
%% globals
TimeOfDay
PresentState
--]]

--[[ Change - XXX value - above. One for motion sensor, one for Light sensor.
     TimeOfDay global variable and lux make sure that the scene
     will be triggered when you are already in the room and something changes.

     Set your settings below, lights and add extra functions
     Feel free to suggest changes or contact when having problems.
	 It is not allowed to sell or distribute this software and earlier versions without the approval of Control Living
     © 2014 - 2015 Smart lights by Control Living
     Version 1.6.7
--]]

--------------------------------------------------------------------
-----------------------YOUR LIGHT SETTINGS--------------------------

motionSensorID    = {477};  -- change id for your motion sensor.
LuxSensorID       = {480};  -- change id for your light sensor.

--Enter the name of your Global variable. WITHOUT IT, THE SCENE DOES NOT WORK. Capital sensitive!
sleepState   = "SleepState"; --Sleep globalstate variable.
timeOfDay    = "TimeOfDay"; --Time of Day Global variable.
presentState = "PresentState"; --Present state Global variable.

--Enter the values of your global variables stated above. If not using, copy the name in front of the "YourValueName"
sleepStateMapping   = {Sleeping="Sleeping", Awake="Awake"};
timeOfDayMapping    = {Morning="Morning", Day="Day", Evening="Evening", Night="Night"};
presentStateMapping = {Home="Home", Away="Away", Holiday="Holiday"};

-- Set the lux value for which the lights have to be turned on.
-- If you don't want to use the MinLux then just set it to: 65535
minLuxMorning  = 100;
minLuxDay      = 60;
minLuxEvening  = 40;
minLuxNight    = 30;

--If the current lux value is above the maxlux, the lights will turn off after their set onTime.
maxLuxMorning = 300;
maxLuxDay = 300;

--[[
 Now the most important part:
   Here you can enter what light, for how long and at what value has to be turned on.
   Leave empty brackets for no lights.
   To set the light value without timer use 2 parameters: {id=LightID, setValue="VALUE"}
   To set the light value with timer    use 3 parameters: {id=LightID, setValue="VALUE", onTime=timeInSeconds }
   To set the light value for RGBW:  use the above, where setValue is: setValue={R="255",G="255",B="255",W="255"}
   --                                           RGBW set: {id=LightID, setValue={R="255",G="255",B="255",W="255"}, onTime=timeInSeconds }
   --]]
   
lightsSleeping = {}; --lights that are triggered when Sleepstate is sleeping. 
lightsMorning  = {{id=471, setValue="99", onTime=300},{id=491, setValue="99", onTime=300},{id=902, setValue="turnOn", onTime=360}};
lightsDay      = {{id=471, setValue="80", onTime=90},{id=491, setValue="80", onTime=90}};
lightsEvening  = {{id=471, setValue="60", onTime=300},{id=491, setValue="60", onTime=300},{id=902, setValue="turnOn", onTime=300}};
lightsNight    = {{id=471, setValue="45", onTime=60}, {id=491, setValue="45", onTime=60}};

--Manual Override, the time that lights will not be turned ON again after manually turning them off.
OverrideFor  = 90;
dimmDownTime = 10;

--------------------------------------------------------------------
-------------------------EXTRA FEATURES-----------------------------

extraMorningFunc = function()
  -- Add your extra code here. If you want some checks or maybe run a virtual device button.
  --This code is always triggered if there is motion.
  -- movieLights =  {{180, "10"},{181, "10"} };
  --if (xbmc == "playing" ) then CallLightArray(movieLights);
  ExtraDebug("Extra morning function called");
end

extraDayFunc = function()
  -- Add your extra code here. If you want some checks or maybe run a virtual device button. 
  --This code is always triggered if there is motion.
  ExtraDebug("Extra day function called");
end

extraEveningFunc = function()
  -- Add your extra code here. If you want some checks or maybe run a virtual device button.
  --This code is always triggered if there is motion.
  ExtraDebug("Extra evening function called");
end

extraNightFunc = function()
  -- Add your extra code here. If you want some checks or maybe run a virtual device button.
  --This code is always triggered if there is motion.
  ExtraDebug("Extra night function called");
end

extraLightTriggerChecks = function()
--add extra checks here. and return the total true or false value.
--if returning false the lights will not be triggered.
-- for instance:  return ( (pcTurnedOff == true ) and (xbmc ~= "Empty") );
  -- return true to enable lights to turn on
  return true;
end

extraOffChecks = function()
  --return true to keep lights on.
  return false;
end

--------------------------------------------------------------------
----------------------ADVANCES SETTINGS-----------------------------
local showStandardDebugInfo = true; -- Debug shown in white
local showExtraDebugInfo    = false; -- Debug shown in orange

--------------------------------------------------------------------
--------------------------------------------------------------------
--               DO NOT CHANGE THE CODE BELOW                     --
--------------------------------------------------------------------
--UPDATE FROM HERE

--private variables
startSource        = fibaro:getSourceTrigger();
keepLightsOn       = false;
timerRunning       = false;
previousLights     = nil;
version = "1.6.7";

SavedState = {
  homeStatus = "",
  sleepState = 0,
  timeOfDay  = "",
  lux        = 0,
  motion     = 0,
  startTime  = 0
}

CurrentState = {
  homeStatus  = "",
  sleepState  = "",
  timeOfDay   = "",
  lux         = 0,
  motionState = 0,
  currentLightArray = {}
}

RGBWDeviceType = { "com.fibaro.RGBW", "com.fibaro.colorController", "com.fibaro.FGRGBW441M"  }
BinaryDeviceType = { "com.fibaro.binarySwitch","com.fibaro.FGWP101", "turnOn"  }
DimmerDeviceType = { "com.fibaro.multilevelSwitch" }

OffModes = {None, ByScene, ManualOverride }

function Debug( color, message )
  fibaro:debug(string.format('<%s style="color:%s;">%s</%s>', "span", color, message, "span")); 
end

--Making sure that only one instance of the scene is running.
fibaro:sleep(50); --sleep to prevent all instances being killed.
if (fibaro:countScenes() > 1) then
  if (showExtraDebugInfo) then
    Debug( "grey", "Abort, Scene count = " .. fibaro:countScenes());
  end
  fibaro:abort();
end

--------------------------EXECUTION----------------------------------

function SetCurrentStatus()
  ExtraDebug("Updating current variable statuses");
  CurrentState.homeStatus  = GetPresentState();
  CurrentState.timeOfDay   = GetTimeOfDay();
  CurrentState.sleepState  = GetSleepState();
  CurrentState.lux         = GetAverageLuxValue();
  CurrentState.motionState = GetCurrentMotionStatus();
end

function SaveCurrentStatus()
  ExtraDebug("Saving current variable statuses");
  SavedState.homeStatus = CurrentState.homeStatus;
  SavedState.timeOfDay  = CurrentState.timeOfDay;
  SavedState.sleepState = CurrentState.sleepState;
  SavedState.lux        = CurrentState.lux;
  SavedState.motion     = CurrentState.motionState;
end

function CheckStatusChanges()
  ExtraDebug("Status change check");
  if (CurrentState.homeStatus ~= SavedState.homeStatus ) or (CurrentState.timeOfDay ~= SavedState.timeOfDay ) then
    if (CurrentState.homeStatus ~= presentStateMapping.Home ) then
      TurnOffLights();
    else
      SceneTriggered();
	  --reset time.
    end;
  end
  SaveCurrentStatus();
    -- if we still have a motion then reset timer.
  if ( (CurrentState.motionState ~= 0 or extraOffChecks() ) and not IsMaxLuxExceeded() )  then 
	ExtraDebug( "Resetting time" );
    SavedState.startTime = os.time(); 
  else
    ExtraDebug("Timer is not reset.");
  end
  --any other case, we are not resetting the timer.
end

function IsMaxLuxExceeded()
  if (CurrentState.timeOfDay == timeOfDayMapping.Morning and CurrentState.lux > maxLuxMorning ) then
    ExtraDebug( "Current lux value: " .. CurrentState.lux .. " higher then max Lux Morning: " .. maxLuxMorning .. ".");
	return true;
  elseif (CurrentState.timeOfDay == timeOfDayMapping.Day and CurrentState.lux > maxLuxDay ) then
    ExtraDebug( "Current lux value: " .. CurrentState.lux .. " higher then max Lux Day: " .. maxLuxDay .. ".");
	return true;
   end
   return false;
end

function LightsOff( lightArray )
  local stillLightsOn = 0;
  local currentTime = os.time();
  for i = 1,#lightArray do
    if ( lightArray[i].onTime ~= nil) then
	  lightItem = lightArray[i];
	  lightItem.OffMode = CheckManualOverrideItem( lightItem );
	  --local 
	  if ( lightItem.OffMode == "ManualOverride" ) then
	      ExtraDebug("Manual override for light: [" .. lightItem.id .. "]" .. lightItem.name .. " active, not turning on");
		  goto continue;
	  end
	  --On till:
      local timeL = SavedState.startTime + (lightItem.onTime);
	  local timeLeft =  timeL -  currentTime;
 	  if (timeLeft >= 0 ) then ExtraDebug("Time left for: [" .. lightItem.id .. "]" .. lightItem.name .. ": " .. timeLeft .. " seconds" );   end
	  if ( timeLeft < dimmDownTime ) then
        if ( lightItem.OffMode ~= "ManualOverride" ) then
			lightItem.OffMode = "ByScene";
		end
	    if ( (timeLeft <= 0) and (lightItem.currentValue ~= 0) ) then
			fibaro:call(lightItem.id, "turnOff");
			StandardDebug("Switch off light: [" .. lightItem.id .. "]'" .. lightItem.name .."'");
        else
            if ( item.lightType == "com.fibaro.multilevelSwitch" ) then
			  currentValueDiv = roundit(((lightItem.currentValue) / (dimmDownTime)), 0);
			  currentValueNew = (lightItem.currentValue - currentValueDiv);
			  if (currentValueNew <=0 ) then currentValueNew = 0; end
			  fibaro:call(lightItem.id, "setValue", tostring(currentValueNew));
            end
			stillLightsOn = stillLightsOn + 1;
		end
      elseif (CheckLightToBeTurnedOnAgain(lightItem)) then
        ExtraDebug("Turn light: " .. lightItem.id .. " back on");
        turnLightOn(lightItem);
		lightItem.OffMode = "";
        stillLightsOn = stillLightsOn + 1;  
      else
	    lightItem.OffMode = "NoOverride";
	    stillLightsOn = stillLightsOn + 1;   
      end
    end
	::continue::
  end
  return stillLightsOn;
end

function KeepLightsOnTimer()
  ExtraDebug("--------------- Timer running ---------------");
  ExtraDebug("starting with while loop, to keep lights on");
  SavedState.startTime = os.time();
  SaveCurrentStatus();
  sleepTime = 1000;
  while ( keepLightsOn ) do
    ExtraDebug("--------------- next timer run ---------------");
    fibaro:sleep(sleepTime);
	start_time = os.clock();
    SetCurrentStatus();
    currentLightArray = GetTimeOfDayLightArray();
    UpdateLightValues(currentLightArray);
    CheckStatusChanges();
    local stillLightsOn = 0;  
    stillLightsOn = LightsOff( currentLightArray );
    if (stillLightsOn == 0 ) then
	  keepLightsOn = RunManualOverrideMode( currentLightArray );
      end_time = 0; --if lights turned back on after override.
    else
      end_time = os.clock() 
    end
	elapsed_time = (end_time - start_time) * 1000;
	sleepTime = 1000 - elapsed_time;
  end
end

function CheckManualOverrideItem( currentItem ) 
  --ExtraDebug("Manual override check for: [" .. currentItem.id .. "]" .. currentItem.name);
  if (currentItem.currentValue == 0 and currentItem.OffMode ~= "ByScene" ) then
    ExtraDebug( "Manual override for light: [" .. currentItem.id .. "]" .. currentItem.name .. " active" );
	return "ManualOverride";
  elseif (currentItem.currentValue ~= 0 and currentItem.OffMode == "ManualOverride" ) then
	ExtraDebug( "Manual override for light: [" .. currentItem.id .. "]" .. currentItem.name .. " cancelled" );
	return "NoOverride";
  end
  return currentItem.OffMode; --returning current mode;
end

function RunManualOverrideMode( currentLightArray )
  OverrideForAll = CheckIfAllInOverrideMode(currentLightArray);
  if ( OverrideForAll ) then
    ExtraDebug("-----------------Override Mode---------------");
    OverrideTimer = os.time();
    while ( OverrideForAll and (OverrideTimer + OverrideFor ) - os.time() > 0 ) do
      ExtraDebug("Still in override for: " .. (OverrideTimer + OverrideFor ) - os.time() .. " seconds" );
      fibaro:sleep(1000);
	  UpdateLightValues(currentLightArray);
	  OverrideForAll = CheckIfAllInOverrideMode(currentLightArray);
	  motion = GetCurrentMotionStatus();
	  if ( motion ~= 0 ) then
	    OverrideTimer = os.time();
	  end
    end
	else return false;
  end
 -- if  ( (OverrideTimer + OverrideFor ) - os.time() <= 0 ) then
  --time has end. So not continue to run lights loop 
 --   return false;
 -- end
  if (OverrideForAll) then
    return false; --run lights 
  else return true;
  end
end

function CheckIfAllInOverrideMode(currentLightArray)
  OverrideForAll = 0;
  for i = 1,#currentLightArray do
    if ( CheckManualOverrideItem(currentLightArray[i]) == "ManualOverride" ) then
      OverrideForAll = OverrideForAll +1;
    else
      return false;
    end
  end
  if (  OverrideForAll ~= 0 and OverrideForAll == #currentLightArray ) then
    return true;
  end
  return false;
end

function RunTimer()
if ( keepLightsOn and not timerRunning ) then
    ExtraDebug("Starting timer, not yet running");
    timerRunning = true;
    KeepLightsOnTimer();
  else
	ExtraDebug("Timer already running, returning");
  end
end

function TurnOffLights()
     local timeOfDayArray = GetTimeOfDayLightArray();
     SetLightValues(timeOfDayArray);
	 UpdateLightValues(timeOfDayArray);
     CallLightArray(timeOfDayArray, "off" );
	return;
end

----------------------Turn lights on functions------------------------

function CallLightArray( lightArray, turnOnOrOff )
  if (#lightArray == 0 ) then
    if (CurrentState.sleepState == sleepStateMapping.Sleeping) then
	  noLightsSetText = "lightsSleeping";
	else
      noLightsSetText = CurrentState.timeOfDay;
	end
    StandardDebug( "No lights set for " .. noLightsSetText );
    return;
  end
  if not ( CheckIfTable(lightArray, "lights" .. CurrentState.timeOfDay ) ) then return end
  for i = 1,#lightArray do
    if not ( CheckIfTable(lightArray[i], "lights" .. CurrentState.timeOfDay ) ) then break end
    lightItem = lightArray[i];
    if (turnOnOrOff == "on" ) then
      turnLightOn(lightItem);
      if (lightItem.onTime ~= nil) then keepLightsOn = true; end
    else
	  fibaro:call(lightItem.id, "turnOff"); --Always turn off, if HC2 light status is not actual.  
      if ( lightItem.currentValue ~= 0) then
        keepLightsOn = false;
        StandardDebug("Switch off light: [" .. lightItem.id .. "]'" .. lightItem.name .."'");
      end
    end
  end
  StandardDebug( "Lights turned: " .. turnOnOrOff .. " for " .. CurrentState.timeOfDay );
end

function turnLightOn( lightItem )
  if (lightItem.lightType == "com.fibaro.multilevelSwitch" ) then
    fibaro:call(lightItem.id, "setValue", tostring(lightItem.setValue));
    StandardDebug( "Set: [" .. lightItem.id .. "]'" .. lightItem.name .. "' to Value: " .. lightItem.setValue );
  elseif ( lightItem.lightType == "com.fibaro.RGBW" )then
    StandardDebug( "Turn: [" .. lightItem.id .. "]'" .. lightItem.name .. "' On"); 
    if ( lightItem.setValue.brg~= nil ) then
      fibaro:call(lightItem.id, "setBrightness", tostring(lightItem.setValue.brg));
    else
	  local clrvalues =lightItem.setValue;
      fibaro:call(lightItem.id, "setColor", clrvalues.R,  clrvalues.G,  clrvalues.B,  clrvalues.W)	
    end
  elseif (lightItem.lightType == "com.fibaro.binarySwitch") then
    fibaro:call(lightItem.id, "turnOn");
	StandardDebug( "Turn: [" .. lightItem.id .. "]'" .. lightItem.name .. "' On"); 
  end
end

function CheckPreviousLights( NewLightArray )
  if ( previousLights ~= nil ) then
    for i = 1,#previousLights do
      local lightItem = previousLights[i];
      for i = 1,#NewLightArray do
        local lightItem1 = NewLightArray[i];
        inarray = false;
        if ( lightItem.id == lightItem1.id ) then
          inarray= true;
          break 
        end
      end
      if not ( inarray ) then fibaro:call(lightItem.id, "turnOff"); end
    end
  end
  previousLights = NewLightArray;	
end

function LightperDayPart( minLux, lightArray )
  local newLuxValue = CurrentState.lux;
  if ( extraLightTriggerChecks() ) then
    if ( newLuxValue  >  minLux )  then
      StandardDebug( "Sensor lux: " .. newLuxValue .. " higher then minValue: " .. minLux .. " : no action");
    else
      StandardDebug("Sensor lux: " .. newLuxValue .. " is lower then minValue: " .. minLux);
	  SetLightValues(lightArray);
	  CallLightArray( lightArray, "on" );
	  CheckPreviousLights( lightArray );
    end
  else
    ExtraDebug("ExtraLightTriggerChecks failed, so no lights");
  end
end

function SceneTriggered()
  if ( CurrentState.homeStatus ~= presentStateMapping.Home ) then
	ExtraDebug("Presentstate = not at home, so no lights");
  elseif  ( CurrentState.sleepState == sleepStateMapping.Sleeping ) then
    LightperDayPart( 65535, lightsSleeping );	
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Morning ) then
    extraMorningFunc();
    LightperDayPart( minLuxMorning, lightsMorning );
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Day ) then
    extraDayFunc();
	LightperDayPart( minLuxDay, lightsDay );
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Evening ) then
    extraEveningFunc();
    LightperDayPart( minLuxEvening, lightsEvening );
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Night  ) then
    extraNightFunc();
    LightperDayPart( minLuxNight, lightsNight );
  else
	ErrorDebug( "No lights: " .. CurrentState.timeOfDay );
  end
  if (keepLightsOn == true) then
    RunTimer(); 
  end
end

function SceneTriggeredByLights( st )
  if (st == "off") then
    ExtraDebug( "light turned off, sleep 4 sec" );
    fibaro:sleep(4000);
  elseif (st == "on") then
    ExtraDebug( "light turned on, activating timer" );
	fibaro:sleep(4000);
	--TODO: add light to current array. 
	--keepLightsOn = true;
	--RunTimer();
	end
end

------------------------STATUS functions------------------------------

function GetTimeOfDay()
  return LookupGlobal( timeOfDay, "TimeOfDay", "Day");
end

function GetSleepState()
  return LookupGlobal( sleepState, "sleepState", "Awake");
end

function GetPresentState()
  return LookupGlobal( presentState, "presentState", "Home");
end

function LookupGlobal( name, stateName, default )
  local ps = fibaro:getGlobalValue( name );
  if ( (ps ~= "") and (ps ~= nil ) ) then
    ExtraDebug("returned " .. stateName .. ": " .. ps );
    return ps;
  else 
    ErrorDebug( stateName .. " variable not found");
    return default;
  end
end

function lightsStatus( id )
  --check if lights are already on.
  allLights = {lightsSleeping, lightsMorning, lightsDay, lightsEvening, lightsNight };
  for i = 1,#allLights do
    for iL = 1, #allLights[i] do 
	  local lightItem =  allLights[i][iL];
      if ( lightItem.id == tonumber(id) ) then
        if   ( lightItem.currentValue == 0 ) then
          return "off";
        else
          return "on";
        end 
      end
    end
  end
  ErrorDebug("Light status unknown");
  return "Unknown";  
end

function GetTimeOfDayLightArray()
 if ( CurrentState.sleepState == sleepStateMapping.Sleeping ) then
    return lightsSleeping;
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Morning ) then
    return lightsMorning;
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Day ) then
	return lightsDay;
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Evening ) then
	return lightsEvening;
  elseif ( CurrentState.timeOfDay == timeOfDayMapping.Night ) then
	return lightsNight;
  end
end

function GetCurrentMotionStatus()
  local sensorbreached = 0;
  if (CheckIfTable(motionSensorID, "motionSensorID") ) then
    for i = 1,#motionSensorID do
      if ( tonumber(fibaro:getValue(motionSensorID[i], "value")) > 0 ) then
        sensorbreached = 1;
      end
    end
   else 
    --if not a table, just return the value of the containing ID
	sensorbreached = tonumber(fibaro:getValue(motionSensorID, "value"))
  end
  return sensorbreached;
end

function GetAverageLuxValue()
  local luxAverage = 0;
  if (CheckIfTable(LuxSensorID, "LuxSensorID") ) then
    if (#LuxSensorID == 1) then 
      return tonumber(fibaro:getValue(LuxSensorID[1], "value"));
    end
    for i = 1,#LuxSensorID do 
      luxAverage = luxAverage + tonumber(fibaro:getValue(LuxSensorID[i], "value"));
    end
      luxAverage = roundit( (luxAverage / #LuxSensorID), 0 );
  else 
    --if not a table, just return the value of the containing ID
    luxAverage = tonumber(fibaro:getValue(LuxSensorID, "value"));
  end
  return luxAverage;
end

function UpdateLightValues( currentArray )
  for i = 1,#currentArray do
    item = currentArray[i];
	newValue = fibaro:getValue(item.id, "value");
	item.currentValue = tonumber(newValue) ~= nil and tonumber(newValue) or ( newValue == "true" and 1 or 0 );
    if ( item.lightType == "com.fibaro.RGBW" )then
         color = fibaro:getValue(item.id, "color");
         c = {R="0", G="0", B="0", W="0", brg="0" }
         c.R, c.G, c.B, c.W = color:match("([^,]+),([^,]+),([^,]+),([^,]+)");
         c.brg = fibaro:getValue(item.id, "brightness"); 
         item.currentValue = c;
       end
  end
end

function SetLightValues(currentArray)
  for i = 1,#currentArray do
    item = currentArray[i];
    item.name = tostring(fibaro:getName(item.id));
	item.OffMode = "NoOverride";
	if (item.name == nil) then item.name = "Unknown"; end
    item.lightType = GetDeviceType( item.id );
  end
end

function GetDeviceType(itemId)
  deviceType = fibaro:getType(item.id);
  if ( idIsInList(deviceType, RGBWDeviceType) ) then
      deviceType ="com.fibaro.RGBW";
  elseif ( idIsInList(deviceType, BinaryDeviceType) ) then
       deviceType = "com.fibaro.binarySwitch";
  elseif ( idIsInList(deviceType, DimmerDeviceType ) ) then
       deviceType = "com.fibaro.multilevelSwitch";
 --elseif( ) then
 --deviceType = "Philips.Hue";
  end
    return deviceType;
end

--------------------Helper functions--------------------------------

function CheckLightToBeTurnedOnAgain(lightItem)
 if not (lightItem.OffMode=="ByScene") then return; end
 	   
 if (lightItem.lightType == "com.fibaro.multilevelSwitch" ) then
   if (lightItem.currentValue) < tonumber(lightItem.setValue) then return true; end
 elseif( lightItem.lightType == "com.fibaro.RGBW" )then
   c = lightItem.currentValue;
   if (c.R == "0" and c.G == "0" and c.B == "0" and c.W == "0" ) then
     return true;
   end    
 elseif (lightItem.lightType == "com.fibaro.binarySwitch") then
   if (lightItem.setValue == "turnOn" and lightItem.currentValue == 0 ) then return true; end
  end
  return false;
end

function CheckIfTable( array, arrayname )
  local tableCheck = tostring( type( array ) ); 
  if ( tableCheck ~= "table" ) then
    ErrorDebug("Missing brackets for variable: '" .. arrayname .. "', please place extra brackts: { } around: " .. array .. "."); 
	return false;
  end
  return true;
end

function roundit(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function idIsInList( startSourceId, sensorList )
  for i = 1,#sensorList do
    if ( startSourceId == sensorList[i] ) then
      return true;
    end
  end
  return false;
end

--------------------Debugging Functions-----------------------------

function StandardDebug( debugMessage )
  if ( showStandardDebugInfo ) then
    Debug( "white", debugMessage);   
  end
end

function ExtraDebug( debugMessage )
  if ( showExtraDebugInfo ) then
    Debug( "orange", debugMessage);
  end
end

function ErrorDebug( debugMessage )
    Debug( "red", "Error: " .. debugMessage);
    Debug( "red", "");
end

function TestDebug(debugMessage )
   Debug( "blue", "Testing: " .. debugMessage );
end

----------------------START OF THE SCENE----------------------------
SetCurrentStatus();
StandardDebug("Home status: " .. CurrentState.homeStatus );
StandardDebug("Motion status: " .. ( CurrentState.motionState == 0 and "No movement" or "movement")); 
  
if (startSource["type"] == "property") then
  startSourceID = tonumber(startSource['deviceID']);
  triggerDebug  = "Triggered by: " .. startSourceID;
  if ( idIsInList( startSourceID, motionSensorID ) ) then
    StandardDebug( triggerDebug .. " Motion sensor" );
    if ( CurrentState.motionState > 0 ) then
      SceneTriggered();
    end
  elseif ( idIsInList( startSourceID, LuxSensorID ) ) then
    StandardDebug( triggerDebug .. " Lux sensor" );
    ExtraDebug( "Lux value changed to: " .. CurrentState.lux );
    if ( CurrentState.motionState > 0 ) then
      SceneTriggered();
    end
  else
    StandardDebug( triggerDebug .. " Light switch" );
    st = lightsStatus( startSourceID );
    if (st == "Unknown") then
      ErrorDebug( "Unknown light trigger" );
	else
	  SceneTriggeredByLights( st );
	end
    -- Maybe we can change the light preset to make it more intelligent.
    -- Maybe we can change the Lux preset to make it more intelligent.
  end
elseif ( startSource["type"] == "global" ) then
  StandardDebug( "Triggered by: " .. "global variable" );
  -- If home status away, we trigger so the current array will be turned off. If motion, turn them on.
  if (CurrentState.homeStatus ~= presentStateMapping.Home) then
    TurnOffLights();
  elseif (CurrentState.motionState > 0 ) then
    SceneTriggered();
  end
else 
  StandardDebug( "Triggered by: " .. startSource["type"] .. " , Not checking the motion state." );
  --Just run the Light Code, not checking for motion. Probably triggered manually.
  if ( startSource["type"] == "other" ) then
    SceneTriggered();
  end
end

Debug( "green", "© Smart Lights V" .. version .. " | by Control Living, Finished" );
Debug( "green", "-------------------------------------------------------" );
--fibaro:abort(); --otherwise scene will stay alive to long.

--UPDATE TILL HERE