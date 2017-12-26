

-- SETUP 
DEFAULT_TIME_OF_DAY = {
	{["days"]={2,3,4,5,6},["time"]="06:30",["tod"]="Morning"},
	{["days"]={1,7},["time"]="06:30",["tod"]="Morning"},
	{["days"]={2,3,4,5,6},["time"]="08:00",["tod"]="Day"},
	{["days"]={1,7},["time"]="10:00",["tod"]="Day"},
	{["days"]={1,2,3,4,5,6,7},["time"]="18:00",["tod"]="Evening"},
	{["days"]={2,3,4,5,6},["time"]="23:30",["tod"]="Night"},
	{["days"]={1,7},["time"]="23:59",["tod"]="Night"}
};

THIS_YEARS_HOLIDAYS = {
    {["name"]="Jul",["start"]="24/12",["end"]="26/12"},
    {["name"]="Nyår",["start"]="31/12",["end"]="1/1"},
    {["name"]="Trettondedag Jul",["start"]="6/1",["end"]="6/1"},
    {["name"]="Påsk",["start"]="2018-03-30",["end"]="2018-04-02"},
    {["name"]="Första Maj",["start"]="1/5",["end"]="1/5"},
    {["name"]="Kristi himmelfärdsdag",["start"]="2018-05-10",["end"]="2018-05-10"},
    {["name"]="Pingstdagen",["start"]="2018-05-20",["end"]="2018-05-20"},
    {["name"]="Sveriges Nationaldag",["start"]="6/6",["end"]="6/6"},
    {["name"]="Midsommar",["start"]="2018-06-23",["end"]="2018-06-23"},
    {["name"]="Alla helgons dag",["start"]="2018-11-03",["end"]="2018-11-03"},
}

function MY_MINUTEWISE_CHECKS()
	setPartsOfWeek();
	setHolidayStates(THIS_YEARS_HOLIDAYS);
	setTimeOfDay(DEFAULT_TIME_OF_DAY);
	setSunState(30);
	--checkLastMovement();
	doHousekeeping();
end; 

---- USER EDITING NOT REQUIRED BEYOND THIS MARK ---- 

-- RUNNING CODE

function runEveryMinute(fun)
    while(true) do
        fun();
        waitUntilNextMinute();
    end;
end;

function waitUntilNextMinute()
    local currSec = os.time() % 60;
    local toWait = 60 - currSec;
    fibaro:sleep(toWait *1000);
end;

-- DATE AND HOLIDAY STUFF

function setHolidayStates(holidayStructure)
    local setValue =tostring(fibaro:getGlobalValue("PartOfWeekToday"));
    if isHoliday(holidayStructure) and setValue ~= "Holiday" then
        fibaro:setGlobal("PartOfWeekToday","Holiday");
    end;
    setValue =tostring(fibaro:getGlobalValue("PartOfWeekTomorrow"))
    if isHolidayTomorrow(holidayStructure) and setValue ~= "Holiday" then
        fibaro:setGlobal("PartOfWeekTomorrow","Holiday");
    end;
end;

function isHoliday(holidayStructure)

    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(today(),hstr["start"],hstr["end"]) then
            return(true);
        end;
    end;
    return(false);
end;

function isHolidayTomorrow(holidayStructure)  
    for k,hstr in pairs(holidayStructure) do
        if isBetweenDates(tomorrow(),hstr["start"],hstr["end"]) then
            return(true);
        end;
    end;
    return(false);
end;

function parseDate (dateString,startOfDay)
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(dateString, "%d+");

    local first = g() ;
    local second = g();
    local third = g() or nil;
    local dateTable = {};
    if first == "" or second == "" then
        return(nil);
    end;
    if third ~= nil then
        -- we have a full date
        dateTable["year"] = first;
        dateTable["month"] = tostring(tonumber(second));
        dateTable["day"] = tostring(tonumber(third));
    else
        dateTable["year"] = os.date("%Y");
        dateTable["month"] = tostring(tonumber(second));
        dateTable["day"] = tostring(tonumber(first));
    end;
    if startOfDay == true then
        dateTable['hour'] = 0;
        dateTable['sec'] = 0;
        dateTable['min'] = 0;
    else
        dateTable['hour'] = 23;
        dateTable['sec'] = 59;
        dateTable['min'] = 59;
    end;

    return(dateTable);
