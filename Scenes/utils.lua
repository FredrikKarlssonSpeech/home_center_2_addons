function fibaroDebugTable (t)
    for k, v in pairs(t) do
        fibaro:debug(k.." ".. tostring(v))
    end
end

function debugTable (t)
    for k, v in pairs(t) do
        print(k.." ".. tostring(v))
    end
end

function tableValueExists(tab, value)
  for k,v in pairs(tab) do
    if value == v then
      return true
    end
  end

  return false
end

function keyUnion(t1, t2)
    local outTab = {};
    for k1, v1 in pairs(t1) do
        for k2, v2 in pairs(t2) do
            outTab[k1] = true;
            outTab[k2] = true;
        end
    end
    return(outTab);
end


debugTable(os.date("*t"));

debugTable(os.date("*t",1454093731));

