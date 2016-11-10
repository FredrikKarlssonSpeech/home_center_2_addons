--- I've stolen this function from http://lua-users.org/wiki/LuaXml
-- @tparam String s

function parseargs(s)
  local arg = {}
  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end

function collect(s)
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)(%w+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=parseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[stack.n].label)
  end
  return stack[1]
end

test1 = [[
<?xml version='1.0' encoding='iso-8859-1'?>
<rss version="2.0">
        <channel>
        <title>Temperatur.nu API 1.12  - Din url är inte korrekt signerad, clientnyckeln kan tillfälligt blockeras - /tnu_1.12.php</title>
        <link>http://wiki.temperatur.nu/index.php/Api</link>
        <item>
                <title>Linköping/Centrum</title>
                <id>linkoping</id>
                <temp>9.3</temp>
                <lat>58.414297</lat>
                <lon>15.628788</lon>
                <lastUpdate>2011-11-24 08:51:25</lastUpdate>
                <kommun>Linköping</kommun>
                <lan>Östergötlands län</lan>
                <sourceInfo>Temperaturdata från Stångå Hotell.</sourceInfo>
                <url>http://www.temperatur.nu/linkoping.html</url>
        </item>
        </channel>
</rss>
]]