end;


function isBetweenDates (date,startDateString, endDateString)
    local startDateTable = parseDate(startDateString,true);
    local endDateTable = parseDate(endDateString,false);
    local startDateEpoch = tableToEpochtime (startDateTable);
    local endDateEpoch = tableToEpochtime (endDateTable);

    local now = tableToEpochtime(parseDate(date));
    return ( (startDateEpoch <= now ) and (endDateEpoch >= now));
end;

function today()
  return(os.date("%Y-%m-%d",tonumber(os.time())));
end;

function tomorrow()
  return(os.date("%Y-%m-%d",tonumber(os.time()+24*3600)));
end;

--- DAY OF WEEK

function setPartsOfWeek()
	local setPartToday = tostring(fibaro:getGlobal("PartOfWeekToday"));
	local setPartTomorrow = tostring(fibaro:getGlobal("PartOfWeekTomorrow"));
	if isWeekDay() and setPartToday ~= "Weekday" then;
		fibaro:setGlobal("PartOfWeekToday","Weekday");
	else
		fibaro:setGlobal("PartOfWeekToday","Weekend");
	end;

	if isWeekDayTomorrow() and setPartTomorrow ~= "Weekday" then
		fibaro:setGlobal("PartOfWeekTomorrow","Weekday");
	else
		fibaro:setGlobal("PartOfWeekTomorrow","Weekend");
	end;
end;


-- TIME OF DAY

function setTimeOfDay(todStructure)
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and afterTime(str["time"],0) then
			fibaro:debug("Setting TimeOfDay to '".. str["tod"] .. "'")
			fibaro:getGlobalValue("TimeOfDay",str["tod"]);
			return(true);
		end;
	end;
	return(false);
end;

function timestringToTable (time)
    local dateTable = os.date("*t");
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(time, "%d+");

    local hour = g() ;
    local minute = g() or 0;
    local second = g() or 0;
    -- Insert sunset inforation istead
    dateTable["hour"] = hour;
    dateTable["min"] = minute;
    dateTable["sec"] = second;
    return(dateTable);
end;

function tableToEpochtime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end;

--- HOUSEKEEPING THINGS

function checkHousekeepingIntegrity()
    local houseVariable = tostring(fibaro:getGlobalValue("HOUSEKEEPING"));
    local parsedVariable = json.decode(houseVariable);
    for id,cmdList in pairs(parsedVariable) do
        -- check that all keys are interpertable as epoch time stamps 
        if tonumber(id) == nil or fibaro:getGlobal(id) == nil then
            error("The 'id' field must be either a device ID or the name of a global variable!");
        end;

        for k,cmdL in pairs(cmdList) do
            -- Check that the load is a table and that it has the manditory fields
            if type(cmdL) ~= "table" and cmdL["time"] == nil or cmdL["cmd"] == nil then
                error("The command table is not well formed or does not contain manditory fields cmd and time!");
            end;
            -- basic checks of structure:
            -- here we check that the time stamp is a number, and that it is larger than the 
            -- time stamp of the time when the function was written
            -- which is unlikely to be an epoch rep. of a time event that should be executed. 
            if tonumber(cmdL["time"]) == nil or tonumber(cmdL["time"]) <= 1510469428 then
                error("The time field is not a number!");
            end;
            -- Check that commands that require a paramter gets one
            -- commnads I know about are these: 
            local oneArg ={"setValue","setSetpointMode","setMode","setFanMode","setVolume","setInterval","pressButton","setFanMode"};
            if tableValueExists(oneArg,cmdL["cmd"] ) and cmdL["value"] == nil then
                error("The cmd is one that takes one argument, but this is not supplied correctly!");
            end; 
            -- commands that I know have 2 arguments
            -- these should have a "arg1" and "arg2" specification in the command structure
            local twoArgs ={"setThermostatSetpoint","setSlider","setProperty"};
            if tableValueExists(twoArgs,cmdL["cmd"] ) and (cmdL["arg1"] == nil or cmdL["arg2"] == nil) then
                error("The cmd is one that takes two arguments, but they are not supplied correctly!");

            end;
        end       
    end;
