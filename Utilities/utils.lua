
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
        print(k.." ".. tostring(v));
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


-- debugTable(os.date("*t"));

-- debugTable(os.date("*t",1454093731));

