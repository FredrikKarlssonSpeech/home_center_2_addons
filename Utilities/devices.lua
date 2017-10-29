


function getBlinds()
	local data ={type =  "com.fibaro.rollerShutter" };
	local devices = fibaro:getDevicesId(data);
	 out ={};
	for k,v in ipairs(devices) do
  		table.insert(out,v);
	end;
  return(out);
end;

--- TODO: Fix this function. Returning only "200"

function getNameOfDevice(id)
  local http = net.HTTPClient()
    http:request("http://127.0.0.1:11111/api/devices/"..tostring(id), {
        options = { method = 'GET', headers = {}, data = '{"id":'..tostring(id)..'}', timeout = 2000 },
          success = function(status)
            
          fibaro:debug(status.status)
          if status.status ~= 200 and status.status ~= 201 then print("failed"); end
          	outData = json.decode(status.data);
        	
        end,
        error = function(err)
          fibaro:debug('[ERROR] ' .. err)
        end
      })

    return(outData);

end;