end;



function initiateHousekeepingVariable()
    fibaro:debug("Initiating the variable HOUSEKEEPING to {}")
    local EMPTY = {};
    fibaro:setGlobal('HOUSEKEEPING',json.encode(EMPTY))
end;


function registerHousekeepingTask(deviceIDs, delaySeconds, command )
    local command = command or "turnOff";

    local timeToSet = (os.time() + delaySeconds);
    -- Reinitiate variable if it is not parable as json and is well structured
    if not pcall(checkHousekeepingIntegrity) then 
        initiateHousekeepingVariable();
    end;
    -- Get data
    local houseVariable = tostring(fibaro:getGlobalValue('HOUSEKEEPING'));
    local parsedVariable = json.decode(houseVariable)  ; 
    -- make sure that we have an array of device ids.
    if type(deviceIDs) ~= "table" and tonumber(deviceIDs) ~= nil then
        deviceIDs = {deviceIDs};
    else
        error("Please supply integer DEviceID values, either as an array or a single value!");
    end;

    for k,id in pairs(deviceIDs) do
        -- command to be inserted
        local cmdTable = {["time"]=timeToSet};
        cmdTable["cmd"]=command;
        -- This is for one argument commands
        if type(command) == "table" and #command == 2 then
            cmdTable["value"] = command[2];
        end;
        if type(command) == "table" and #command == 3 then
            cmdTable["arg1"] = command[2];
            cmdTable["arg2"] = commant[3];
        end;
        -- now we have only one sceduled command per device id
        parsedVariable[tostring(id)] = cmdTable;
    end;
    -- print and store housekeeping 
    local outString = json.encode(parsedVariable);
    fibaro:debug("Setting Housekeeping tasks: "..outString);
    fibaro:setGlobal('HOUSEKEEPING',outString);
end;


function doHousekeeping()
    if not pcall(checkHousekeepingIntegrity) then 
        fibaro:debug("ERROR: HOUSEKEEPING tasks are not well structured. Performing reset. No taks will be performed, so you need to initiate them again.")
        initiateHousekeepingVariable();
        return(false);
    end;
    -- Get data
    local houseVariable = tostring(fibaro:getGlobalValue('HOUSEKEEPING'));
    fibaro:debug("GOT: " .. houseVariable);
    local parsedVariable = json.decode(houseVariable) ;
    debugTable(parsedVariable) ;
    for id,cmdStruct in pairs(parsedVariable) do
        now = os.time();
        local time = cmdStruct["time"];
        -- check whether the stored execution time is now or has passed.
        if time ~= nil and tonumber(time) <= now then
            -- section for device commands
            if tonumber(id) ~= nil then
                if cmdStruct["cmd"] ~= nil and cmdStruct["arg1"] ~= nil and cmdStruct["arg2"] ~= nil then
                    fibaro:call(tonumber(id),tostring(cmdStruct["cmd"]),tostring(cmdStruct["arg1"]),tostring(cmdStruct["arg2"]));
                elseif cmdStruct["cmd"] ~= nil and cmdStruct["value"] ~= nil then
                    fibaro:call(tonumber(id),tostring(cmdStruct["cmd"]),tostring(cmdStruct["value"]));
                elseif cmdStruct["cmd"] ~= nil then
                    fibaro:call(tonumber(id),tostring(cmdStruct["cmd"]));
                else
                    fibaro:debug("ERROR: The HOUSEKEEPING structure is not well formed. Please check the one associated with time ".. tostring(time));
                    printHousekeeing();
                end;
            else
                -- in this case, the ID is a string, which means that it is a variable
                if cmdStruct["cmd"] ~= nil then
                    local value = tostring(cmdStruct["cmd"]);
                    fibaro:setGlobal(id,value);
                else
                    fibaro:debug("ERROR: The HOUSEKEEPING structure is not well formed. Please check the one associated with time ".. tostring(time));
                    printHousekeeing();
                end;
            end;

            -- Now remove the executed schedule
            parsedVariable[tostring(id)]  = nil;
        end;
    end;
    -- print and store the modified housekeeping scedule
    local outString = json.encode(parsedVariable);
    fibaro:debug("Setting Housekeeping tasks: "..outString);
    fibaro:setGlobal('HOUSEKEEPING',outString);
