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
for k,i in ipairs(devices) do
    deviceName=string.gsub(fibaro:getName(i), "%s+", "") -- eliminate spaces in devicename
    
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

{"Toaletten":{"Setpointgolvvärmen":464,"Temperaturgolvvärme":465,"Badrummetbelysning":214,"Toalettdörrnere":181,"Modegolvvärme":466},"Alexsovrum":{"Alexelement":203,"Rangeextender":334,"TaklampanAlex":264},"Överstavinden":{"Temperatur":336,"Luftfuktighet":337},"Tvättstugan":{"Taklampan":314,"Elementtvättstugan":166,"Tvättmaskin":279,"Rörelsetvättstugan":379,"Temperatur":380,"Uttagförstrykjärn":373,"Lillalampan":316,"Ljus":381},"Hallen":{"ACMode":49,"Lägegolvvärme":462,"Luxhallen":357,"Rörelsehallen":355,"Ytterdörrenhallen":178,"ACSetpoint":47,"Setpointgolvvärme":460,"ACFanmode":50,"Tempgolvvärme":461,"Temperatur":48,"ACplug":369,"Tempfibaro":356,"Knappviddörren":54},"Vårtsovrum":{"Knappvidsängen":396,"Dimmerfänsterlampa":375,"Elementvårtrum":149,"Taklampa":251,"TVochAppleTV":436},"Unallocated":{"Fredrik":74,"Alva":96,"Veronica":75},"Toalettuppe":{"Setpointgolvvärme":468,"Modegolvvärme":470,"Golvtemp":469,"Belysningtoauppe":62},"Garaget":{"Sidodörrengaraget":388,"Brandvarnaregaraget":353,"Garagetrörelse":32,"Luftfuktighet":35,"Sidodörrtemp":387,"Bildörrengaraget":377,"Taklampan":28,"Belysningarbetsbänk":449,"GaragetTemp":33,"Garagetljus":34},"Skrivar-förrådet":{"Dörrskrivarförrådet":243,"VäckNAS":486,"Routerochskrivare":441,"Tempskrivarförrådet":242,"Lyseskrivaren":227},"Vardagsrummetnere":{"Sensorvidkaminen":476,"Ljusvidsoffan":478,"Tempkaminen":477,"Verandadörren":84,"Lampknappar":412,"Elementvardagnere":147,"Temperaturdörren":82,"Dimmerbrasan":268,"Grönafönsterlampan":288,"Vänstervägglampa":408,"Ljusvardagsrummetn":83,"Brandvarnarenere":300,"Rörelsevardagsrum":183,"Högervägglampa":407,"Alarmvardagsrumn":276},"Vardagsrummetuppe":{"Luftfuktighetupper":126,"Vänsterelementuppe":153,"Högerelementuppe":155,"Lampornavidsoffan":482,"Fönsterlampornauppe":323,"Ljusupper":125,"Taklampan":57,"TVochTV-spel":249,"Julbelysninguppe":472,"Temperaturuppe":124,"UVUppe":127,"RörelseUppe":5,"Brandvarnareuppe":304,"Trapplampan":58},"Lillaförrådet":{"Templillaförrådet":175,"Dörrlillaförrådet":173,"Belysninglilla":245},"Theosrum":{"Taklampan":310,"TVochdator":328,"Theoselement":161},"Köksförrådet":{"HC2+värmeslinga":455},"Förrådet":{"Ljusförrådet":392,"Belysningförrådet":451,"Tempförrådet":391,"Sensorförrådet":390},"Köket":{"Ljusstakarnere":474,"Frysen":98,"Läckagediskmaskinen":86,"Elementköket":145,"DiskmaskinenOFF\/ON":88,"Kaffemaskinen":281,"Mikrovågsugn":419,"Kyl":45,"Fönsterlamporna":21,"Ugn":414},"iOS":{"FredriksiPhone":76,"VeronicasiPhone":365,"\"VeronicasiPhone\"":133,"AlvasiPhone":360,"FredriksiPad":95},"VD":{"StyrningAC":484,"Startpåmorgonen":488,"Variablestates":347,"Belysning":485},"Alvassovrum":{"Alvasfjärr":92,"Alvasuttag":400,"Alvaslampa":90,"Alvaselement":151},"Utomhus":{"Ljusbrytareninnergå":446,"Innergårdenbelysnin":447,"Motorvärmaren":193},"Isasrum":{"IsasTV":292,"Isaselement":163,"Isastaklampa":306},"users":{"Veronica":75,"Fredrik":74,"Alva":96,"SuberUser":2}}
