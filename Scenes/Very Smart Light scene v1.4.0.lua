--[[
%% properties


%% globals
SleepState
PresentState
TimeOfDay

--]]

--[[
-----------------------------------------------------------------------------
-- VERY SMART LIGHT SCENE -- Put here name of the room
-----------------------------------------------------------------------------
Copyright (c) 2016 Zoran Sankovic - Sankotronic. All Rights Reserved.
Version 1.4.0

-- VERSION HISTORY ----------------------------------------------------------
1.4.0 - Darkness is not used anymore for turning On lights and dim low levels.
        Only TimeOfDay is now used for that purpose. Added support for 
        different types of Philips HUE light VD. Scene now supports HUE
        color ambience, HUE white ambience and HUE white dimmable only bulbs
        and VDs. Also added support for customized HUE VD. Support for HUE
        plugin remain same. It is possible to mix different types of HUE VD
        since now you have to define VD type for each HUE light. Added two
        new global variables for Cooking and for Mealtime that can be used
        to define different brightness levels and to keep lights On as long
        as this variables are set to Yes. Corrected dimming of RGBW lights
        when useRGBWcolor is set to Yes. Corrected duration timer compensation
        with PIRwindowTime. Now is properly calculated and warning displayed
        if duration setting is lower than PIRwindowTime. Now lights will 
        always turn on for the duration of motion sensor breach time. Corrected
        scene behaviour when PresentState and SleepState are changed. When
        PresentState is changed to Home or Holiday scene will turn on lights
        when motion is detected or dim low if set for that part of day. Same
        is when SleepState change from Sleep to Awake. When PresentState is 
        set to Holiday scene can be controlled by global variable triggers
1.3.5 - corrected that scene turn off switch lights if user set valSWT to 0.
        corrected that scene turn off RGBW lights if program iz running or
        color is enabled if dimRGB is set to 0. Added ProjectorState global
        variable that can be used to additionally setup lighting for movie
        time with projector. So now you can have two different setup to watch
        movies! Don't forget to put CinemaState and ProjectorState to 
        extraGlobalName to keep lights at predefined values!
1.3.4 - resolved bug for keepDimSleep setting that logic was reversed. Now if
        set to true will keep lights dimmed and false will turn them off.
        Rectified situation when scene not turning lights on at all if is not
        using light sensors. Corrected dimOff logic to properly dim or turn
        off lights depending on settings. Cleaned code of some other bugs 
        found during testing.
1.3.3 - resolved bug that was preventing extra timer using jompa68 Alarm
        clock from proper functioning. Extended dimOff function so now lights
        can be dimmed low during all day and also all night regardless of
        SleepState value depending on your settings. Corrected scene behavior
        when sleepName and PresentState global variables value changes and 
        debugging messages
1.3.2 - Added support for latest version of jompa68 Alarm clock 3.0.0.
        Added possibility to define two different dimming levels for Evening
        and Night time if there is no movement in room and lights are set to
        dim instead switch off. Corrected bug for turning on RGBW lights if 
        program and color set to No. Added some basic checking of user
        settings if HolidayLights flag, Brightness and dimOff values are
        missing. Corrected how scene handles ambilight settings. dim and off
        ambilight changed to one setting dimOffAmbilight and it must be set
        to Yes to use settings. keepAmbilight is just setting if you want to
        keep color when motion detected or use defalut colors. Even if you
        do not keep colors while in room they will still revert to color
        when no movement detected.
1.3.1 - corrected usage of dimAmbilight and offAmbilight so that only color
        and saturation is remembered while brightness is set by scene setting
        corrected Alarm clock timer to check if it is turned Off to not keep
        lights on.
1.3   - added ambilight selection so that scene remembers previous status of
        the HUE lamps to dim back when no motion in the room, or even
        leave settings after turning them off. It is also possible to select
        if HUE lamps will raise brightness in ambilight colors or to default
        settings when there is motion in the room. Now every lamp can be set
        to different light level for every used situation like (hoilday lights,
        guests, cinema, etc.) and for every part of the day.
1.2   - added possibility for scene to be triggered by global variables. That
        makes possible to use motion sensors from other systems to control
        this scene through mirroring motion sensors to HC as global variables
1.1   - added support for HUE plugins, added extra timer to turn on devices,
        run scenes or change global variable after predefined time. RGBW module
        programs can now be set differently for each day of the week. Added
        holiday lights control and dim levels. Corrected extra timer which uses
        alarm clock to keep lights correctly at defined time for that day
1.0   - added support for RGBW modules with selection of program to run at
        predefined time of day, extra timer to keep lights on for defined time
0.7   - added extra devices to keep lights on if value is equal to defined
        value. Also added possibility to use more than one montion and light
        sensors.
0.5   - added support for HUE VD and switch (relay) type light controllers
0.1   - basic code able to control lights triggered by motion and light sensor

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
Fully configurable scene to control your lights for HC2! Before usage need to
prepare sensors, lights and other devices ID, configure following global 
variables or check if you already have ones with the same behavior. Since it
is possible to map values for all predefined global variables you can use 
values in your language and just map corresponding values.
-- LIST OF GLOBAL VARIABLES NEEDED ------------------------------------------
"HomeTable"       - predefined global variable table with device and scene IDs.
                    Recommended to use since z-wave devices can change their
                    ID with re-inclusion and then is necessary to edit only 
                    scene which make this table and only device ID in scene
                    headers. Much less time and effort is needed than without
                    that option!
"Darkness"        - global variable, possible values: 
                    0 - Day time, 1 - Night time
"TimeOfDay"       - predefined global variable with values: 
                    "Morning", "Day", "Evening", "Night"
"PresentState"    - predefined global variable with values:
                    "Home", "Away", "Holiday"
"SleepState"      - predefined global variable with values: 
                    "Awake", "Sleep"
"LightState"      - predefined global variable with values "Auto", "Manual"
"IndoorLightsDim" - predefined global variable with values "Yes", "No"
"CinemaState"     - predefined global variable with values "Yes", "No"
"ProjectorState"  - predefined global variable with values "Yes", "No"
"CookingState"    - predefined global variable with values "Yes", "No"
"MealState"       - predefined global variable with values "Yes", "No"
"GuestState"      - predefined global variable with values "Yes", "No"
"SleepXxxxxxx"    - predefined global variables with values "Yes", "No", can
                    have different name for different bedrooms, just replace
                    Xxxxxxx with name of the bedroom eg.sleepMaster, sleepRoom1
                    etc. All you need is to define this global variable, 
                    import VD that will change state and then put name of this
                    variable bellow in code line 157 for local variable
                    sleepingName
"HolidayLights"   - predefined global variable with values "On", "Off" used
                    to change brightness level of controlled lights to more
                    festive level and with ability to temporarily disable
                    control of some lights with this scene
The beauty of this scene is that you don't have to declare new globals if you
already have them, all you have to do is to enter name of your corresponding
global variable and map your values to the ones used by this scene to get it
work properly! For details how to setup this scene please refer to comments
provided bellow.
--]]

-- Making sure that only one instance of the scene is running. This is working
-- in 99,99% of the time with Max. running instances set to 4 or more. There are
-- very rare occasions when in very small split of second one instance still
-- didn't stop but another already kick in and then giving warning notification
-- if Max. running instances is set to 2 or less.
-- There is no other influence to this scene except that annoying warnings in
-- notification area but scene will continue to work properly. Of course you need
-- to leave this code bellow as it is.
if (fibaro:countScenes() > 1) then
  fibaro:abort();
end
    
-- PART OF CODE FOR USERS TO EDIT AND SETUP ---------------------------------

-- GLOBAL VARIABLES ---------------------------------------------------------
-- enter names and value mapping of your global variables or leave as it is
-- and add to variables panel
-- get the table of device & scene ID's from global variable HomeTable. If
-- then uncomment bellow line else leave it as it is!
-- local jT = json.decode(fibaro:getGlobalValue("HomeTable"));

-- "PresentState" is predefined global value that determines if you are at home
-- away or on holidays. This variable value is set by other scene or VD. 
-- Enter name of your global variable between "" or leave as it is
local presentState        = "PresentState";
-- Enter corresponding values that you use for presence
local presentStateMapping = {Home="Home", Away="Away", Holiday="Holiday"};
-- "SleepState" is predefined global variable that determines if you are
-- sleeping or are awake. This variable value is set by other scene or VD.
local sleepState          = "SleepState";
local sleepStateMapping   = {Sleep="Sleep", Awake="Awake"};
-- if you don't want to use SleepState then set following variable to "No"
-- otherwise to "Yes". If set to "No" and not using sleepState then make 
-- sure that you put useTimeOfDay to "Yes"  otherwise lights will always 
-- turn to Awake level!!
local useSleepState       = "Yes";
-- "sleepingName" predefined global variable with possible values: "Yes",
-- "No" but in comparison to "SleepState" which puts to sleep entire house
-- or apartment this one is used to put to sleep only one room. So it can be
-- used to turn living room into bedroom, or to disable lights in children 
-- rooms so they can go sleep earlier and we don't have to put entire house 
-- to sleep. If value is set to "Yes" disables smart light, "No" enables smart
-- light. If you don't use it then just leave "" empty. In our children
-- bedrooms I setup dimmer 2 switch 2 to start scene on 1 click which then
-- press button on VD to change state of this variable from "No" to "Yes" and
-- vice versa so they can switch off lighting themselves. When this variable
-- value change from "Yes" to "No" this scene will turn off lights and will
-- not turn on lights on movement. Put also this global variable under scene
-- header section %% globals!
local sleepingName        = "";
local sleepingMapping     = {Yes="Yes", No="No"};
-- "LightState" is predefined global variable with possible values: "Auto",
-- "Manual". If set to "Auto" then smart lights are enabled if set to "Manual"
-- then lights have to be turned On/Off manually because all very smart light
-- scenes are disabled! Value is changed with VD.
local lightState          = "LightState";
local lightStateMapping   = {Auto="Auto", Manual="Manual"};
-- "IndoorLightsDim" is predefined global variable with possible values: 
-- "Yes", "No". If set to "Yes" then lights will be dimmed to Sleep level 
-- regardless of any other settings (Guest, Awake, Cinema), "No" will enable 
-- other dimming levels. We use this during summer to dim lights in house not
-- to attract insects since windows and doors are opened. Value is changed
-- with VD.
local indoorLightsDim     = "IndoorLightsDim";
local indoorLightsMapping = {Yes="Yes", No="No"}
-- if you don't want to use indorLigtsDim then set following variable to "No"
-- otherwise to "Yes"
local useIndoorLights     = "No";
-- "CinemaState" is predefined global variable with possible values: "Yes", 
-- "No". If set to "Yes" lights will dim to predefined levels by dimDIMCinema
-- & dimVDCinema and status can be changed by VD that controls TV.
local cinemaState         = "CinemaState";
local cinemaStateMapping  = {Yes="Yes", No="No"};
-- if you don't want to use cinemaState then set following variable to "No" 
-- otherwise to "Yes"
local useCinemaState      = "No";
-- "ProjectorState" is predefined global variable with possible values: "Yes", 
-- "No". If set to "Yes" lights will dim to predefined levels by dimDIMprojector
-- & dimVDprojector and status can be changed by VD that controls projector
local projectorState        = "ProjectorState";
local projectorStateMapping = {Yes="Yes", No="No"};
-- if you don't want to use cinemaState then set following variable to "No" 
-- otherwise to "Yes"
local useProjectorState     = "No";
-- "CookingState" is predefined global variable with possible values: "Yes", 
-- "No". If set to "Yes" lights will dim to predefined levels by dimDIMcooking
-- & dimVDcooking and status can be changed by VD that controls cooking
local cookingState        = "CookingState";
local cookingStateMapping = {Yes="Yes", No="No"};
-- if you don't want to use cookingState then set following variable to "No" 
-- otherwise to "Yes"
local useCookingState     = "No";
-- "MealState" is predefined global variable with possible values: "Yes", 
-- "No". If set to "Yes" lights will dim to predefined levels by dimDIMMeal
-- & dimVDMeal and status can be changed by VD that controls mealtime
local mealState           = "MealState";
local mealStateMapping    = {Yes="Yes", No="No"};
-- if you don't want to use mealState then set following variable to "No" 
-- otherwise to "Yes"
local useMealState        = "No";
-- GuestState is predefined global variable with possible values: "Yes", "No".
-- If "Yes" it will set lights to predefined level with dimVDGuest & dimDIMGuest,
-- also timer is disabled and lights will stay on until set to "No" guests
-- if this global variable is added to to section bellow:
-- GLOBAL VARIABLES STATE TO KEEP LIGHTS ON!
local guestState          = "GuestState";
local guestStateMapping   = {Yes="Yes", No="No"};
-- if you don't want to use guestState then set following variable to "No"
-- otherwise to "Yes"
local useGuestState       = "No";
-- "Darkness" is global variable with two possible states 0 - for day time
-- and 1 for night time and it is changed at sunrise & sunset by main scene
-- that is responsible for all time based events. IMPORTANT!! This one you
-- also must add to scene header under %% globals section
local darkness            = "Darkness";
local darknessMapping     = {Light="0", Dark="1"};
-- "TimeOfDay" is global variable with possible values: "Morning", "Day",
-- "Evening", "Night". Value is changed by main scene that is responsible 
-- for all time based events. Lights will adapt brightness when variable
-- change value if you set useTimeOfDay to "Yes". If you set to "No" and
-- all other options (Holiday, Guest, Cinema, Indoor..) are se to "No"
-- then only SleepState will influence lights dim level. This one you
-- also must add to scene header under %% globals section
local timeOfDay           = "TimeOfDay";
local timeOfDayMapping    = {Morning="Morning", Day="Day", Evening="Evening", Night="Night"};
local useTimeOfDay        = "Yes";
-- "HolidayLights" is predefined variable with possible values: "On" and
-- "Off" and can be used to set brightness of lights to predefined level,
-- or you can even disable control of some of the lights because they
-- are controled by other scene and VD. Exaple is for Christmas time when
-- I use HUE lamps to change color with another scene so I disable control
-- for them in this scene and change brightness level for other lights to
-- improve ambient. Depending on your settings in this scene control of
-- defined lights will be disabled and brightness level of other lights set
-- to holiday levels only while value of this global variable is "On". When
-- value change to "Off" this scene will resume control over all defined
-- lights with brightness levels set with other values and HUE lights will
-- revert to set default color!
local holidayLights        = "HolidayLights";
local holidayLightsMapping = {On="On", Off="Off"};
-- if you don't want to dim other lights when holidayLights are on then
-- leave "No" otherwise set to "Yes"
local useholidayLights     = "No";

