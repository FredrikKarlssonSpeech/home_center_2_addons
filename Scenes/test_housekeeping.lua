
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


function registerHousekeepingTask(deviceIDs, delaySeconds, command )
    local command = command or "turnOff";
    -- handle tuples of the type "{setValue, 20}" by concatenation
    if type(command) == "table" then
        command = tostring(command[1] .. "_" .. command[2]);
    end;
    local timeToSet = (os.time() + delaySeconds);
    -- Reinitiate variable if it is not parable as json and is well structured
    if not pcall(checkHousekeepingIntegrity) then 
        initiateHousekeepingVariable();
    end;
    -- Get data
    local houseVariable = tostring(fibaro:getGlobalValue('HOUSEKEEPING'));
    local parsedVariable = json.decode(houseVariable)  ; 
    -- FOR DEBUG : '{"turnOff":{"10":25,"20":100}}'

    if ( parsedVariable[command] ) then
        -- If the command sublist exist, then just get the list of ID,time pairs stored in it
        devList = parsedVariable[command] ;
    else 
        devList = {};
    end;
    -- now set or insert the new time for the device ID
    -- for a table of IDs 
    if type(deviceIDs) == "table" then
        for i,id in pairs(deviceIDs) do
            devList[id] = timeToSet;
        end;
    else 
        -- in case of a single ID
        devList[deviceIDs] = timeToSet;
    end;
    -- now insert the constructed list into the old one with "command" as key.
    -- old data will be overwritten
    parsedVariable[command] = devList;

    local outString = json.encode(parsedVariable);
    fibaro:debug("Setting Housekeeping tasks: "..outString);
    fibaro:setGlobal('HOUSEKEEPING',outString);
end;


function checkHousekeepingIntegrity()
    local houseVariable = tostring(fibaro:getGlobalValue("HOUSEKEEPING"));
    local parsedVariable = json.decode(houseVariable);
end;

function initiateHousekeepingVariable()
    fibaro:debug("Initiating the variable HOUSEKEEPING to {}")
    local EMPTY = {};
    EMPTY["turnOff"] = {};
    fibaro:setGlobal('HOUSEKEEPING',json.encode(EMPTY))
end;

function printHouseKeeing()
    debugTable(json.decode(tostring(fibaro:getGlobalValue("HOUSEKEEPING"))));
end;

initiateHousekeepingVariable();
registerHousekeepingTask(11,11,"turnOff");

printHouseKeeing()



