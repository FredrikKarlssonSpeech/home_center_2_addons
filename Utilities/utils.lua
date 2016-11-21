-- A module that collects general programming utility functions


--- Function that prints out the content of a table within a Fibaro scene as debuging information
-- @tparam table t A table. Only simple tables (not nested) are supported.
function fibaroDebugTable (t)
    for k, v in pairs(t) do
        fibaro:debug(k.." ".. tostring(v));
    end;
end;

--- Function that prints out the content of a table within a ordinary lua environment.
-- @tparam table t A table. Only simple tables (not nested) are supported.
-- @see fibaroDebugTable

function debugTable (t)

    for k, v in pairs(t) do
        if(type(v) == "table") then
            printFun(k.."::\t")
            for kI, vI in pairs(v) do
                if(not debug == nil) then
                    fibaro:debug(kI.." ".. tostring(v1));
                else
                    print(kI.." ".. tostring(v1));
                end;
            end;
        else
            if(not debug == nil) then
                fibaro:debug(k.." ".. tostring(v));
            else
                print(k.." ".. tostring(v));
            end;
        end;
    end;
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