-- SENSORS, LIGHTS, DIMMING LEVELS, EXTRA DEVICES AND TIMERS ---------------

-- MOTION SENSOR(S) --------------------------------------------------------
-- enter motion sensors or door sensors or any devices ID separated by comma
-- that you want to turn lights on! Just MAKE SURE that you also put those 
-- ID above in header section under %% properties eg. "30 value"
local motionID = {};

-- MOTION DETECTED WITH GLOBAL VARIABLE ------------------------------------
-- if you use motion sensors from stand alone alarm systems from other
-- manufacturers and not connected to Fibaro HC then you can leave motionID
-- empty = {}. First you need to set bellow useGlobalMotion to "Yes" and 
-- then add global variables that are used to monitor motion sensors, as many
-- as you need to variable globalMotionID separated by comma
local useGlobalMotion = "No";
-- enter global variables that will trigger this scene separated by comma.
-- Don't forget to add all global variables also to scene header under
-- %% globals !!!
local globalMotionID = {};
-- enter here value of the above global variables which reflect when
-- motion sensor is breached. For example if sensor is breached and
-- global variable change value to 1, then put this value bellow
local globalMotionValue = "";
-- You can also use mixed motion sensors some from Fibaro and some from
-- other alarm systems. This is up to you!

-- LIGHT SENSOR(S) ---------------------------------------------------------
-- enter light sensor IDs separated with comma that will be used to control
-- lights. If there is more than one then average lux is calculated! Just 
-- MAKE SURE that you also put those ID above in header section under 
-- %% properties eg. "30 value"
local luxID    = {};

-- if you don't have light sensors just leave it empty, and also don't
-- change default values for light levels luxMin=100 and luxMax=300!

-- LIGHTS SETTINGS ---------------------------------------------------------

-- VD OR PLUGIN LIGHTS (HUE) -----------------------------------------------
-- enter lights ID controlled by VD or plugin (like HUE) separated by comma
-- between brackets or if none leave brackets empty
local VDlightID          = {};

-- enter type of the VD device used for each light separated by comma:
-- "VDHcol" - virtual device controlling Philips HUE white & color
--            ambience bulb version 2.1m & 2.1b
-- "VDHwha" - virtual device controlling Philips HUE wihte ambience
--            bulb version 2.1m & 2.1b
-- "VDHwbr" - virtual device controlling Philips HUE white brightness
--            only bulb version 2.1m & 2.1b
-- "VDHcst" - custom version of Philips HUE VD so please provide bellow
--            buttons & sliders order numbers!
-- "PlugIn" - Philips HUE plugin
-- REMEMBER!! If you use VD then brightness, color and saturation can be
-- set from 0 to 100 and if you use PlugIn then brightness and saturation
-- can be set from 0 to 254 while color 0 - 65535!!! color temperature for
-- white ambience bulb can be set from 153 to 500
local VDlightIDtype      = {};
-- if you use HUE VD version 2.1m then set refresh type to "M" else if
-- you use HUE VD version 2.1b then set refresh type to "B" for each
-- VD light, same applies for custom VD.
local VDrefreshType      = {};
-- If you use custom VD for Philips HUE then please define buttons and
-- sliders order number. if not used then just leave empty quotes.
local VDbrightnessSlider = "2";
local VDcolorSlider      = "3";
local VDsaturationSlider = "4";
local VDrefreshButton    = "5";
-- enter name of brightness slider if you use custom made HUE VD. This name
-- can be found in advanced tab when editing VD:
local customVDbriSliderName = "sldBrightness";
-- enter name of hue(color) slider if you use custom made HUE VD. This name
-- can be found in advanced tab when editing VD:
local customVDhueSliderName = "sldHue";
-- enter name of saturation slider if you use custom made HUE VD. This name
-- can be found in advanced tab when editing VD:
local customVDsatSliderName = "sldSaturation";
-- enter here default values for VD color and saturation to be reset if used
-- for holiday lights or other, REMEMBER! Values are different for VD and
-- for "PlugIn" !!!
local VDdefaultColor      = 20; -- VD = 1 - 100; PlugIn = 1 - 254
local VDdefaultSaturation = 20; -- VD = 0 - 100; PlugIn = 0 - 65535
local VDdefaultColorTemp  = 30; -- VD = 0 - 100; Plugin = 153 - 500
-- enter which lights will be used during holiday to change color by
-- setting light flag to 1. If you left flag 0 then scene will control
-- light as usual. Same is for all other type of lights bellow. Flag must
-- be defined for all lights even if you don't use HolidayLights.
local VDholidayFlag      = {};
-- enter here if you want to keep ambilight color of the HUE lamps when
-- turned on by motion sensor or want then to use default settings. Enter
-- "Yes" to keep color or "No" to dimm up to default settings above
local keepAmbilight       = "No";

-- DIMMER LIGHTS -----------------------------------------------------------
-- enter lights ID controlled by DIMMER DEVICE separated by comma between 
-- brackets or if none leave brackets empty
local DIMlightID         = {};
-- enter which DIMMER lights will be used during holiday and controlled by
-- another scene or VD by setting light flag to 1. If you left flag 0 then
-- this scene will control light as usual.
local DIMholidayFlag     = {};

-- RELAY, SWITCH, SMART PLUG LIGHTS ----------------------------------------
-- enter lights ID controlled by SWITCH (RELAY, SMART PLUG) separated by
-- comma between brackets or if none leave brackets empty
local SWTlightID         = {};
-- same settings as above.
local SWTholidayFlag     = {};

-- RGBW LIGHTS -------------------------------------------------------------
-- enter lights ID controlled by RGBW MODULE separated by comma between
-- brackets or if none leave brackets empty
local RGBWlightID        = {};
-- same settings as above.
local RGBWholidayFlag    = {};
-- RGBW MODULE PROGRAM AND COLORS SETTINGS ------------------------------
-- RGBW module has some default programs and more can be added by users,
-- here you can define your favorite program for each RGBW light and turn
-- usage on by setting useRGBWprograms to "Yes". Also you can set at what 
-- time of day to use program. If you leave RGBWprogramTime empty "" then 
-- script will use program setting throughout all day! When program is not
-- in use you can enter color settings and turn on color usage by setting 
-- useRGBWcolor to "Yes". If both program and color is set to "No" then 
-- LED strips will be turned on to preset brightness in dimming levels 
-- and duration section
local useRGBWprograms = {"No"};
-- define favorite programs for seven days of the week starting with Sunday
-- Just enter ID of the programs separated by comma for each RGBW light:
-- Eg for 2 lights: {{1, 3, 4, 1, 3, 1, 3}, {1, 3, 4, 1, 3, 1, 3}};
local RGBWfavorite    = {{1, 3, 4, 1, 3, 1, 3}};
-- enter at what time of day you want RGBW program to be run. Possible
-- entries: "Morning", "Day", "Evening", "Night" or leave empty "" for
-- all day for each RGBW module separately
local RGBWprogramTime = {"Evening"};
-- If set to "Yes" then color settings will be used to turn on RGBW light
-- and can be defined for each module
local useRGBWcolor    = {"No"};
-- Here enter color settings for each RGBW module. Make sure that you enter
-- settings for all colors R,G,B, & W and for all RGBW lights as this example
-- for two: {{R=255, G=255, B=50, W=100}, {R=155, G=155, B=150, W=100}};
local RGBWcolor       = {{R=169, G=56, B=0, W=100}};
 
-- LIGHT LEVELS -----------------------------------------------------------
-- enter minimum light level measured by luxID sensor(s) at which lights
-- will turn ON during day time if light sensor is not used then leave the
-- default value 100!
local luxMin          = 100;
-- enter maximum light level measured by luxID sensor at which lights will
-- be turned OFF if light sensor is not used then leave the default
-- value 300!
local luxMax          = 300;

-- TURN OFF OR DIMM LIGHTS ------------------------------------------------
-- to have lights dim low instead of turning off, first set dimOff to true.
-- If you want ligths to stay dimmed low even during sleep then also set
-- keepDimSleep to true. After that you still need bellow to enable at
-- which time of day you want lights to dim low and set brightness levels
-- and also set useDimLow to true.
local dimOff          = false;
-- define here if you want to keep dimmed lights during sleep 'true' or you
-- want them to turn off 'false'
local keepDimSleep    = false;
-- define here if you want scene to remember previous settings of HUE lamps
-- so when tere is no motion in room anymore to dimm them to previous
-- ambilight. Enter "Yes" to remember, "No" to keep to default settings
local dimOffAmbilight = "No";
-- define dimming level for VD(HUE) lights when no movement detected 
-- 0 - turned off 1 to 100 dimmed. You can define for each HUE lamp 
-- different dim level just enter for each light value in braces separated
-- by comma like {20, 10}
-- NEW from version 1.3.4 now you can set dimOff levels for all times of
-- day

-- * MORNING * -------------------------------------------------------------
local dimVDlowMorning  = {};
-- define dimming level for each light controlled by DIMMER when no movement 
-- detected. Same as above
local dimDIMlowMorning = {};
-- define dimming level for each light controlled by RGBW when no movement 
-- detected. Same as above
local dimRGBlowMorning = {};
-- define for each light controlled by SWITCH will turn off when no movement 
-- detected. 0 - turn off, or 1 to stay on
local valSWTlowMorning = {};
-- define "Yes" here for each RGBW if you want favorite program to continue
-- running or "No" to enable use of predefined color settings or just
-- turn it off when no one is in room and timer finished counting
-- NOTE to keep program running you need to set dimRGBlow greater than zero!
local dimRGBprogramMorning = {"No"};
-- define "Yes" here for each RGBW light if you want to be set to predefined
-- color at above dimlow brightness or "No" to just dim it low at present
-- color settings
-- NOTE to keep color on you need to set dimRGBlow to beightness value greater
-- than zero
local dimRGBcolorMorning = {"No"};
-- define if you want lights to dim low at Morning time 'true' or 'false'
local useDimLowMorning = false;

-- * DAY * ---------------------------------------------------------------
local dimVDlowDay  = {};
-- define dimming level for each light controlled by DIMMER when no movement 
-- detected. Same as above
local dimDIMlowDay = {};
-- define dimming level for each light controlled by RGBW when no movement 
-- detected. Same as above
local dimRGBlowDay = {};
-- define for each light controlled by SWITCH will turn off when no movement 
-- detected. 0 - turn off, or 1 to stay on
local valSWTlowDay = {};
-- define "Yes" here for each RGBW if you want favorite program to continue
-- running or "No" to enable use of predefined color settings or just
-- turn it off when no one is in room and timer finished counting
-- NOTE to keep program running you need to set dimRGBlow greater than zero!
local dimRGBprogramDay = {"No"};
-- define "Yes" here for each RGBW light if you want to be set to predefined
-- color at above dimlow brightness or "No" to just dim it low at present
-- color settings
-- NOTE to keep color on you need to set dimRGBlow to beightness value greater
-- than zero
local dimRGBcolorDay = {"No"};
-- define if you want lights to dim low at Day time 'true' or 'false'
local useDimLowDay = false;
-- same as above but for night time

-- * EVENING * ---------------------------------------------------------------
local dimVDlowEvening  = {};
-- define dimming level for each light controlled by DIMMER when no movement 
-- detected. Same as above
local dimDIMlowEvening = {};
-- define dimming level for each light controlled by RGBW when no movement 
-- detected. Same as above
local dimRGBlowEvening = {};
-- define for each light controlled by SWITCH will turn off when no movement 
-- detected. 0 - turn off, or 1 to stay on
local valSWTlowEvening = {};
-- define "Yes" here for each RGBW if you want favorite program to continue
-- running or "No" to enable use of predefined color settings or just
-- turn it off when no one is in room and timer finished counting
-- NOTE to keep program running you need to set dimRGBlow greater than zero!
local dimRGBprogramEvening = {"No"};
-- define "Yes" here for each RGBW light if you want to be set to predefined
-- color at above dimlow brightness or "No" to just dim it low at present
-- color settings
-- NOTE to keep color on you need to set dimRGBlow to beightness value greater
-- than zero
local dimRGBcolorEvening = {"No"};
-- define if you want lights to dim low at Evening time 'true' or 'false'
local useDimLowEvening = false;
-- same as above but for night time
-- * NIGHT * -----------------------------------------------------------------
local dimVDlowNight      = {};
-- define dimming level for each light controlled by DIMMER when no movement 
-- detected. Same as above
local dimDIMlowNight     = {};
-- define dimming level for each light controlled by RGBW when no movement 
-- detected. Same as above
local dimRGBlowNight     = {};
-- define for each light controlled by SWITCH will turn off when no movement 
-- detected. 0 - turn off, or 1 to stay on
local valSWTlowNight     = {};
-- define "Yes" here for each RGBW if you want favorite program to continue
-- running or "No" to enable use of predefined color settings or just
-- turn it off when no one is in room and timer finished counting
-- NOTE to keep program running you need to set dimRGBlow greater than zero!
local dimRGBprogramNight = {"No"};
-- define "Yes" here for each RGBW light if you want to be set to predefined
-- color at above dimlow brightness or "No" to just dim it low at present
-- color settings
-- NOTE to keep color on you need to set dimRGBlow to beightness value greater
-- than zero
local dimRGBcolorNight = {"No"};
-- define if you want lights to dim low at Night time 'true' or 'false'
local useDimLowNight = false;