end;

--- A utility function that may be used for printing the current housekeeping schedule.
function printHousekeeing()
    debugTable(json.decode(tostring(fibaro:getGlobalValue("HOUSEKEEPING"))));
end;

--- DAYLIGHT THINGS

function setSunState(offset,latestSunset)
	local offset = offset or 0;
	local latestSunset = latestSunset or "23:30";
	local sunsetHour = earliest(stringTimeAdjust( tostring(fibaro:getValue(1, "sunsetHour")), offset ),latestSunset);
	local sunriseHour = fibaro:getValue(1, "sunriseHour");
	local nowSet = fibaro:getGlobalValue("SunState");
	if afterTime(sunriseHour, offset) and beforeTime(sunsetHour, -offset) then
		local toSet = "Sun up";
	else
		local toSet = "Sun down";
	end;

	if nowSet ~= toSet then
		-- Of course, this global variable needs to be provided by the user.
		fibaro:setGlobal("SunState",toSet);
	end;
end;

-- UTILITIES


function debugTable(node)
  -- handing two printing functions
  local printFunc = print
  if (fibaro or {}).debug then
    function printFunc(...);
      return fibaro:debug(...);
    end;
  end;
  -- to make output beautiful
  local function tab(amt)
    local str = "";
    for i=1,amt do
      str = str .. "\t";
    end;
    return str;
  end;

  local cache, stack = {},{};
  local depth = 1;
  local output_str = "{\n";

  while true do
    if not (cache[node]) then
      cache[node] = {};
    end;

    local size = 0;
    for k,v in pairs(node) do
      size = size + 1;
    end;

    local cur_index = 1;
    for k,v in pairs(node) do
      if not (cache[node][k]) then
        cache[node][k] = {};
      end;

      -- caches results since we will be recursing child nodes
      if (cache[node][k][v] == nil) then
        cache[node][k][v] = true;

        if (string.find(output_str,"}",output_str:len())) then
          output_str = output_str .. ",\n";
        elseif not (string.find(output_str,"\n",output_str:len())) then
          output_str = output_str .. "\n";
        end;

        local key;
        if (type(k) == "userdata") then
          key = "[userdata]";
        elseif (type(k) == "string") then
          key = "['"..tostring(k).."']";
        else
          key = "["..tostring(k).."]";
        end;

        if (type(v) == "table") then
          output_str = output_str .. tab(depth) .. key .. " = {\n";
          table.insert(stack,node);
          table.insert(stack,v);
          break;
        elseif (type(v) == "userdata") then
          output_str = output_str .. tab(depth) .. key .. " = userdata";
        elseif (type(v) == "string") then
          output_str = output_str .. tab(depth) .. key .. " = '"..v.."'";
        else
          output_str = output_str .. tab(depth) .. key .. " = "..tostring(v);
        end;

        if (cur_index == size) then
          output_str = output_str .. "\n" .. tab(depth-1) .. "}";
        else
          output_str = output_str .. ",";
        end;
      else
        -- close the table
        if (cur_index == size) then
          output_str = output_str .. "\n" .. tab(depth-1) .. "}";
        end;
      end;
      cur_index = cur_index + 1;
    end;

    if (#stack > 0) then
      node = stack[#stack];
      stack[#stack] = nil;
      depth = cache[node] == nil and depth + 1 or depth - 1;
    else
      break;
    end;
  end;
  printFunc(output_str);
end;


--- NOW RUN THE WHOLE THING

runEveryMinute(MY_MINUTEWISE_CHECKS);

