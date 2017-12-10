

function isDaytime()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "day");
end;