-- LIGHT DIMMING LEVELS AND TIMER DURATION SETTINGS ---------------------

-- DIMMING LEVELS AND TIMER DURATION WITH GLOBAL VARIABLES --------------
-- bellow you can set dimming levels for each VD, DIMMER, RGBW module 
-- controlled lights for different situations. This will work
-- only if you first enable usage of each situation by setting usage
-- variable to "Yes".
-- Dimming levels of other lights when holiday lights are turned On for
-- each light in braces separated by comma.
-- NOTE - at the moment duration is one and same for all lights!
-- Enter brightness setting for each light when useGuestState is set
-- to Yes and GuestState is set to Yes:
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDGuest     = {};
-- brightness setting for each DIMMER light:
local dimDIMGuest    = {};
-- brightness setting for each RGBW light:
local dimRGBGuest    = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTGuest    = {};
-- after no motion detected keep lights on time setting in seconds:
local durGuest       = 120;
-- Enter brightness setting for each light when useCookingState is set
-- to Yes and CookingState is set to Yes:
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDCooking    = {};
-- brightness setting for each DIMMER light:
local dimDIMCooking   = {};
-- brightness setting for each RGBW light:
local dimRGBCooking   = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTCooking   = {};
-- after no motion detected keep lights on time setting in seconds:
local durCooking      = 120;
-- Enter brightness setting for each light when useMealState is set
-- to Yes and MealState is set to Yes:
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDMeal       = {};
-- brightness setting for each DIMMER light:
local dimDIMMeal      = {};
-- brightness setting for each RGBW light:
local dimRGBMeal      = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTMeal      = {};
-- after no motion detected keep lights on time setting in seconds:
local durMeal         = 120;
-- Enter brightness setting for each light when useProjectorState is set
-- to Yes and ProjectorState is set to Yes:
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDProjector  = {};
-- brightness setting for each DIMMER light:
local dimDIMProjector = {};
-- brightness setting for each RGBW light:
local dimRGBProjector = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTProjector = {};
-- after no motion detected keep lights on time setting in seconds:
local durProjector    = 120;
-- Enter brightness setting for each light when useCinemaState is set
-- to Yes and CinemaState is set to Yes:
-- brightness setting for each VD/PlugIn(HUE) light:
-- Enter brightness setting for each light when useCinemaState is set
-- to Yes and CinemaState is set to Yes:
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDCinema    = {};
-- brightness setting for each DIMMER light:
local dimDIMCinema   = {};
-- brightness setting for each RGBW light:
local dimRGBCinema   = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTCinema   = {};
-- after no motion detected keep lights on time setting in seconds:
local durCinema      = 120;
-- Enter brightness setting for each light when useHolidayLights is set
-- to Yes and holiday lights are turned on:
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDholiday  = {};
-- brightness setting for each DIMMER light:
local dimDIMholiday = {};
-- brightness setting for each RGBW light:
local dimRGBholiday = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTholiday = {};
-- after no motion detected keep lights on time setting in seconds:
local durholiday    = 90;
-- SleepState = Awake dimming levels and timer duration (when we are 
-- awake and light lux is low and is used when variable useTimeOfDay 
-- is set to "No"!!
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDAwake     = {};
-- brightness setting for each DIMMER light:
local dimDIMAwake    = {};
-- brightness setting for each RGBW light:
local dimRGBAwake    = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTAwake    = {};
-- after no motion detected keep lights on time setting in seconds:
local durAwake       = 180;
-- SleepState = Sleep and/or indoorLightsDim dimming levels and 
-- duration (when we are sleeping) brightness setting for each 
-- VD/PlugIn(HUE) light when SleepState is sleep:
-- brightness setting for each VD/PlugIn(HUE) light:
local dimVDSleep     = {};
-- brightness setting for each DIMMER light:
local dimDIMSleep    = {};
-- brightness setting for each RGBW light:
local dimRGBSleep    = {};
-- brightness setting for each SWITCH/RELAY/PLUG light:
local valSWTSleep    = {};
-- after no motion detected keep lights on time setting in seconds:
local durSleep       = 90;

-- DIMMING LEVELS AND TIMER WITH TIME OF DAY -----------------------------
-- If all special events (Guest, Cinema, indoor lights, holiday lights)
-- are disabled by setting usage to "No" or are not activated with global
-- value then lights dimming level will be set depending on settings of 
-- the following local variable:
-- if useTimeOfDay is set to:
--    "No"  - use dimDIMAwake, dimVDAwake and durAwake, 
--    "Yes" - use timeOfDay settings bellow:
-- NOTE - at the moment duration is one and same for all lights!

-- *** MORNING ***
-- setting for each VD/PlugIn(HUE) light for MORNING time:
local dimVDMorning    = {};
-- setting for each light controlled by DIMMER for MORNING time:
local dimDIMMorning   = {};
-- setting for each RGBW light for MORNING time:
local dimRGBMorning   = {};
-- setting for each SWITCH light for MORNING time:
local valSWTMorning   = {};
-- timer duration setting for MORNING time in seconds:
local durationMorning = 120;

-- *** DAY ***
-- setting for each VD(HUE) light for DAY time:
local dimVDDay        = {};
-- setting for each light controlled by DIMMER for DAY time:
local dimDIMDay       = {};
-- setting for each RGBW light for DAY time:
local dimRGBDay       = {};
-- setting for each SWITCH light for DAY time:
local valSWTDay       = {};
-- timer duration setting for DAY time in seconds:
local durationDay     = 300;

-- *** EVENING ***
-- setting for each VD(HUE) light for EVENING time:
local dimVDEvening    = {};
-- setting for each light controlled by DIMMER for EVENING time:
local dimDIMEvening   = {};
-- setting for each RGBW light for EVENING time:
local dimRGBEvening   = {};
-- setting for each SWITCH light for EVENING time:
local valSWTEvening   = {};
-- timer duration setting for EVENING time in seconds:
local durationEvening = 300;

-- *** NIGHT ***
-- setting for each VD(HUE) light for NIGHT time:
local dimVDNight      = {};
-- setting for each light controlled by DIMMER for NIGHT time:
local dimDIMNight     = {};
-- setting for each RGBW light for NIGHT time:
local dimRGBNight     = {};
-- setting for each SWITCH light for NIGHT time:
local valSWTNight     = {};
-- timer duration setting for NIGHT time in seconds:
local durationNight   = 180;

-- CHECK LIGHT STATUS!! --------------------------------------------------
-- if you want to be able to switch off lights before any timer is done
-- then set this variable to "true" else leave "false". If set to false
-- lights will turn off after defined time from last movement detected
-- if set to true then if you turn off one light manually other will
-- also turn off as soon as motion sensor change status to safe and
-- regardless of extra devices and/or timers active.
local checkLightOff   = true;

-- TIMER CORRECTION TIME!! -----------------------------------------------
-- please check your motion sensor parameter 6 settings and put it here so
-- that timer duration is corrected to be exact as you entered above 
-- (30 sec is default setting for Fibaro motion sensor):
local PIRwindowTime   = 30;

-- EXTRA DEVICES (VALUE) TO KEEP LIGHTS ON -------------------------------
-- Here you can define some extra conditions that will keep lights on until
-- changed. Enter devices ID separated by comma in table that you want to 
-- keep lights on. If breached put 1 or if safe put 0 in extraDeviceValue
-- Example is light in bathroom, if you put here bathroom door sensor ID
-- and 0 for door closed then light will stay on even motion is not
-- detected as long as door is closed. Light can be still turned off
-- manually and if checkLightOff is set to true then scene will stop
-- before timer is counted to zero.
 extraDeviceID    = {};
 extraDeviceValue = {};
-- if you want to enable EXTRA DEVICES (VALUE) to keep lights on when
-- SleepState is set to Sleep then set extraDeviceSleep to true otherwise
-- set it to false
 extraDeviceSleep = false;

-- EXTRA DEVICES (POWER) TO KEEP LIGHTS ON -------------------------------
-- enter devices ID separated with comma in table that read power 
-- consumption and will keep lights on as long as power consumption is 
-- grater than value put in table setPower in watts. For example if you
-- put here study table light smart plug ID and 10W then scene will keep
-- lights on as long as study table light is on and draws power greater
-- than 10W.
 extraPowerID    = {};
 setPower        = {};
-- if you want to enable EXTRA DEVICES (POWER) to keep lights on when
-- SleepState is set to Sleep then set extraDeviceSleep to true otherwise
-- set it to false
 extraPowerSleep = false;

-- GLOBAL VARIABLES STATE TO KEEP LIGHTS ON ------------------------------
-- enter global variable names separated by comma in table that will keep
-- lights on as long as their value is same as value in table
-- extraGlobalValue. Ex.: extraGlobalName  = {"CinemaState", "GuestState"}
--                        extraGlobalValue = {"Yes", "Yes"}
-- In above example if any or both global variables "CinemaState" and
-- "GuestState" value is set to "Yes" then scene will keep lights on.
-- As soon as their value is set back to "No" scene will enable timer
-- and turn off lights after defined time if no motion detected.
-- Of course if you don't need this feature just leave brackets empty {}
extraGlobalName       = {};
extraGlobalValue      = {};
-- if you want to enable EXTRA GLOBAL VARIABLE to keep lights on when
-- SleepState is set to Sleep then set extraDeviceSleep to true otherwise
-- set it to false
extraGlobalSleep = false;

-- EXTRA TIMERS TO KEEP LIGHTS ON --------------------------------------- 
-- here you can enable (true) extra timer that will keep lights on from
-- specific time like wakeup time from alarm clock and for how long. 
-- Lights will still go off if there is enough light in the room. Time 
-- format must be in string format "HH:MM"
 extraTimerEnable   = false;
-- enter name of the global variable for Alarm clock status and map your
-- values for On and Off status
 timerStatus        = "AlarmClockStatus";
 timerStatusMapping = {On="On", Off="Off"};
-- here enter name of global variable to enable/disable particular timer
-- eg. check if AlarmClockDays1 that is generated by jompa68 ACWUT 
-- (AlarmClock + WakeUpTime) version 3.0.0 is active or turned off and
-- define for which value timer will be enabled
 timerCheckName     = {"AlarmClockDays1", "AlarmClockDays2"};
 timerCheckValue    = {"Weekdays", "Weekends"};
-- set mapping for alarm days if you use them in your language
 timerValueMapping  = {Weekdays="Weekdays", Weekends="Weekends",
                       Monday="Monday", Tuesday="Tuesday",
                       Wednesday="Wednesday", Thursday="Thursday",
                       Friday="Friday", Saturday="Saturday",
                       Sunday="Sunday", Off="Off"};
-- here you enter name of global variable(s) which value is specific
-- time in format HH:MM (like alarm clock)
 timerStartTimeName = {"AlarmClockTime1", "AlarmClockTime2"};
-- here you enter for how long timer will keep lights on, eg. "01:00"
-- will keep for 1 hour, "00:30" will keep for 30 min from specified time
-- by AlarmClockTime1 and/or AlarmClockTime2
 timerDurationTime  = {"01:30", "01:30"};

-- ACTIVATE DEVICE, VD, SCENE OR CHANGE GLOBAL VARIABLE VALUE WITH TIMER --
-- scene has timer that counts seconds from 0 up from time when is first
-- triggered by motion sensor and while is running. This timer can be used
-- to start devices or scenes or change value of global variables at time 
-- specified in seconds. If scene stops running before start time is reached
-- then nothing will happen. This can be used to start extraction fan in 
-- bathroom if you stay there longer than some specified time or anything
-- else you may want to start or even stop after defined time starting from
-- breaching motion sensor and starting this scene!!

-- ACTIVATE DEVICE --------------------------------------------------------
-- enter device ID separated by comma which you like to start between {}
-- brackets like {123, 50}, if none just leave brackets empty
local exDeviceID      = {};
-- enter value for each device above separated by comma as follows:
-- 400 - this value will just turn on device - "turnOn"
--   0 - this will actually turn off device - "turnOff"
-- 1 to 100 - this will turn on device with this value - "value" or will
--            change device value if it is already turned on
-- -1 to -100 - this will set value for device and then turn it on which
--              means that first value will be set and then "turnOn"
--              command executed.
local exDeviceValue   = {}
-- enter time in seconds after which you want to start above device(s)
-- separated by comma like {180, 240}. Each device can have different time.
local exDeviceTime    = {};

-- ACTIVATE BUTTON ON VIRTUAL DEVICE --------------------------------------
-- enter VD ID separated by comma which you like to activate between {}
-- brackets like {123, 50}, if none just leave brackets empty
local exVDeviceID     = {};
-- enter number of button with quotation marks like {"2", "5"} that will be
-- pressed
local exVDeviceButton = {}
-- enter time in seconds after which you want to press button on above VD(s)
-- separated by comma like {180, 240}. Each VD can have different time.
local exVDeviceTime   = {};


-- START SCENE ------------------------------------------------------------
-- enter scene(s) ID separated by comma which you like to start between {}
-- brackets like {30, 28} if none just leave brackets empty
local exSceneID     = {};
-- enter time in seconds after which you want to start above scene(s)
-- separated by comma like {180, 240}. Each scene can have different time.
local exSceneTime   = {};

-- CHANGE GLOBAL VARIABLE VALUE--------------------------------------------
-- NOTE: if you use global variables to control extra devices then you need
-- to define those global variables in global variable panel first!!
-- enter global variable name(s) separated by comma of which you like to
-- change value eg. {"Global1", "Global2"}. if none just leave brackets 
-- empty
local exGlobal      = {};
-- enter for each global variable what value you want to set separated by
-- comma like {"Value1", 1}. Can be string value with "", or numerical
-- value. 
local exGlobalValue = {};
-- enter time in seconds after which you want global variable to change
-- value separated by comma like {180, 240}. Each global variable can have
-- different time.
local exGlobalTime  = {};

-- DEBUGGING VARIABLES ---------------------------------------------------
-- setup debugging, true is turned on, false turned off.
local deBug           = true;  -- for showing events as they happen like
                               -- turning on/off lights etc.
local lightdebug      = false; -- debuging procedures to control light
                               -- bulbs
local timerdeBug      = false; -- for testing main timer of the loop and
                               -- will repeat every second
local exFlag          = true;  -- for testing extra devices and globals,
                               -- will show only first occurrence
local chFlag          = true;  -- for testing extra timer, will show only
                               -- first occurrence
-- END OF CODE PART FOR USERS TO EDIT AND SETUP --------------------------

-- BELLOW CODE NO NEED TO MODIFY BY USER ---------------------------------
-- except if you know what you're doin' :-P

-- setup some local variables
local version         = "1.4.0";
local luxMeas         = "";
local countdown       = 0;
local exTimer         = 0;
local time            = os.date('*t');
local currentwday     = time['wday'];
local chState         = false;
local chLight         = false;
local chLevel         = false;
local adjusted        = false;
local motion          = false;
local errFlag         = false;
local VDhueAmbilight  = {};
local VDsatAmbilight  = {};
local VDctAmbilight   = {};
customBriSlider = "ui."..customVDbriSliderName..".value";
customHueSlider = "ui."..customVDhueSliderName..".value";
customSatSlider = "ui."..customVDsatSliderName..".value";
local StartSource     = fibaro:getSourceTrigger();

-- debugging function in color
function logbug(color, message)
  fibaro:debug(string.format('<%s style="color:%s;">%s</%s>', "span", color, message, "span")); 
end

-- get current status
function getCurrentState()
  presentStateCurrent    = fibaro:getGlobalValue(presentState);
  sleepStateCurrent      = fibaro:getGlobalValue(sleepState);
  if sleepingName ~= "" then
    sleepingCurrent      = fibaro:getGlobalValue(sleepingName);
  else
    sleepingCurrent      = sleepingMapping.No;
  end
  lightStateCurrent      = fibaro:getGlobalValue(lightState);
  timeOfDayCurrent       = fibaro:getGlobalValue(timeOfDay);
  indoorLightsCurrent    = fibaro:getGlobalValue(indoorLightsDim);
  cinemaStateCurrent     = fibaro:getGlobalValue(cinemaState);
  projectorStateCurrent  = fibaro:getGlobalValue(projectorState);
  cookingStateCurrent    = fibaro:getGlobalValue(cookingState);
  mealStateCurrent       = fibaro:getGlobalValue(mealState);
  holidayLightsCurrent   = fibaro:getGlobalValue(holidayLights);
  guestStateCurrent      = fibaro:getGlobalValue(guestState);
  darknessCurrent        = fibaro:getGlobalValue(darkness);
  -- setup array to turn off lights
  if #VDlightID > 0 then
    VDoff = {};
    for i = 1, #VDlightID do
      VDoff[i] = 0;
    end
  end
  if #DIMlightID > 0 then
    DIMoff = {};
    for i = 1, #DIMlightID do
      DIMoff[i] = 0;
    end
  end
  if #RGBWlightID > 0 then
    RGBWoff = {};
    for i = 1, #RGBWlightID do
      RGBWoff[i] = 0;
    end
  end
  if #SWTlightID > 0 then
    SWToff = {};
    for i = 1, #SWTlightID do
      SWToff[i] = 0;
    end
  end
end

-- Adjust dim level and duration for different situations and/or time of day
function adjustLevels()
  if ((useGuestState == "Yes") and
      (fibaro:getGlobalValue(guestState) == guestStateMapping.Yes)) then
    if deBug then logbug("violet", "Adjusted levels to guest") end;
    dimDIM   = dimDIMGuest;
    dimVD    = dimVDGuest;
    dimRGB   = dimRGBGuest;
    valSWT   = valSWTGuest;
    duration = durGuest;
  elseif ((useCookingState == "Yes") and
          (fibaro:getGlobalValue(cookingState) == cookingStateMapping.Yes)) then
    if deBug then logbug("violet", "Adjusted levels to cooking") end;
    dimDIM   = dimDIMCooking;
    dimVD    = dimVDCooking;
    dimRGB   = dimRGBCooking;
    valSWT   = valSWTCooking;
    duration = durCooking;
  elseif ((useMealState == "Yes") and
          (fibaro:getGlobalValue(mealState) == mealStateMapping.Yes)) then
    if deBug then logbug("violet", "Adjusted levels to mealtime") end;
    dimDIM   = dimDIMMeal;
    dimVD    = dimVDMeal;
    dimRGB   = dimRGBMeal;
    valSWT   = valSWTMeal;
    duration = durMeal;
  elseif ((useProjectorState == "Yes") and
          (fibaro:getGlobalValue(projectorState) == projectorStateMapping.Yes)) then
    if deBug then logbug("violet", "Adjusted levels to projector") end;
    dimDIM   = dimDIMProjector;
    dimVD    = dimVDProjector;
    dimRGB   = dimRGBProjector;
    valSWT   = valSWTProjector;
    duration = durProjector;
  elseif ((useCinemaState == "Yes") and
          (fibaro:getGlobalValue(cinemaState) == cinemaStateMapping.Yes)) then
    if deBug then logbug("violet", "Adjusted levels to cinema") end;
    dimDIM   = dimDIMCinema;
    dimVD    = dimVDCinema;
    dimRGB   = dimRGBCinema;
    valSWT   = valSWTCinema;
    duration = durCinema;
  elseif ((useholidayLights == "Yes") and 
      (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.On)) then
    if deBug then logbug("violet","Adjusted levels to holiday lights") end;
    dimDIM   = dimDIMholiday;
    dimVD    = dimVDholiday;
    dimRGB   = dimRGBholiday;
    valSWT   = valSWTholiday;
    duration = durholiday;
  elseif ((useIndoorLights == "Yes") and
          (fibaro:getGlobalValue(indoorLightsDim) == indoorLightsMapping.Yes)) then
    if deBug then logbug("violet", "Adjusted levels indoor lights") end;
    dimDIM   = dimDIMSleep;
    dimVD    = dimVDSleep;
    dumRGB   = dimRGBSleep;
    valSWT   = valSWTSleep;
    duration = durSleep;
  elseif ((useSleepState == "Yes") and
          (fibaro:getGlobalValue(sleepState) == sleepStateMapping.Sleep)) then
    if deBug then logbug("violet", "Adjusted levels to sleep") end;
    dimDIM   = dimDIMSleep;
    dimVD    = dimVDSleep;
    dimRGB   = dimRGBSleep;
    valSWT   = valSWTSleep
    duration = durSleep;
  else  
    if useTimeOfDay == "No" then
      if deBug then logbug("violet", "Adjusted levels to awake") end;
      dimDIM   = dimDIMAwake;
      dimVD    = dimVDAwake;
      dimRGB   = dimRGBAwake;
      valSWT   = valSWTAwake;
      duration = durAwake;
    else
      if fibaro:getGlobalValue(timeOfDay) == timeOfDayMapping.Morning then
        if deBug then logbug("violet", "Adjusted levels to Morning time") end;
        dimDIM   = dimDIMMorning;
        dimVD    = dimVDMorning;
        dimRGB   = dimRGBMorning;
        valSWT   = valSWTMorning;
        duration = durationMorning;
      elseif fibaro:getGlobalValue(timeOfDay) == timeOfDayMapping.Day then
        if deBug then logbug("violet", "Adjusted levels to Day time") end;
        dimDIM   = dimDIMDay;
        dimVD    = dimVDDay;
        dimRGB   = dimRGBDay;
        valSWT   = valSWTDay;
        duration = durationDay;
      elseif fibaro:getGlobalValue(timeOfDay) == timeOfDayMapping.Evening then
        if deBug then logbug("violet", "Adjusted levels to Evening time") end;
        dimDIM   = dimDIMEvening;
        dimVD    = dimVDEvening;
        dimRGB   = dimRGBEvening;
        valSWT   = valSWTEvening;
        duration = durationEvening;
      else
        if deBug then logbug("violet", "Adjusted levels to Night time") end;
        dimDIM   = dimDIMNight;
        dimVD    = dimVDNight;
        dimRGB   = dimRGBNight;
        valSWT   = valSWTNight;
        duration = durationNight;
      end
    end
  end
  adjusted = true;
end

-- adjust dim level for Evening or Night time for dimOff
function dimOffLevels()
  if ((useDimLowMorning) and (fibaro:getGlobalValue(timeOfDay) == timeOfDayMapping.Morning)) then
    if deBug then logbug("violet", "Adjusted dim low levels to Morning time") end;
    dimVDlow      = dimVDlowMorning;
    dimDIMlow     = dimDIMlowMorning;
    dimRGBlow     = dimRGBlowMorning;
    valSWTlow     = valSWTlowMorning;
    dimRGBprogram = dimRGBprogramMorning;
    dimRGBcolor   = dimRGBcolorMorning;
    useDimLow     = useDimLowMorning;
  elseif ((useDimLowDay) and (fibaro:getGlobalValue(timeOfDay) == timeOfDayMapping.Day)) then
    if deBug then logbug("violet", "Adjusted dim low levels to Day time") end;
    dimVDlow      = dimVDlowDay;
    dimDIMlow     = dimDIMlowDay;
    dimRGBlow     = dimRGBlowDay;
    valSWTlow     = valSWTlowDay;
    dimRGBprogram = dimRGBprogramDay;
    dimRGBcolor   = dimRGBcolorDay;
    useDimLow     = useDimLowDay;
  elseif ((useDimLowEvening) and (fibaro:getGlobalValue(timeOfDay) == timeOfDayMapping.Evening)) then
    if deBug then logbug("violet", "Adjusted dim low levels to Evening time") end;
    dimVDlow      = dimVDlowEvening;
    dimDIMlow     = dimDIMlowEvening;
    dimRGBlow     = dimRGBlowEvening;
    valSWTlow     = valSWTlowEvening;
    dimRGBprogram = dimRGBprogramEvening;
    dimRGBcolor   = dimRGBcolorEvening;
    useDimLow     = useDimLowEvening;
  elseif ((useDimLowNight) and (fibaro:getGlobalValue(timeOfDay) == timeOfDayMapping.Night)) then
    if deBug then logbug("violet", "Adjusted dim low levels to Night time") end;
    dimVDlow      = dimVDlowNight;
    dimDIMlow     = dimDIMlowNight;
    dimRGBlow     = dimRGBlowNight;
    valSWTlow     = valSWTlowNight;
    dimRGBprogram = dimRGBprogramNight;
    dimRGBcolor   = dimRGBcolorNight;
    useDimLow     = useDimLowNight;
  else
    if deBug then logbug("violet", "Dim low levels for "..fibaro:getGlobalValue(timeOfDay)..
                          " not set. Lights will turn Off") end;
  end
end


-- check if custom VD is set properly
function checkCustomVD()
  check = true;
  what  = "";
  if VDbrightnessSlider == "" then
    what = "brightness slider order number";
  elseif VDcolorSlider == "" then
    what = "color slider order number";
  elseif VDsaturationSlider == "" then
    what = "color slider order number";
  elseif VDrefreshButton == "" then
    what = "refresh button order number";
  elseif customVDbriSliderName == "" then
    what = "brightness slider name";
  elseif customVDhueSliderName == "" then
    what = "color slider name";
  elseif customVDsatSliderName == "" then
    what = "saturation slider name";
  end
  if what ~= "" then
    logbug("red", "ERROR! Custom VD "..what.." not defined. Please check settings.");
    check = false;
  end
  return check
end

-- check if lights settings are ok
function checkUserSettings(f, cdim)
  -- f=1 check VD settings   -- f=2 check DIMMER settings
  -- f=3 check RGBW settings -- f=4 check SWITCH settings
  check = true;
  if f == 1 then
    if #VDlightID > #cdim then
      logbug("red", "ERROR! One of VD lights is missing dimOff value. Please correct settings.");
      check = false;
    elseif #VDlightID > #VDlightIDtype then
      logbug("red", "ERROR! One of VD lights is missing VDlightIDtype definition. Please correct settings.");
      check = false;
    elseif #VDlightID > #VDrefreshType then
      logbug("red", "ERROR! One of VD lights is missing VDrefreshType definition. Please correct settings.");
      check = false;
    end
  elseif f == 2 then
    if #DIMlightID > #cdim then
      logbug ("red", "ERROR! One of DIMMER lights is missing dimOff value. Please correct settings.");
      check = false;
    end
  elseif f == 3 then
    if #RGBWlightID > #cdim then
      logbug("red", "ERROR! One of RGBW lights is missing dimOff value. Please correct settings.");
      check = false;
    end
  elseif f == 4 then
    if #SWTlightID > #cdim then
      logbug("red", "ERROR! One of SWITCH lights is missing dimOff value. Please correct settings.");
      check = false;
    end
  end
  return check
end

-- collect color settings of UHE lamps
function getAmbilight()
  for i = 1, #VDlightID do
    if VDlightIDtype[i] == "VDHcol" then
      if VDrefreshType[i] == "B" then
        fibaro:call(VDlightID[i], "pressButton", "5");
        fibaro:sleep(50);
      end
      VDhueAmbilight[i] = fibaro:getValue(VDlightID[i], "ui.sldHue.value");
      VDsatAmbilight[i] = fibaro:getValue(VDlightID[i], "ui.sldSaturation.value");
      if lightdebug then logbug("yellow", "VDHcol - HUE color ambience light ambi setting stored") end;
    elseif VDlightIDtype[i] == "VDHwha" then
      if VDrefreshType[i] == "B" then
        fibaro:call(VDlightID[i], "pressButton", "4");
        fibaro:sleep(50);
      end
      VDctAmbilight[i] = fibaro:getValue(VDlightID[i], "ui.sldCt.value");
      if lightdebug then logbug("yellow", "VDHwha - HUE white ambience light ambi setting stored") end;
    elseif VDlightIDtype[i] == "VDHcst" then
      if checkCustomVD() then
        if VDrefreshType[i] == "B" then
          fibaro:call(VDlightID[i], "pressButton", VDrefreshButton);
          fibaro:sleep(50);
        end
        VDhueAmbilight[i] = fibaro:getValue(VDlightID[i], VDcolorSlider);
        VDsatAmbilight[i] = fibaro:getValue(VDlightID[i], VDsaturationSlider);
        if lightdebug then logbug("yellow", "VDHcst - custom HUE VD light ambi setting stored") end;
      end
    elseif VDlightIDtype[i] == "PlugIn" then
      VDhueAmbilight[i] = fibaro:getValue(VDlightID[i], "ui.Hue.value");
      VDsatAmbilight[i] = fibaro:getValue(VDlightID[i], "ui.Saturation.value");
      if lightdebug then logbug("yellow", "PlugIn - HUE color ambience light ambi setting stored") end;
    else
      logbug("red", "Type of HUE VD light not defined. Please check.")
    end
  end
  if deBug then logbug("yellow", "HUE lamps color settings stored in memory") end;
end

-- function that dims low or turns off VD lights
function turnOffVDlight(i, Vdim)
  local check = false; --lights no change
  if lightdebug then logbug("yellow", VDlightIDtype[i].." - HUE light: "..
                            fibaro:getName(VDlightID[i]).." dim set to "..Vdim) end;
 if ((VDlightIDtype[i] == "VDHcol") or (VDlightIDtype[i] == "VDHwha") or (VDlightIDtype[i] == "VDHwbr")) then
    if dimOffAmbilight == "Yes" then
      if VDlightIDtype[i] == "VDHcol" then
        fibaro:call(VDlightID[i], "setSlider", "3", VDhueAmbilight[i]);
        fibaro:call(VDlightID[i], "setSlider", "4", VDsatAmbilight[i]);
      elseif VDlightIDtype[i] == "VHDwha" then
        fibaro:call(VDlightID[i], "setSlider", "3", VDctAmbilight[i]);
      end
    end
    if (tonumber(fibaro:getValue(VDlightID[i], "ui.sldBrightness.value")) ~= Vdim) then
      fibaro:call(VDlightID[i], "setSlider", "2", Vdim);
      check = true;
    end
    if VDrefreshType[i] == "B" then
      if VDlightIDtype[i] == "VDHcol" then
        fibaro:call(VDlightID[i], "pressButton", "5");
      elseif VDlightIDtype[i] == "VHDwha" then
        fibaro:call(VDlightID[i], "pressButton", "4");
      else
        fibaro:call(VDlightID[i], "pressButton", "3");
      end
    end
  elseif VDlightIDtype[i] == "VDHcst" then
    if checkCustomVD() then
      if dimOffAmbilight == "Yes" then
        fibaro:call(VDlightID[i], "setSlider", VDcolorSlider, VDhueAmbilight[i]);
        fibaro:call(VDlightID[i], "setSlider", VDsaturationSlider, VDsatAmbilight[i]);
      end
      if (tonumber(fibaro:getValue(VDlightID[i], customBriSlider)) ~= Vdim) then
        fibaro:call(VDlightID[i], "setSlider", VDbrightnessSlider, Vdim);
        check = true;
      end
      if VDrefreshType[i] == "B" then
        fibaro:call(VDlightID[i], "pressButton", VDrefreshButton);
      end
    end
  else
    if dimOffAmbilight == "Yes" then
      fibaro:call(VDlightID[i], "changeHue", VDhueAmbilight[i]);
      fibaro:call(VDlightID[i], "changeSaturation", VDsatAmbilight[i]);
    end
    if Vdim ~= 0 then
      if (tonumber(fibaro:getValue(VDlightID[i], "ui.brightness.value")) ~= Vdim) then
        fibaro:call(VDlightID[i], "changeBrightness", Vdim);
        check = true;
      end
    else
      if (tonumber(fibaro:getValue(VDlightID[i], "on")) == 1) then
        fibaro:call(VDlightID[i], "turnOff");
        check = true;
      end
    end
  end
    if lightdebug and check then logbug("yellow", "This HUE light status changed") end;
  return check
end

-- function that dims low or turns off dimmer lights
function turnOnOffDIMlight(i, Ddim)
  local check = false;
  if lightdebug then logbug("yellow", "DIMMER light: "..
                            fibaro:getName(DIMlightID[i]).." dim set to "..Ddim) end;
  if Ddim == 0 then
    if (tonumber(fibaro:getValue(DIMlightID[i], "value")) > 0 ) then
      fibaro:call(DIMlightID[i], "turnOff");
      check = true;
    end
  else
    if (fibaro:getValue(DIMlightID[i], "value") ~= Ddim) then
      fibaro:call(DIMlightID[i], "setValue", Ddim);
      check = true;
    end
  end
  if lightdebug and check then logbug("yellow", "This DIMMER light status changed") end;
  return check
end

-- function that dims low or turns off RGBW lights
function turnOffRGBWlight(i, Rdim)
  local check = false;
  if lightdebug then logbug("yellow", "RGBW light: "..fibaro:getName(RGBWlightID[i])..
                            " dim set to "..Rdim) end;
  if Rdim == 0 then
    if (tonumber(fibaro:getValue(RGBWlightID[i], "currentProgramID")) > 0 ) then
      fibaro:call(RGBWlightID[i], "turnOff");
      check = true;
    else
      if (tonumber(fibaro:getValue(RGBWlightID[i], "value")) > 0 ) then
        fibaro:call(RGBWlightID[i], "turnOff");
        check = true;
      end
    end
  else
    if ((useRGBWprograms[i] == "Yes") and (dimRGBprogram[i] == "Yes") and
       ((RGBWprogramTime[i] == "") or (RGBWprogramTime[i] == timeOfDayCurrent))) then
      if (tonumber(fibaro:getValue(RGBWlightID[i], "currentProgramID")) ~= (RGBWfavorite[i][currentwday])) then
        if lightdebug then logbug("yellow", "Starting program: "..RGBWfavorite[i][currentwday]) end;
        fibaro:call(RGBWlightID[i], "startProgram", RGBWfavorite[i][currentwday]);
        check = true;
      end
    elseif ((useRGBWcolor[i] == "Yes") and (dimRGBcolor[i] == "Yes")) then
      if lightdebug then logbug("yellow", "Setting color to R="..RGBWcolor[i].R..
                                                          " G="..RGBWcolor[i].G..
                                                          " B="..RGBWcolor[i].B..
                                                          " W="..RGBWcolor[i].W) end;
      fibaro:call(RGBWlightID[i], "setColor", RGBWcolor[i].R, RGBWcolor[i].G, RGBWcolor[i].B, RGBWcolor[i].W);
      fibaro:sleep(100);
      if (tonumber(fibaro:getValue(RGBWlightID[i], "value")) ~= Rdim ) then
        fibaro:call(RGBWlightID[i], "setValue", Rdim);
        check = true;
      end
    else
      if (fibaro:getValue(RGBWlightID[i], "value") ~= Rdim ) then
        if lightdebug then logbug("yellow", "Setting brightness at current color") end;
        fibaro:call(RGBWlightID[i], "setValue", Rdim);
        check = true;
      end
    end
  end
  if lightdebug and check then logbug("yellow", "This RGBW light status changed") end;
  return check
end

-- function that turns off switch lights
function turnOnOffSWTlight(i, Sval)
  local check = false;
  if lightdebug then logbug("yellow", "SWITCH light: "..
                            fibaro:getName(SWTlightID[i]).." value set to "..Sval) end;
  if Sval ~= 0 then
    if (tonumber(fibaro:getValue(SWTlightID[i], "value")) == 0 ) then
      fibaro:call(SWTlightID[i], "turnOn");
      check = true;
    end
  else
    if (tonumber(fibaro:getValue(SWTlightID[i], "value")) > 0 ) then
      fibaro:call(SWTlightID[i], "turnOff");
      check = true;
    end
  end
  if lightdebug and check then logbug("yellow", "This SWITCH light status changed") end;
  return check
end

-- turn off lights in sequence VD, DIMMER, RGBW, SWITCH(RELAY/PLUG)
function turnOffLights(VDdim, DIMdim, RGBdim, SWTval)
  local turnOff = false;
  local dimmOff = false;
  local check   = false;
  local result  = false
  if #VDlightID > 0 then
    if ((dimOffAmbilight == "Yes") and (keepAmbilight == "Yes")) then
      getAmbilight();
    end
    if checkUserSettings(1, VDdim) then
      if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
        for i = 1, #VDlightID do
          if VDdim[i] ~= 0 then dimmOff = true else turnOff = true end;
          result = turnOffVDlight(i, VDdim[i]);
          if result then check = true end;
        end
      else
        if (#VDlightID == #VDholidayFlag) then
          for i = 1, #VDlightID do
            if VDholidayFlag[i] == 0 then
              if VDdim[i] ~= 0 then dimmOff = true else turnOff = true end;
              result = turnOffVDlight(i, VDdim[i]);
              if result then check = true end;
            end
          end
        else
          logbug ("red", "ERROR! VD lights holiday flag is missing. Please correct settings.");
          errFlag = true;
        end
      end
    else
      errFlag = true;
    end
  end
  if #DIMlightID > 0 then
    if checkUserSettings(2, DIMdim) then
      if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
        for i = 1, #DIMlightID do
          if DIMdim[i] ~= 0 then dimmOff = true else turnOff = true end;
          result = turnOnOffDIMlight(i, DIMdim[i]);
          if result then check = true end;
        end
      else
        if (#DIMlightID == #DIMholidayFlag) then
          for i = 1, #DIMlightID do
            if DIMholidayFlag[i] == 0 then
              if DIMdim[i] ~= 0 then dimmOff = true else turnOff = true end;
              result = turnOnOffDIMlight(i, DIMdim[i]);
              if result then check = true end;
            end
          end
        else
          logbug ("red", "ERROR! DIMMER off lights holiday flag is missing. Please correct settings.");
          errFlag = true;
        end
      end
    else
      errFlag = true;
    end
  end
  if #RGBWlightID > 0 then
    if checkUserSettings(3, RGBdim) then
      if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
        for i = 1, #RGBWlightID do
          if RGBdim[i] ~= 0 then dimmOff = true else turnOff = true end;
          result = turnOffRGBWlight(i, RGBdim[i]);
          if result then check = true end;
        end
      else
        if (#RGBWlightID == #RGBWholidayFlag) then
          for i = 1, #RGBWlightID do
            if RGBWholidayFlag[i] == 0 then
              if RGBdim[i] ~= 0 then dimmOff = true else turnOff = true end;
              result = turnOffRGBWlight(i, RGBdim[i]);
              if result then check = true end;
            end
          end
        else
          logbug ("red", "ERROR! RGBW lights holiday flag is missing. Please correct settings.");
          errFlag = true;
        end
      end
    else
      errFlag = true;
    end
  end
  if #SWTlightID > 0 then
    if checkUserSettings(4, SWTval) then
      if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
        for i = 1, #SWTlightID do
          if SWTval[i] == 0 then turnOff = true end;
          result = turnOnOffSWTlight(i, SWTval[i]);
          if result then check = true end;
        end
      else
        if (#SWTlightID == #SWTholidayFlag) then
          for i = 1, #SWTlightID do
            if SWTholidayFlag[i] == 0 then
              if SWTval[i] == 0 then turnOff = true end;
              result = turnOnOffSWTlight(i, SWTval[i]);
              if result then check = true end;
            end
          end
        else
          logbug ("red", "ERROR! SWITCH lights holiday flag is missing. Please correct settings.");
          errFlag = true;
        end
      end
    else
      errFlag = true;
    end
  end
  if check then
    if dimmOff then
      if deBug then logbug("lightgreen", "Dimming lights to low") end;
    else
      if deBug then logbug("lightgreen", "Turning lights Off") end;
    end
  else
    if dimmOff then
      if deBug then logbug("lightgreen", "No action, lights are already dimmed") end;
    else
      if deBug then logbug("lightgreen", "No action, lights are already off") end;
    end
  end
end

-- function to turn on VD lights
function turnOnVDlight(i, Vdim)
  local check = false;
  if lightdebug then logbug("yellow", VDlightIDtype[i].." - HUE light: "..
                            fibaro:getName(VDlightID[i]).." brightness set to "..Vdim) end;
  if ((VDlightIDtype[i] == "VDHcol") or (VDlightIDtype[i] == "VDHwha") or (VDlightIDtype[i] == "VDHwbr")) then
    if ( tonumber(fibaro:getValue(VDlightID[i], "ui.sldBrightness.value")) ~= Vdim ) then
      fibaro:call(VDlightID[i], "setSlider", "2", Vdim);
      check = true;
      if keepAmbilight == "No" then
        if VDlightIDtype[i] == "VDHcol" then
          fibaro:call(VDlightID[i], "setSlider", "3", VDdefaultColor);
          fibaro:call(VDlightID[i], "setSlider", "4", VDdefaultSaturation);
        elseif VDlightIDtype[i] == "VDHwha" then
          fibaro:call(VDlightID[i], "setSlider", "2", VDdefaultColorTemp);
        end
      end
    end
    if VDrefreshType[i] == "B" then
      if VDlightIDtype[i] == "VDHcol" then
        fibaro:call(VDlightID[i], "pressButton", "5");
      elseif VDlightIDtype[i] == "VDHwha" then
        fibaro:call(VDlightID[i], "pressButton", "4");
      else
        fibaro:call(VDlightID[i], "pressButton", "3");
      end
    end
  elseif VDlightIDtype[i] == "VDHcst" then
    if checkCustomVD() then
      if ( tonumber(fibaro:getValue(VDlightID[i], customBriSlider)) ~= Vdim ) then
        fibaro:call(VDlightID[i], "setSlider", VDbrightnessSlider, Vdim);
        check = true;
        if keepAmbilight == "No" then
          fibaro:call(VDlightID[i], "setSlider", VDcolorSlider, VDdefaultColor);
          fibaro:call(VDlightID[i], "setSlider", VDsaturationSlider, VDdefaultSaturation);
        end
      end
      if VDrefreshType[i] == "B" then
        fibaro:call(VDlightID[i], "pressButton", VDrefreshButton);
      end
    end
  elseif VDlightIDtype[i] == "PlugIn" then
    if (tonumber(fibaro:getValue(VDlightID[i], "ui.brightness.value")) ~= Vdim) then
      fibaro:call(VDlightID[i], "changeBrightness", Vdim);
      check = true;
      if keepAmbilight == "No" then
        fibaro:call(VDlightID[i], "changeHue", VDdefaultColor);
        fibaro:call(VDlightID[i], "changeSaturation", VDdefaultSaturation);
      end
    end
    if (tonumber(fibaro:getValue(VDlightID[i], "on")) == 0) then
      fibaro:call(VDlightID[i], "turnOn");
    end
  else
    logbug("red", "ERROR! Philips HUE VD type definition is missing! Please check!");
  end
  if lightdebug and check then logbug("yellow", "This HUE light status changed") end;
  return check
end

-- function to turn on RGBW lights
function turnOnRGBWlight(i, Rdim)
  local check = false;
  if ((useRGBWprograms[i] == "Yes") and (Rdim > 0) and
    ((RGBWprogramTime[i] == "") or (RGBWprogramTime[i] == timeOfDayCurrent))) then
    if (#RGBWfavorite[i] == 7) then
      if lightdebug then logbug("yellow", "RGBW light: "..fibaro:getName(RGBWlightID[i])..
                                " program set to "..RGBWfavorite[i][currentwday]) end;
      if (tonumber(fibaro:getValue(RGBWlightID[i], "currentProgramID")) ~= (RGBWfavorite[i][currentwday])) then
        fibaro:call(RGBWlightID[i], "startProgram", RGBWfavorite[i][currentwday]);
        check = true;
      end
    else
      logbug ("red", "ERROR! RGBW lights weekly program setting invalid. Please correct settings.");
      errFlag = true;
    end
  elseif ((useRGBWcolor[i] == "Yes") and (Rdim > 0)) then
    if lightdebug then logbug("yellow", "RGBW light: "..fibaro:getName(RGBWlightID[i])..
                              " color set to R="..RGBWcolor[i].R..
                                           " G="..RGBWcolor[i].G..
                                           " B="..RGBWcolor[i].B..
                                           " W="..RGBWcolor[i].W) end;
    fibaro:call(RGBWlightID[i], "setColor", RGBWcolor[i].R, RGBWcolor[i].G, RGBWcolor[i].B, RGBWcolor[i].W);
    fibaro:sleep(100);
    fibaro:call(RGBWlightID[i], "setValue", Rdim);
    check = true;
  elseif Rdim > 0 then
    if lightdebug then logbug("yellow", "RGBW light: "..fibaro:getName(RGBWlightID[i])..
                              " brightness set to "..Rdim) end;
    if (tonumber(fibaro:getValue(RGBWlightID[i], "value")) ~= Rdim) then
      fibaro:call(RGBWlightID[i], "setValue", Rdim);
      check = true;
    end
  else
    fibaro:call(RGBWlightID[i], "turnOff");
  end
  if lightdebug and check then logbug("yellow", "This RGBW light status changed") end;
  return check
end

-- turn on lights in sequence VD, DIMMER, RGBW, SWITCH(RELAY/PLUG)
function turnOnLights(VDdim, DIMdim, RGBdim, SWTval)
  local result = false;
  local check  = false;
  if #VDlightID > 0 then
    if dimOffAmbilight == "Yes" then getAmbilight() end;
    if checkUserSettings(1, VDdim) then
      if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
        for i = 1, #VDlightID do
          result = turnOnVDlight(i, VDdim[i]);
          if result then check = true end;
        end
      else
        if (#VDlightID == #VDholidayFlag) then
          for i = 1, #VDlightID do
            if VDholidayFlag[i] == 0 then
              result = turnOnVDlight(i, VDdim[i]);
              if result then check = true end;
            end
          end
        else
          logbug ("red", "ERROR! VD lights holiday flag is missing. Please correct settings.");
          errFlag = true;
        end
      end
    else
      errFlag = true;
    end
  end
  if #DIMlightID > 0 then
    if checkUserSettings(2, DIMdim) then
    if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
      for i = 1, #DIMlightID do
        result = turnOnOffDIMlight(i, DIMdim[i]);
        if result then check = true end;
      end
    else
      if (#DIMlightID == #DIMholidayFlag) then
        for i = 1, #DIMlightID do
          if DIMholidayFlag[i] == 0 then
            result = turnOnOffDIMlight(i, DIMdim[i]);
            if result then check = true end;
          end
        end
      else
        logbug ("red", "ERROR! Dimmer on lights holiday flag is missing. Please correct settings.");
        errFlag = true;
      end
    end
    else
      errFlag = true;
    end
  end
  if #RGBWlightID > 0 then
    if checkUserSettings(3, RGBdim) then
      if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
        for i = 1, #RGBWlightID do
          result = turnOnRGBWlight(i, RGBdim[i]);
          if result then check = true end;
        end
      else
        if (#RGBWlightID == #RGBWholidayFlag) then
          for i = 1, #RGBWlightID do
            if RGBWholidayFlag[i] == 0 then
              result = turnOnRGBWlight(i, RGBdim[i]);
              if result then check = true end;
          end
          end
        else
          logbug ("red", "ERROR! RGBW lights holiday flag is missing. Please correct settings.");
          errFlag = true;
        end
      end
    else
      errFlag = true;
    end
  end
  if #SWTlightID > 0 then
    if checkUserSettings(4, SWTval) then
      if ((useholidayLights == "No") or (fibaro:getGlobalValue(holidayLights) == holidayLightsMapping.Off)) then
        for i = 1, #SWTlightID do
          result = turnOnOffSWTlight(i, SWTval[i]);
          if result then check = true end;
        end
      else
        if (#SWTlightID == #SWTholidayFlag) then
          for i = 1, #SWTlightID do
            if SWTholidayFlag[i] == 0 then
              result = turnOnOffSWTlight(i, SWTval[i]);
              if result then check = true end;
            end
          end
        else
          logbug ("red", "ERROR! SWITCH lights holiday flag is missing. Please correct settings.");
          errFlag = true;
        end
      end
    else
      errFlag = true;
    end
  end
  if check then
    if deBug then logbug("lightgreen", "Turning lights On or changing brightness.") end;
  else
    if deBug then logbug("lightgreen", "Lights are already On.") end;
  end
end

-- after using holiday lights reset HUE lamps to default color
function resetVDColors(VDbright, VDcolor, VDsat, VDct)
  if deBug then logbug("yellow", "Reseting HUE color to default settings") end;
  if #VDlightID > 0 then
    for i = 1, #VDlightID do
      if ((VDlightIDtype[i] == "VDHcol") or (VDlightIDtype == "VDHwha") or (VDlightIDtype == "VDHwbr")) then
        if ( tonumber(fibaro:getValue(VDlightID[i], "ui.sldBrightness.value")) ~= VDbright[i] ) then
          fibaro:call(VDlightID[i], "setSlider", "2", VDbright[i]);
        end
        if VDlightIDtype[i] == "VDHcol" then
          fibaro:call(VDlightID[i], "setSlider", "3", VDcolor);
          fibaro:call(VDlightID[i], "setSlider", "4", VDsat);
        elseif VDlightIDtype[i] == "VDHwha" then
          fibaro:call(VDlightID[i], "setSlider", "3", VDct);
        end
        if VDrefreshType[i] == "B" then
          if VDlightIDtype[i] == "VDHcol" then
            fibaro:call(VDlightID[i], "pressButton", "5");
          elseif VDlightIDtype[i] == "VDHwha" then
            fibaro:call(VDlightID[i], "pressButton", "4");
          else
            fibaro:call(VDlightID[i], "pressButton", "3");
          end
        end
      elseif VDlightIDtype[i] == "VDHcst" then
        if checkCustomVD() then
          if ( tonumber(fibaro:getValue(VDlightID[i], customBriSlider)) ~= VDbright[i] ) then
            fibaro:call(VDlightID[i], "setSlider", VDbrightnessSlider, VDbright[i]);
          end
          fibaro:call(VDlightID[i], "setSlider", VDcolorSlider, VDcolor);
          fibaro:call(VDlightID[i], "setSlider", VDsaturationSlider, VDsat);
          if VDrefreshType[i] == "B" then
            fibaro:call(VDlightID[i], "pressButton", VDrefreshButton);
          end
        end
      elseif VDlightIDtype[i] == "PlugIn" then
        if (fibaro:getValue(VDlightID[i], "ui.brightness.value") ~= VDbright[i]) then
          fibaro:call(VDlightID[i], "changeBrightness", VDbright[i]);
        end
        fibaro:call(VDlightID[i], "changeSaturation", VDsat);
        fibaro:call(VDlightID[i], "changeHue", VDcolor);
        fibaro:call(VDlightID[i], "turnOn");
      end
    end
  end
end

-- check motion sensors and global variables for motion
function checkMotion()
  local motion = false;
  if (StartSource['type'] == 'property') then
    for i = 1, #motionID do
      if tonumber(fibaro:getValue(motionID[i], 'value')) > 0 then
        motion = true;
      end
    end
  elseif (StartSource['type'] == 'global') then
    if ((useGlobalMotion == "Yes") and (#globalMotionID > 0)) then
      for i = 1, #globalMotionID do
        if fibaro:getGlobalValue(globalMotionID[i]) == globalMotionValue then
          motion = true;
        end
      end
    elseif (StartSource['name'] == timeOfDay) then
      motion = false;
    elseif StartSource['name'] == sleepingName then
      if sleepingName ~= "" then
        if fibaro:getGlobalValue(sleepingName) == sleepingMapping.No then
          for i = 1, #motionID do
            if (tonumber(fibaro:getValue(motionID[i], 'value')) > 0) then
              motion = true;
            end
          end
        end
      end
    elseif StartSource['name'] == presentState then
      if fibaro:getGlobalValue(presentState) ~= presentStateMapping.Away then 
        for i = 1, #motionID do
          if (tonumber(fibaro:getValue(motionID[i], 'value')) > 0) then
            motion = true;
          end
        end
      end
    end
  end
  return motion
end

-- check light sensors and calculate averige light level
function checkLux()
  local totalLux   = 0;
  local averigeLux = 0;
  if #luxID > 0 then
    for i = 1, #luxID do
      totalLux = totalLux + tonumber(fibaro:getValue(luxID[i], 'value'));
    end
    averigeLux = math.floor(totalLux / #luxID);
  else
    averigeLux = 50;
  end
  return averigeLux;
end

-- Function that checks conditions to dim or turn off lights
function dimOffLights()
  luxMeas = checkLux();
  if luxMeas < luxMax then
    if dimOff and useDimLow and (presentStateCurrent ~= presentStateMapping.Away) and (sleepingCurrent == sleepingMapping.No) then
      if deBug then logbug("orange", "dimOff = true and useDimLow = true and presentState ~= Away and sleeping = No") end;
      if sleepStateCurrent == sleepStateMapping.Awake then
        if deBug then logbug("orange", "sleepState = Awake, dimming lights low") end;
        turnOffLights(dimVDlow, dimDIMlow, dimRGBlow, valSWTlow);
      elseif keepDimSleep then
        if deBug then logbug("orange", "sleepState = Sleep; keepDimSleep = true, dimming lights low") end;
        turnOffLights(dimVDlow, dimDIMlow, dimRGBlow, valSWTlow);
      else
        if deBug then logbug("orange", "sleepState = Sleep; keepDimSleep = false, turn lights Off") end;
        turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
      end
    else
      if deBug then logbug("orange", "dimOff = false or useDimLow = false or present = Away or sleeping = Yes, turn lights Off") end;
      turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
    end
  else
    if deBug then logbug ("orange", "dimOff and useDimLow = true but Current lux: "..
                          luxMeas.." >= luxMax: "..luxMax.." keep lights Off") end;
        turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
  end
end

-- function to calculate time by adding hours and minutes (positive or negative)
function calculateTime(baseTime, diffHour, diffMinute)
    local origHour, origMinute = string.match(baseTime, "(%d+):(%d+)");
    local newMinute = (origMinute + diffMinute) % 60
    local excessHour = math.floor((origMinute + diffMinute) / 60)
    local newHour = (origHour + diffHour + excessHour) % 24
    return string.format("%02d:%02d", newHour, newMinute)
end

-- function to calculate time by adding or subrtracting a time (HH:MM)
function calculateTimeString(baseTime, duration, operand)
    local diffHour, diffMinute = string.match(duration, "(%d+):(%d+)");
     if operand == "subtract" then
        diffHour = 0 - diffHour;
        diffMinute = 0 - diffMinute;
    end
    return calculateTime(baseTime, diffHour, diffMinute)
end

-- function checks condition of extra timers and if found match keeps ligts On
function checkExtraTimer()
  local check = false;
  if extraTimerEnable then
    if fibaro:getGlobalValue(timerStatus) ~= timerStatusMapping.Off then
      local currentTime  = os.date("%H:%M", os.time());
      if #timerStartTimeName > 0 then
        if ((#timerStartTimeName == #timerDurationTime) and
            (#timerStartTimeName == #timerCheckName) and
            (#timerStartTimeName == #timerCheckValue)) then
            for i = 1, #timerStartTimeName do
              if fibaro:getGlobalValue(timerCheckName[i]) == timerCheckValue[i] then
                if ((timerCheckValue[i] == timerValueMapping.Weekdays)  and (currentwday >= 2 and currentwday <= 6)) or
                   ((timerCheckValue[i] == timerValueMapping.Weekends)  and (currentwday == 1 or  currentwday == 7)) or
                   ((timerCheckValue[i] == timerValueMapping.Monday)    and (currentwday == 2)) or
                   ((timerCheckValue[i] == timerValueMapping.Tuesday)   and (currentwday == 3)) or
                   ((timerCheckValue[i] == timerValueMapping.Wednesday) and (currentwday == 4)) or
                   ((timerCheckValue[i] == timerValueMapping.Thursday)  and (currentwday == 5)) or
                   ((timerCheckValue[i] == timerValueMapping.Friday)    and (currentwday == 6)) or
                   ((timerCheckValue[i] == timerValueMapping.Saturday)  and (currentwday == 7)) or
                   ((timerCheckValue[i] == timerValueMapping.Sunday)    and (currentwday == 1)) then
                   local startTime    = fibaro:getGlobalValue(timerStartTimeName[i]);
                   local duration     = timerDurationTime[i];
                   local endTime      = calculateTimeString(startTime, duration, "add");
                   if currentTime >= startTime and currentTime <= endTime then
                     if deBug and chFlag then logbug("yellow", "Timer : "..timerStartTimeName[i]..
                                                     " - Current: "..currentTime..", Start: "..startTime..
                                                     ", Duration: "..duration..", End: "..endTime) end;
                     check = true;
                   end
                end
              end
            end
        else
          logbug("red", "ERROR! Extra timer settings invalid! Please check settings!");
          errFlag = true;
        end
      end
    end
  end
  if check then chFlag = false end;
  return check
end

-- function checks condition of extra devices and globals and if found match keep ligts On
function checkExtraCondition()
  local extraCondition = false;
  if ((sleepStateCurrent == sleepStateMapping.Awake) or extraDeviceSleep) then
    if #extraDeviceID > 0 then
      for i = 1, #extraDeviceID do
        if tonumber(fibaro:getValue(extraDeviceID[i], "value")) == extraDeviceValue[i] then
          if deBug and exFlag then logbug("lightblue", "Device: "..fibaro:getName(extraDeviceID[i])..
                                          " has value ".. extraDeviceValue[i]..
                                          " and will keep lights On") end;
          extraCondition = true;
        end
      end
    end
  end
  if ((sleepStateCurrent == sleepStateMapping.Awake) or extraPowerSleep) then
    if #extraPowerID > 0 then
      for i = 1, #extraPowerID do
        if tonumber(fibaro:getValue(extraPowerID[i], "power")) > setPower[i] then
          if deBug and exFlag then logbug("lightblue", "Device: "..fibaro:getName(extraPowerID[i])..
                                          " power: "..fibaro:getValue(extraPowerID[i], "power")..
                                          "W is greater than "..setPower[i].."W and will keep lights On") end;
          extraCondition = true
        end
      end
    end
  end
  if ((sleepStateCurrent == sleepStateMapping.Awake) or extraGlobalSleep) then
    if #extraGlobalName > 0 then
      for i = 1, #extraGlobalName do
        if fibaro:getGlobalValue(extraGlobalName[i]) == extraGlobalValue[i] then
          if deBug and exFlag then logbug("lightblue", "Global variable: "..extraGlobalName[i]..
                                          " value is equal to: "..extraGlobalValue[i]..
                                          " and will keep lights On") end
          extraCondition = true;
        end
      end
    end
  end
  if extraCondition then exFlag = false end;
  return extraCondition
end

-- check extra devices to be started
function checkExDevices()
  if #exDeviceID > 0 then
    if ((#exDeviceID == #exDeviceTime) and (#exDeviceID == #exDeviceValue)) then
      for i = 1, #exDeviceID do
        if exDeviceTime[i] == exTimer then
          if exDeviceValue[i] == 400 then
            fibaro:call(exDeviceID[i], "turnOn");
            if deBug then logbug("brown", "turn On: "..fibaro:getRoomNameByDeviceID(exDeviceID[i])..
                                 " "..fibaro:getName(exDeviceID[i])) end;
          elseif exDeviceValue[i] == 0 then    
            fibaro:call(exDeviceID[i], "turnOff");
            if deBug then logbug("brown", "turn Off: "..fibaro:getRoomNameByDeviceID(exDeviceID[i])..
                                 " "..fibaro:getName(exDeviceID[i])) end;
          elseif ((exDeviceValue[i] > 0) and (exDeviceValue[i] <= 100)) then
            fibaro:call(exDeviceID[i], "setValue", exDeviceValue[i]);
            if deBug then logbug("brown", "setValue to: "..tostring(exDeviceValue[i])..
                                 " on "..fibaro:getRoomNameByDeviceID(exDeviceID[i])..
                                 " "..fibaro:getName(exDeviceID[i])) end;
          elseif ((exDeviceValue[i] >= -100) and (exDeviceValue[i] < 0)) then
            fibaro:call(exDeviceID[i], "setValue", math.abs(exDeviceValue[i]));
            fibaro:sleep(100);
            fibaro:call(exDeviceID[i], "turnOn");
            if deBug then logbug("brown", "setValue to: "..tostring(math.abs(exDeviceValue[i]))..
                                 " on "..fibaro:getRoomNameByDeviceID(exDeviceID[i])..
                                 " "..fibaro:getName(exDeviceID[i])) end;
          else
            logbug("red", "ERROR! No device turned on because value is out of range. Please correct.");
            errFlag = true;
          end
        end
      end
    else
      logbug("red", "ERROR! Check ACTIVATE DEVICE setup because time or value is missing!");
      errFlag = true;
    end
  end
  if #exVDeviceID > 0 then
    if ((#exVDeviceID == #exVDeviceTime) and (#exVDeviceID == #exVDeviceButton)) then
      for i = 1, #exVDeviceID do
        if exVDeviceTime[i] == exTimer then
          fibaro:call(exVDeviceID[i], "pressButton", exVDeviceButton[i]);
          if deBug then logbug("brown", "On virtual device: "..fibaro:getName(exVDeviceID[i])..
                               " pressed button "..exVDeviceButton[i]) end;
        end
      end
    else
      logbug("red", "ERROR! Check ACTIVATE VD setup because time or button is missing!");
      errFlag = true;
    end
  end
  if #exSceneID > 0 then
    if (#exSceneID == #exSceneTime) then
      for i = 1, #exSceneID do
        if exSceneTime[i] == exTimer then
          fibaro:startScene(exSceneID[i]);
          if deBug then logbug("brown", "Started scene ID: "..exSceneID[i]) end;
        end
      end
    else
      logbug("red", "ERROR! Check ACTIVATE SCENE setup because time is missing!");
      errFlag = true;
    end
  end
  if #exGlobal > 0 then
    if ((#exGlobal == #exGlobalTime) and (#exGlobal == #exGlobalValue)) then
      for i = 1, #exGlobal do
        if exGlobalTime[i] == exTimer then
          fibaro:setGlobal(exGlobal[i], exGlobalValue[i]);
          if deBug then logbug("brown", "Global var: "..exGlobal[i].." changed value to "..exGlobalValue[i]) end;
        end
      end
    else
      logbug("red", "ERROR! Check CHANGE GLOBAL VARIABLE setup because time or value is missing!");
      errFlag = true;
    end
  end
end

-- check status of the lights and if turned off stop the scene when no motion detected - customBriSlider
function checkLights()
  local check = false;
  if (motion == false and checkLightOff) then
    if #VDlightID > 0 then
      if #VDlightID == #dimVD then
        for i = 1, #VDlightID do
          if VDlightIDtype[i] == "VDHcol" or VDlightIDtype[i] == "VDHwha" or VDlightIDtype[i] == "VDHwbr" then
            if ((tonumber(fibaro:getValue(VDlightID[i], "ui.sldBrightness.value")) == 0) and (dimVD[i] > 0)) then
              if deBug then logbug("grey", "VD HUE light is turned off!") end
              check = true;
            end
          elseif VDlightIDtype[i] == "VDHcst" then
            if ((tonumber(fibaro:getValue(VDlightID[i], customBriSlider)) == 0) and (dimVD[i] > 0)) then
              if deBug then logbug("grey", "Custom VD HUE light is turned off!") end
              check = true;
            end
          elseif VDlightIDtype[i] == "PlugIn" then
            if ((tonumber(fibaro:getValue(VDlightID[i], "on")) == 0) and (dimVD[i] > 0)) then
              if deBug then logbug("grey", "HUE plugin light is turned off!") end
              check = true;
            end
          end
        end
      else
        logbug("red", "ERROR! One of VD lights missing Brightness setting. Please check.");
      end
    end
    if #DIMlightID > 0 then
      if #DIMlightID == #dimDIM then
        for i = 1, #DIMlightID do
          if ((tonumber(fibaro:getValue(DIMlightID[i], "value")) == 0) and (dimDIM[i] > 0)) then
            if deBug then logbug("grey", "DIMlight is turned off!") end
            check = true;
          end
        end
      else
        logbug("red", "ERROR! One of dimmer lights missing Brightness setting. Please check.");
      end
    end
    if #RGBWlightID > 0 then
      if #RGBWlightID == #dimRGB then
        for i = 1, #RGBWlightID do
          if (tonumber(fibaro:getValue(RGBWlightID[i], "currentProgramID")) == 0) then
            if ((tonumber(fibaro:getValue(RGBWlightID[i], "value")) == 0) and (dimRGB[i] > 0)) then
              if deBug then logbug("grey", "RGBWlight is turned off!") end
              check = true;
            end
          end
        end
      else
        logbug("red", "ERROR! One of RGBW lights missing Brightness setting. Please check.");
      end
    end
    if #SWTlightID > 0 then
      if #SWTlightID == #valSWT then
        for i = 1, #SWTlightID do
          if ((tonumber(fibaro:getValue(SWTlightID[i], "value")) == 0) and (valSWT[i] ~= 0)) then
            if deBug then logbug("grey", "SWTlight is turned off!") end
            check = true;
          end
        end
      else
        logbug("red", "ERROR! One of switch lights missing On/Off setting. Please check.");
      end
    end
  end
  if check then
    if deBug then logbug("grey", "Lights are turned off so stop scene from running!") end
  end
  return check;
end

-- function check state of some variables and light levels and if found changed then turns off lights
function checkState()
  local check = false;
  if (fibaro:getGlobalValue(presentState) ~= presentStateCurrent) then
    presentStateCurrent = fibaro:getGlobalValue(presentState);
    if presentStateCurrent == presentStateMapping.Away then
      check = true;
      if deBug then logbug("blue", "State of "..presentState.." is changed to "..
                           presentStateCurrent..", turn lights off & stop scene") end
    else
      if deBug then logbug("blue", "State of "..presentState.." is changed to "..
                           presentStateCurrent..", light state not changed") end
    end  
  end
  if sleepingName ~= "" then
    if (fibaro:getGlobalValue(sleepingName) ~= sleepingCurrent) then
      sleepingCurrent = fibaro:getGlobalValue(sleepingName);
      if fibaro:getGlobalValue(sleepingName) == sleepingMapping.Yes then
        check = true;
        if deBug then logbug("blue", "State of "..sleepingName.." is changed to "..
                         sleepingCurrent..", turn lights off & stop scene") end
      end
    end
  end
  if (fibaro:getGlobalValue(sleepState) ~= sleepStateCurrent) then
    if (motion == false) then
      if deBug then logbug("blue", "State of "..sleepState.." is changed to "..
                           fibaro:getGlobalValue(sleepState)..
                           " and no motion, turn lights off & stop scene") end
      check = true;
    end
  end
  if (fibaro:getGlobalValue(lightState) ~= lightStateCurrent) then
    lightStateCurrent = fibaro:getGlobalValue(lightState);
    check = true;
    if deBug then logbug("blue", "State of "..lightState.." is changed to "..
                         lightStateCurrent..", turn lights off & stop scene") end
  end
  if (checkLux() >= luxMax) then
    check = true;
    if deBug then logbug("blue", "Lux level has changed and is >= than luxMax: "..luxMax..
                         ", turn lights off & stop scene") end
  end
  return check;
end

-- function checks status of selected global variables and if found 
-- changed changes dim level of lights accordingly
function checkLevels()
  local check = false;
  if (fibaro:getGlobalValue(sleepState) ~= sleepStateCurrent) then
    sleepStateCurrent = fibaro:getGlobalValue(sleepState);
    if motion then
      if deBug then logbug("blue", "State of "..sleepState.." is changed to "..
                           fibaro:getGlobalValue(sleepState)..
                           " and motion detected, adjust lights only") end
      check = true;
    end
  end
  if ((useholidayLights == "Yes") and (fibaro:getGlobalValue(holidayLights) ~= holidayLightsCurrent)) then
    holidayLightsCurrent = fibaro:getGlobalValue(holidayLights); -- are holiday lights on
    if deBug then logbug("lightgrey", "State of "..holidayLights.." is changed to "..
                         holidayLightsCurrent..", lights brightness changed") end
    if holidayLightsCurrent == holidayLightsMapping.Off then
      if ((offAmbilight == "No") and (dimAmbilight == "No")) then
        resetVDColors(dimVD, VDdefaultColor, VDdefaultSaturation, VDdefaultColorTemp);
      end
    end
    check = true;
  end
  if ((useIndoorLights == "Yes") and (fibaro:getGlobalValue(indoorLightsDim) ~= indoorLightsCurrent)) then
    indoorLightsCurrent = fibaro:getGlobalValue(indoorLightsDim); -- or we are in the garden or in house
    if deBug then logbug("lightgrey", "State of "..indoorLightsDim.." is changed to "..
                         indoorLightsCurrent..", lights brightness changed") end
    check = true;
  end
  if ((useProjectorState == "Yes") and (fibaro:getGlobalValue(projectorState) ~= projectorStateCurrent)) then
    projectorStateCurrent = fibaro:getGlobalValue(projectorState); -- or we watching TV
    if deBug then logbug("lightgrey", "State of "..projectorState.." is changed to "..
                         projectorStateCurrent..", lights brightness changed") end
    check = true;
  end
  if ((useCookingState == "Yes") and (fibaro:getGlobalValue(cookingState) ~= cookingStateCurrent)) then
    cookingStateCurrent = fibaro:getGlobalValue(cookingState); -- or we are cooking
    if deBug then logbug("lightgrey", "State of "..cookingState.." is changed to "..
                         cookingStateCurrent..", lights brightness changed") end
    check = true;
  end
  if ((useMealState == "Yes") and (fibaro:getGlobalValue(mealState) ~= mealStateCurrent)) then
    mealStateCurrent = fibaro:getGlobalValue(mealState); -- or we are eating
    if deBug then logbug("lightgrey", "State of "..mealState.." is changed to "..
                         mealStateCurrent..", lights brightness changed") end
    check = true;
  end
  if ((useCinemaState == "Yes") and (fibaro:getGlobalValue(cinemaState) ~= cinemaStateCurrent)) then
    cinemaStateCurrent = fibaro:getGlobalValue(cinemaState); -- or we watching TV
    if deBug then logbug("lightgrey", "State of "..cinemaState.." is changed to "..
                         cinemaStateCurrent..", lights brightness changed") end
    check = true;
  end
  if ((useGuestState == "Yes") and (fibaro:getGlobalValue(guestState) ~= guestStateCurrent)) then
    guestStateCurrent = fibaro:getGlobalValue(guestState); -- or we have guests
    if deBug then logbug("lightgrey", "State of "..guestState.." is changed to "..
                         guestStateCurrent..", lights brightness changed") end
    check = true;
  end
  if ((useTimeOfDay == "Yes") and (fibaro:getGlobalValue(timeOfDay) ~= timeOfDayCurrent)) then
    timeOfDayCurrent = fibaro:getGlobalValue(timeOfDay);
    if dimOff then
      dimOffLevels();
      if deBug then logbug("lightgrey", "State of "..timeOfDay.." is changed to "..
                           timeOfDayCurrent..", lights dimOff level changed") end
    end
    if deBug then logbug("lightgrey", "State of "..timeOfDay.." is changed to "..
                         timeOfDayCurrent..", lights brightness changed") end
    check = true;
  end
  if sleepingName ~= "" then
    if (fibaro:getGlobalValue(sleepingName) ~= sleepingCurrent) then
      sleepingCurrent = fibaro:getGlobalValue(sleepingName);
      if fibaro:getGlobalValue(sleepingName) == sleepingMapping.No then
        check = true;
        if deBug then logbug("lightgrey", "State of "..sleepingName.." is changed to "..
                         sleepingCurrent..", turn lights On") end
      end
    end
  end
  return check;
end

function endScene()
  logbug ("green", "STOP - Very Smart Lights scene");
  fibaro:abort();
end

--- MAIN CODE PART ------------------------------------------------------------------------
logbug ("green", "START - Very Smart Lights scene version "..version.." - (c) 2016 Sankotronic");
-- get current state of the global variables
getCurrentState();
-- If triggered by motion sensor or golobal variable then do the thing
luxMeas = checkLux();
motion  = checkMotion();
-- set dimOff levels if using
if dimOff and not motion then dimOffLevels() end;

-- MAIN LOOP -------------------------------------------------------------------------------
if (StartSource['type'] == 'property') or (StartSource['type'] == 'global') then
  -- execute only when briched and when state change to safe then skip
  if motion then
    -- if we are at home or on holidays then turn on lights
    if (fibaro:getGlobalValue(presentState) ~= presentStateMapping.Away) then
    -- If lights are in auto mode and light level low or it is dark then turn light on
    if ((fibaro:getGlobalValue(lightState) == lightStateMapping.Auto) and 
       (sleepingCurrent == sleepingMapping.No) and 
       ((fibaro:getGlobalValue(darkness) == darknessMapping.Dark) or (luxMeas < luxMin))) then
      if StartSource['type'] == 'property' then
        if deBug then logbug("cyan", "Trigger by "..fibaro:getRoomNameByDeviceID(StartSource['deviceID'])..
                             " "..fibaro:getName(StartSource['deviceID'])..
                             ". Current lux:"..luxMeas.." < luxMin: "..luxMin.." turn lights On") end;
      else
        if deBug then logbug("cyan", "Trigger by global "..StartSource['name']..
                             ". Current lux:"..luxMeas.." < luxMin: "..luxMin.." turn lights On") end;
      end
      adjustLevels();
      if dimOff then dimOffLevels() end;
      -- scene main loop
      while true do
        -- Check sensors or global variable for movement
        motion = checkMotion();
        extraC = checkExtraCondition();
        extraT = checkExtraTimer();
        -- if any of sensors triggered or extra condition state is active reset countdown
        if motion or extraC or extraT then
          if ((duration - PIRwindowTime) <= 0) then
            countdown = PIRwindowTime
            if duration < PIRwindowTime then
              logbug("orange", "WARNING! Light duration set shorter than PIRwindowTime = "..PIRwindowTime..". Please correct.");
            end
          else    
            countdown = duration - PIRwindowTime;
          end
        end
        if timerdeBug then 
          if motion then m="Yes" else m="No" end 
          if extraC then c="Yes" else c="No" end
          if extraT then t="Yes" else t="No" end
          logbug("yellow", "motion = "..m.." extra cond: "..c..
                 " extra timer: "..t.." Countdown = "..countdown.." Duration = "..duration)
        end
        -- if some of the states is changed adjust levels or turn off lights
        chState = checkState();
        chLevel = checkLevels();
        if chState then
          countdown = 0;
        end;
        if chLevel then
          adjustLevels();
        end;
        -- if countdown and light is off then turn it on
        if ( countdown > 0 ) and (chLevel or adjusted) then
          turnOnLights(dimVD, dimDIM, dimRGB, valSWT);
          chLevel  = false;
          adjusted = false;
          fibaro:sleep(300); -- needed to give devices time to report back proper status!
        end
        if countdown > 0 then countdown = countdown - 1 end;
        -- check extra devices, scenes, globals to be started
        if timerdeBug then logbug("lightgray", "exTimer = "..exTimer) end;
        checkExDevices();
        -- exTimer
        exTimer = exTimer + 1;
        -- check lights status and if turned off stop scene
        chLight = checkLights();
        if chLight then
          countdown = 0;
        end;
        if errFlag then
          logbug("red", "There is ERROR in the settings and scene is stopped");
          endScene();
        end
        -- if countdown is ended and light is on then turn it off
        if ( countdown == 0 ) then
          if deBug then logbug("cyan", "Timer reach 0 seconds") end;
          dimOffLights();
          -- Kill running scene cause it is done with light
          endScene();
        end
        fibaro:sleep(1000);
      end
    else
      -- if motion is breached but lux >= luxMax then turn off light
      if (fibaro:getGlobalValue(lightState) == lightStateMapping.Auto) then
        luxMeas = checkLux();
        if (luxMeas >= luxMax) then
          if deBug then logbug("cyan", "Trigger by "..fibaro:getRoomNameByDeviceID(StartSource['deviceID'])..
                               " "..fibaro:getName(StartSource['deviceID'])..
                               ". Current lux:"..luxMeas.." >= luxMax: "..luxMax.." turn lights Off") end;
          turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
        else
          if StartSource['type'] == 'property' then
            if deBug then logbug("cyan", "Trigger by "..fibaro:getRoomNameByDeviceID(StartSource['deviceID'])..
                                 " "..fibaro:getName(StartSource['deviceID'])..
                                 ". Current lux:"..luxMeas..", luxMin: "..luxMin..", luxMax: "..luxMax..
                                 " light state not changed") end;
          else
            if deBug then logbug("cyan", "Trigger by global "..StartSource['name']..
                                 ". Current lux:"..luxMeas..", luxMin: "..luxMin..", luxMax: "..luxMax..
                                 " light state not changed") end;
          end
        end
      else
        if deBug then logbug("orange", "Lights are in manual mode. No action taken.") end;
      end
      endScene();
    end
    else
      if deBug then logbug("cyan", "Trigger by "..fibaro:getRoomNameByDeviceID(StartSource['deviceID'])..
                           " "..fibaro:getName(StartSource['deviceID']).." present state is "..
                           fibaro:getGlobalValue(presentState).." keep lights turned off") end;
      endScene();
    end
  else
    if (fibaro:getGlobalValue(lightState) == lightStateMapping.Auto) then
      if StartSource['type'] == "property" then
        luxMeas = checkLux();
        if (luxMeas >= luxMax) then
          if deBug then logbug("cyan", "Trigger by "..fibaro:getRoomNameByDeviceID(StartSource['deviceID'])..
                               " "..fibaro:getName(StartSource['deviceID'])..
                               ". Current lux: "..luxMeas.." >= luxMax: "..luxMax.." turn lights Off") end;
          turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
        else
          if deBug then logbug("cyan", "Trigger by "..fibaro:getRoomNameByDeviceID(StartSource['deviceID'])..
                               " "..fibaro:getName(StartSource['deviceID'])..
                               ". Current lux: "..luxMeas..", luxMin: "..luxMin..", luxMax: "..luxMax..
                               " light state not changed") end;
        end
      else
        if ((StartSource['name'] == timeOfDay) or (StartSource['name'] == sleepState)) then
          if (StartSource['name'] == timeOfDay) then
            if deBug then logbug("cyan", "Trigger by global: ".. StartSource['name']..", set to "..
                                 fibaro:getGlobalValue(timeOfDay)..", check dim low status") end;
          else
            if deBug then logbug("cyan", "Trigger by global: ".. StartSource['name']..", set to "..
                                 fibaro:getGlobalValue(sleepState)..", check dim low status") end;
          end
          dimOffLights();
        else
          if (StartSource['name'] == sleepingName) then
            if sleepingName ~= "" then
              if fibaro:getGlobalValue(sleepingName) == sleepingMapping.Yes then
                if deBug then logbug("cyan", "Trigger by global: ".. StartSource['name']..", set to "..sleepingMapping.Yes..
                                     ", turn lights off") end;
                turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
              else
                if deBug then logbug("cyan", "Trigger by global: ".. StartSource['name']..", set to "..sleepingMapping.No..
                                     ", check dim low status") end;
                dimOffLights();
              end
            end
          elseif (StartSource['name'] == presentState) then
            if fibaro:getGlobalValue(presentState) == presentStateMapping.Away then
              if deBug then logbug("cyan", "Trigger by global: ".. StartSource['name']..", set to "..
                                   fibaro:getGlobalValue(presentState)..", turn lights off") end;
              turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
            else
              if deBug then logbug("cyan", "Trigger by global: ".. StartSource['name']..", set to "..
                                   fibaro:getGlobalValue(presentState)..", check dim low status") end;
              dimOffLights();
            end
          end
        end
      end
    else
      if deBug then logbug("orange", "Lights are in manual mode. No action taken.") end;
    end
    endScene();
  end
else
  -- when manually activated then turn off lights
  if deBug then logbug("cyan", "Scene triggered manually, turn lights off") end;
  turnOffLights(VDoff, DIMoff, RGBWoff, SWToff);
  endScene();
end
-- END OF CODE ------------------------------------------------------------
