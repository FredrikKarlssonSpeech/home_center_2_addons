--[[
%% autostart
%% properties
%% events
%% globals
--]]

--- just a copy of @AutoFrank's scene here
--- https://forum.fibaro.com/index.php?/topic/23942-tutorial-using-a-hometable-to-store-device-and-scene-ids
local debug = true --set to false to stop debug messages

-- HOME TABLE FOR ANYTHING IN ADDITION TO DEVICES, VDs, iOS DEVICES
-- EDIT TO YOUR NEEDS OR KEEP BLANK: jsonHome = {}
jsonHome = {

    users = {
        SuberUser=2,Fredrik=74,Alva=96,Veronica=75
    },
}

-- NO USER EDITS NEEDED BELOW

local function log(str) if debug then fibaro:debug(str); end; end

devices=fibaro:getDevicesId({visible = true, enabled = true}) -- get list of all visible and enabled devices
log("Fill hometable with "..#devices.." devices")

-- FILL THE HOMETABLE WITH ALL VDs, DEVICES AND iOS DEVICES

function string.replace(str, subsTab)
  local outStr = str
  for k,v in pairs(subsTab) do
    outStr=string.gsub(outStr,tostring(k),tostring(v))
  end
  return(outStr)
end

local replacementTab = {["å"]="a",["ä"]="a",["ö"]="o",["Å"]="A",["Ä"]="A",["Ö"]="o"}

for k,i in ipairs(devices) do
    deviceName=string.gsub(fibaro:getName(i), "%s+", "") -- eliminate spaces in devicename
    deviceName=string.replace(deviceName,replacementTab)


    if fibaro:getType(i) == "virtual_device" then -- Add VDs to Hometable
        if jsonHome.VD == nil then -- Add VD to the table
            jsonHome.VD = {}
        end
        jsonHome.VD[deviceName]=i
        log("i="..i..", type="..fibaro:getType(i)..", device="..deviceName)
    elseif fibaro:getType(i) == "iOS_device" then -- Add iOS devices to Hometable
        if jsonHome.iOS == nil then -- Add iOS devices to the table
            jsonHome.iOS = {}
        end
        jsonHome.iOS[deviceName]=i
        log("i="..i..", type="..fibaro:getType(i)..", device="..deviceName)
    else -- Add all other devices to the table
        roomID = fibaro:getRoomID(i)
        if roomID == 0 then
            roomname = "Unallocated"
        else
            roomname=string.gsub(fibaro:getRoomName(roomID), "%s+", "") -- eliminate spaces in roomname
        end
        if jsonHome[roomname] == nil then -- Add room to the table
            jsonHome[roomname] = {}
        end
        jsonHome[roomname][deviceName]=i
        log("i="..i..", type="..fibaro:getType(i)..", device="..deviceName..", room="..roomname)
    end
end



jHomeTable = json.encode(jsonHome)              -- ENCODES THE DATA IN JSON FORMAT BEFORE STORING
fibaro:setGlobal("HomeTable", jHomeTable)       -- THIS STORES THE DATA IN THE VARIABLE
log("global jTable created:")                   -- STANDARD DEBUG LINE TO DISPLAY A MESSAGE
log(jHomeTable)

-- I then like to read back a entry from the table to show that the table didnt get corrupt in the process.

local jT = json.decode(fibaro:getGlobalValue("HomeTable"))  -- REFERENCE TO DECODE TABLE
log(jT.scene.MainScene)                         -- DISPLAY ONE VARIALE
