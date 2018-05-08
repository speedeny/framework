
local LuaCallCsharpEvent = require("Core.Event.CSharpEvent").FireEventToCharp
local LuaCallEvent       = require("Core.Event.LuaScope").Fire

local function _FireEvent(...)
   	LuaCallEvent(...)
    LuaCallCsharpEvent(...)
end

-- 提供给C#绑定调用LUA的事件接口
_G.CSharpCallLuaEvent = LuaCallEvent

return 
{
	Fire = _FireEvent,
}












