

function D_Phi(humidity)

    local hum = tonumber(humidity);

    if (hum >= 75 ) then
        -- highest risk level
        D= math.exp(15.53*(math.log(hum/90)));

    elseif (hum > 60 and hum < 75 ) then
        D = (-2.7 + 1.1*(hum / 30));
    else
        D= -0.5;
    end;
    return D;
end;

function D_T(temperature)
    local temp = tonumber(temperature)
    -- here we expand the truth a little bit. In the original report, the definition is given up to 30 degrees C (not 50)
    if (temp >= 0.1 and temp < 50) then
        DT = math.exp(0.74*(math.log(temp/20)));
    elseif temp < 0.1 then
        DT = -0.5;
    end;
    return DT
end;

function D(temperature, humidity)
    local hum = tonumber(humidity);
    local temp = tonumber(temperature);

    if temp > 0.1 then
        D = D_Phi(hum) * D_T(temp);
    else
        D= -0.5;

    end;

    return D;
end;


--- Function that checks whether there is a risk of mold growth, and assessess the level of threat.
-- The calculations are based on temperature and humidity estimates, as well as a rough mathmatical approximation of risk regions.
-- developed from this http://www.penthon.com/wp-content/uploads/2014/08/Mogelriskdiagram.png image.
-- @tparam number hum the humidity percentage, measured at the site where a mold growth risk estimate should be computed.
-- @tparam number temp the temperature at the location where the humidity measure was made.
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

--- Function that helps you determine if the car heater should be started.
-- The function considers the time you need it heated and the temperature outside. 
-- It has two modes of operation, an ECO setting that heats the car not as long, an a normal operation setting. 
-- The function also considers a condition that may block the function from returning TRUE, 
--- which may be any boolean returned from a check of an AWAY variable or something like that.
-- @tparam string readyTime A specification of time when the car should be ready. E.g. "06:15".
-- @tparam number tempOutside The ouside temperature.
-- @tparam boolean eco Should ECO setting (shorter time with heating on) be used.
-- @tparam boolean BLOCKED Should the heater, for some reason, never be turned on?

function timeToStartCarHeater (readyTime, tempOutside, eco, BLOCKED)
    local timeEpoch = tableToEpochtime(timestringToTable(readyTime));
    local now = os.time();
    local heaterBLOCKED = BLOCKED or false;
    local startTime = timeEpoch;
    if (eco) then
        if (tempOutside <= -15) then
            -- 2 Hours before time
            startTime = timeEpoch - (3600*2);
        elseif (tempOutside <= -10) then
            -- 1 Hour before time
            startTime = timeEpoch - (3600*1);
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
    return ( (not heaterBLOCKED) and (startTime <= now) and (now <= timeEpoch));
end;


