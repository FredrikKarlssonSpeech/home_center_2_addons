-- A module that collects general programming utility functions



--- Function that prints out the content of a table.
-- The function works well both within  Fibaro Home center 2 and in an ordinary lua environment.
-- @tparam table node A table. Only simple tables (not nested) are supported.
-- @author Alundaio http://stackoverflow.com/questions/9168058/lua-beginner-table-dump-to-console/42062321#42062321

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

--- Function that checks whether a value exists in a table
-- @tparam table tab The table
-- @tparam string value A value to check for.
-- @treturn boolean A value indicating whether the value existed in the table

function tableValueExists(tab, value)
  for k,v in pairs(tab) do
    if value == v then
      return true;
    end;
  end;
  return false;
end;

local function test_tableValueExists()
  local a = {};
  a[12] = "Tolvan";
  a["13"] = "Tretton";
  assert(tableValueExists(a,"Tolvan") == true,"Tolvan finns" );
  assert(tableValueExists(a,"Tretton") == true,"Tretton finns" );
end;

--- A function that finds the union of keys in two tables
-- @tparam table t1 The first table
-- @tparam table t2 The second table
-- @treturn table A table with keys that are the union (no replication) of keys from the two tables, and will a value 'true' assigned to each key.


function keyUnion(t1, t2)
    local outTab = {};
    for k1, v1 in pairs(t1) do
        for k2, v2 in pairs(t2) do
            outTab[k1] = true;
            outTab[k2] = true;
        end;
    end;
    return(outTab);
end;





--- A function that allows you to create an array containing integers ranging from 'start' to 'stop', optionally spaced by 'step' numbers.
-- @tparam integer start The integer which will be the first (head) of the sequence.
-- @tparam integer stop The integer which will either be the largest in the sequence (the tail) or integer setting the upper boundary for the sequence. In the latter case, the last element in the integer array will be the largets integer x the fullfills (x + 'step') < 'stop'.
-- @tparam integer step The spacing between numbers in the returned sequence.
function seq(start, stop, step)
    local myStep = myStep or 1;
    local out = {};
    local i = start;
    local store = start;
    while (store <= stop) do
        out[i] = store;
        i = i + 1;
        store = store + myStep;
    end;
    return out;
end;

--- Utility function that changes keys to values and vise versa for a table.
-- @tparam table t The table to be inverted.
-- @treturn table A table where all the keys in t has become values (and the oposite).
function tableToTable (t)
    local out = {}
    for k, v in pairs(t) do
        out[tostring(v)] = k;
    end;
    return out;
end;

--- A simple utility function which checks whether a value exists within an array
-- @tparam table tab the array.
-- @param value the value to check the presence of.
-- @treturn boolean is the value present in 'tab'?
-- @usage a={};table.insert(a,10);
-- @usage print(arrayContainsValue(a,10));
-- @usage print(arrayContainsValue(a,120));
function arrayContainsValue(tab, value)
    for k,v in pairs(tab) do
        if tostring(v) == tostring(value) then
            return(true);
        end;
    end;
    return(false);
end;


--- A simple utility function which checks whether a key exists in an array
-- @tparam table tab the array.
-- @param key the value to check the presence of.
-- @treturn boolean is the value present in 'tab'?
-- @usage a={};a["10"]=90;a["20"]=80;
-- @usage print(arrayContainsKey(a,10));
-- @usage print(arrayContainsKey(a,120));
function arrayContainsKey(tab, key)
    for k,v in pairs(tab) do
        if tostring(k) == tostring(key) then
            return(true);
        end;
    end;
    return(false);
end;

--- This utility function manages the loading of content from a HomeTable variable
-- @tparam string variableName an optional name of a variable from which the structure should be collected.
-- @treturn table a nested structure containing the HomeTable information.
-- @treturn boolean return value is false if the function fails to load any information, or the HomeTable is empty.
function loadHomeTable (variableName)
    local var = tostring(variableName) or "HomeTable";
    local jT = json.decode(fibaro:getGlobalValue(var));
    -- Check what we got
    if jT == {} then
        fibaro:debug("Could not load content from the HomeTable variable \'".. var .. "\'. Please make sure the variable exists.");
        return(false);
    else
        fibaro:debug("Got HomeTable");
        return(jT);
    end;
end;
