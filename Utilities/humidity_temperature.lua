

function D_Phi(humidity)

    local hum = tonumber(humidity);

    if (hum >= 75 ) then
        -- highest risk level
        D= math.exp(15.53*(math.log(hum/90)))

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
        DT = math.exp(0.74*(math.log(temp/20)))
    elseif temp < 0.1 then
        DT = -0.5
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