
require("xlua.util")

local Scope = require ("Core.Event.LuaScope")
--local Eventer = require ("Core.Event.Eventer")
_G.Eventer = require ("Core.Event.Eventer")

local luascope = Scope.Create("global.testlua.demo")
luascope:Listen("LUA_TO_CSHARP", function (val, val1, val2)
	print("lua ============= Received LUA_TO_CSHARP From Lua args ", val, val1, val2)
end)

luascope:Invoke(3, function()
	print("Invoke scope function")
	Eventer.Fire("LUA_TO_CSHARP", "a",2,3)


	luascope:SetTimer(3, 1, function()
		print("SetTimer Function Call")
	end)
end)

local csharpscope = Scope.Create("global.testsharp.demo")
csharpscope:Listen("CSHARP_TO_LUA", function (t1, t2, t3)
	 print("lua ============ Received CSHARP_TO_LUA From C# args ", t1, t2, t3)
end)

require("Loader")
--- 5. Project
LoadProject("Define/Project.lua")
LoadProject("Interface/Project.lua")
LoadProject("Core/Project.lua")


LoadProject("Logic/Project.lua")
LoadProject("Lib/Project.lua")

Eventer.Fire("LuaScriptLoaded")

--UIPanelManagerIns:Report()
Eventer.Fire("PanelEvents_Test", "TestPanelA------")
Eventer.Fire("UIOpenPanel", "TestPanelA")
Eventer.Fire("VisibleEvent_Test", "TestPanelA------")

