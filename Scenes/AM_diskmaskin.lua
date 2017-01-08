--[[
%% properties
279 power
%% globals
--]]

--[[
-----------------------------------------------------------------------------
-- APPLIANCE MONITORING SCENE -- HERE PUT NAME OF APPLIANCE
-----------------------------------------------------------------------------
Copyright © 2016 Zoran Sankovic - Sankotronic. All Rights Reserved.
Version 1.0

-- VERSION HISTORY ----------------------------------------------------------
1.0 - Completely rewritten scene so can be used to monitor any appliance in
      the home or workplace. 

-- COPYRIGHT NOTICE ---------------------------------------------------------
Redistribution and use of this source code, with or without modification, 
is permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. The name of the author may not be used to endorse or promote products 
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY  COPYRIGHT OWNER  "AS IS"  AND ANY  EXPRESS  OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
MERCHANTABILITY  AND FITNESS FOR A  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT  SHALL THE AUTHOR  BE  LIABLE  FOR ANY  DIRECT,  INDIRECT, INCIDENTAL, 
SPECIAL,  EXEMPLARY,  OR CONSEQUENTIAL  DAMAGES  (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT  OF SUBSTITUTE  GOODS OR  SERVICES;  LOSS OF USE,  DATA,  OR 
PROFITS;  OR BUSINESS INTERRUPTION)  HOWEVER  CAUSED  AND  ON  ANY THEORY OF 
LIABILITY,  WHETHER  IN  CONTRACT,  STRICT  LIABILITY,  OR  TORT  (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- SCENE DESCRIPTION --------------------------------------------------------
This scene can monitor any appliance for power consumption and send push
and/or popup notification when appliance start working and/or when it is
finished. You can also select to switch it off when is done or leave it
under power. Bellow you will find part of code for you to setup for
particular appliance and behavior of this scene.

-- LIST OF GLOBAL VARIABLES NEEDED ------------------------------------------
"HomeTable"       - predefined global variable table with device and scene IDs.
                    Recommended to use since z-wave devices can change their
                    ID with re-inclusion and then is necessary to edit only 
                    scene which make this table and only device ID in scene
                    headers. Much less time and effort is needed than without
                    that option!
"applianceStatus" - make predefined global variable with two possible
                    values "On" and "Off". Values can be in your language
                    just map them to values used in this scene. name of
                    global variable is up to you. For example to monitor
                    washing machine you can make global variable named
                    "WashigMachine" adn put that name for applianceStatus
--]]

-- Making sure that only one instance of the scene is running. This is working
-- in 99,99% of the time with Max. running instances set to 4 or more. There
-- are very rare occasions when in very small split of second one instance
-- still didn't stop but another already kick in and then giving warning 
-- notification if Max. running instances is set to 2 or less.
-- There is no other influence to this scene except that annoying warnings in
-- notification area but scene will continue to work properly. Of course you
-- need to leave this code bellow as it is.
if (fibaro:countScenes() > 1) then
  fibaro:abort();
end
    
-- PART OF CODE FOR USERS TO EDIT AND SETUP ---------------------------------

-- GLOBAL VARIABLES ---------------------------------------------------------
-- enter names and value mapping of your global variables or leave as it is
-- and add to variables panel
-- get the table from global if not using then delete this line!!!
-- local jT = json.decode(fibaro:getGlobalValue("HomeTable"));
-- enter name of your global variable for monitoring state of appliance and
-- map your values for "On" and "Off"
local applianceStatus        = "Tvättmaskinen";
local applianceStatusMapping = {On="Igång", Off="Inte igång"};

-- EXTRA GLOBAL VARIABLES ---------------------------------------------------
-- here you can add your extra global variables to enhance features of this
-- scene:

-- APPLIANCE CONTROL DEVICE SETUP -------------------------------------------
-- enter device ID which is used to control appliance and measure power
-- consumption. Don't forget to put this ID in scene header under
-- %% properties
-- 100 power
local deviceID           = 279;
-- enter minimum power in Watt bellow which appliance is stopped or in
-- standby mode
local deviceMinPower     = 3.5;
-- enter time in minutes after which scene will send message that appliance
-- is done and stopped. This time delay is necessary for many modern washing
-- machines due to electronic drive controls
local deviceStopDuration = 10;
-- enter here "Yes" if you want to switch off appliance when is done and
-- stopped or "No" if you want to leave it on
local deviceTurnOff      = "No";

-- USERS, PUSH AND POPUP NOTIFICATION SETUP ---------------------------------
-- define users to send push messages
local userID   = {2, 74};
-- flag for each user; if 1 then send notifications else if 0 do not
-- send notifications. You can add code in function extraUserCodeFirst()
-- where you can change user flags depending on some global variable.
local userFlag = {1, 1};

-- PUSH MESSAGES SETUP ------------------------------------------------------
-- enter push message text for the appliance start and stop event
local pushMessage = {start = "Tvättmaskinen har startat",
                     stop  = "Tvättmaskinen har avslutat sitt program"};
-- enter "Yes" if you want to receive push notification that appliance
-- started working else put "No"
local pushStart = "No";
-- enter "Yes" if you want to receive push notification that appliance
-- finished working else put "No"
local pushStop  = "Yes";

-- POPUP MESSAGES SETUP -----------------------------------------------------
-- enter popup message text and button caption for the appliance start and 
-- stop
local popupMainTitle         = "Tvättmaskinen";
local popupTimeFormat        = "%H:%M:%S | %Y-%m-%d";
local popupContentTitleStart = "Tvättmaskinen har startat";
local popupContentTitleStop  = "Tvättmaskinen har avslutat sitt program";
local popupContentBodyStart  = "Tvättmaskinen har påbörjat ett program";
local popupContentBodyOn     = "Tvättmaskinen har inte slagits av.";
local popupContentBodyOff    = "Tvättmaskinen har avslutat sitt program";
local popupImgUrl            = "";
local popupButtonCaption     = "OK";
-- enter "Yes" if you want to receive popup notification that appliance
-- started working else put "No"
local popupStart = "No";
-- enter "Yes" if you want to receive popup notification that appliance
-- finished working else put "No"
local popupStop  = "Yes";

-- DEBUGGING VARIABLES -----------------------------------------------------
-- setup debugging, true is turned on, false turned off.
local deBug        = true;  -- for showing events as they happen
local exDebug      = false; -- for checking loop counter

-- EXTRA FUNCTION WHERE YOU CAN ADD YOUR CODE ----------------------------
-- use this function to add code that will be executed before loop is
-- started and push adn popup notifications are sent
function extraUserCodeFirst()
  -- your code goes here
  
  if deBug then logbug("yellow", "User extra code before loop executed") end;
end

-- use this function to add code that will be executed after loop is
-- finished and before sending push and popup notifications
function extraUserCodeLast()
  -- your code goes here

  if deBug then logbug("yellow", "User extra code after loop executed") end;
end
-- END OF CODE PART FOR USERS TO EDIT AND SETUP -----------------------------

-- BELLOW CODE NO NEED TO MODIFY BY USER ------------------------------------
-- except if you know what you're doin' :-P

local StartSource = fibaro:getSourceTrigger()
local countdown   = 0;
local version     = "1.0";

function logbug(color, message)
  fibaro:debug(string.format('<%s style="color:%s;">%s</%s>', "span", color, message, "span")); 
end

-- send push notification
function sendPush(message)
  if (#userID == #userFlag) then
    if #userID > 0 then
      for i = 1, #userID do
        if userFlag[i] == 1 then
          fibaro:call(userID[i], "sendPush", message); -- Send message to flagged users
          if deBug then logbug("orange", "Push notification sent to user "..fibaro:getName(userID[i])) end;
        end
      end
    end
  else
    if deBug then logbug("red", "User and flag count is different, not setup correctly. Please check") end;
  end
end

-- send popup notification
function sendPopup(i)
  if i == 1 then
    popupContentTitle = popupContentTitleStart;
    popupContentBody  = popupContentBodyStart;
    popupTypeInfo     = "Info";
    if deBug then logbug("orange", "Popup notification sent: appliance started") end;
  else
    popupContentTitle = popupContentTitleStop;
    if deviceTurnOff == "Yes" then
      popupContentBody = popupContentBodyOff
      if deBug then logbug("Yellow", "Appliance is switched off") end;
    else
      popupContentBody = popupContentBodyOn
    end
    popupTypeInfo     = "Success";
    if deBug then logbug("orange", "Popup notification sent: appliance stopped") end;
  end
  -------------------------------------------
  HomeCenter.PopupService.publish({
      -- title (required)
      title = popupMainTitle,
      -- subtitle(optional), e.g. time and date of the pop-up call
      subtitle = os.date(popupTimeFormat),
      -- content header (optional)
      contentTitle = popupContentTitle,
      -- content (required)
      contentBody = popupContentBody,
      -- notification image (assigned from the variable)
      img = popupImgUrl,
      -- type of the pop-up
      type = popupTypeInfo,
      -- buttons definition
      buttons = { { caption = popupButtonCaption, sceneId = 0 } }
    })
  ---------------------------------------------
end

if ((tonumber(fibaro:getValue(deviceID, 'power')) > deviceMinPower) and (StartSource['type'] == "property")) then    
  logbug ("green", "Appliance monitoring scene started version "..version.." - © 2016 Sankotronic");
  fibaro:setGlobal(applianceStatus, applianceStatusMapping.On);
  extraUserCodeFirst();
  if pushStart  == "Yes" then sendPush(pushMessage.start) end;
  if popupStart == "Yes" then sendPopup (1) end;
  while true do
    local power = tonumber(fibaro:getValue(deviceID, 'power'));
    -- if power is greater than minimum then reset countdown
    if (power > deviceMinPower) then
      countdown = deviceStopDuration;
    else
      if (countdown > 0) then countdown = countdown - 1 end;
    end
    -- if countdown is ended then send notification and turn off
    if (countdown == 0) then
      if fibaro:getGlobalValue(applianceStatus) == applianceStatusMapping.On then
        fibaro:setGlobal(applianceStatus, applianceStatusMapping.Off);
        extraUserCodeLast();
        if pushStop      == "Yes" then sendPush(pushMessage.stop) end;
        if popupStop     == "Yes" then sendPopup (2) end;
        if deviceTurnOff == "Yes" then fibaro:call(deviceID, "turnOff") end;
      end
      logbug ("green", "Appliance monitoring scene Ended");
      -- Kill running scene cause it is done with appliance
      fibaro:abort();
    end
    if deBug then logbug("lightgreen", "Power: " .. power .. "W, Countdown: " .. countdown .. " Min.") end;
    fibaro:sleep(60000);
  end
else
  logbug ("lightgreen", "Appliance monitoring scene started manually and will stop.");
  -- Kill running scene cause it is done with appliance
  fibaro:abort();
end
