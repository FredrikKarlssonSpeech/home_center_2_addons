--[[
%% properties
337 value
336 value
%% events
%% globals
--]]


if (fibaro:countScenes() > 1) then
  fibaro:abort();
end;

local hum = tonumber(fibaro:getValue(337, "value")) ;
local temp =  tonumber(fibaro:getValue(336, "value")) ;

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

function sendNotification()
    fibaro:call(74, "sendDefinedEmailNotification", "369");
    fibaro:call(76, "sendDefinedPushNotification", "369");
end;

if(riskOfMold(hum,temp)) then
    sendNotification();
end;


