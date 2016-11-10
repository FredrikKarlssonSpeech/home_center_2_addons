

function getNearby(list,distanceInMeters)
    local http = net.HTTPClient()

    local url = "http://127.0.0.1/api/users"

    http:request(url, 
      {options = {
        method = "GET",
        },
        success = function(response)
            fibaro:debug (response.data)
        end,
        error = function(err)
            fibaro: debug ("Error:" .. err) 
        end})
    fibaro:debug(success);
end;