-- 过滤向C#发送事件
local unityEvents = 
{
	LUA_TO_CSHARP = true,
}

local f =  CS.LuaEventToCSharp._Fire

local function _SendToCSharp(name, ...)
    if nil ~= unityEvents[name] then
        f(name, ...)
    end
end

return {
	FireEventToCharp = _SendToCSharp,
}

