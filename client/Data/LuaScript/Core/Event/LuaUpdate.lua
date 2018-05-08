
local LuaTime = require("Core.Event.LuaTime")

local updater = {}
local frame = 0

local function _RegisterUpdater(u, name)
    if u and u.Update then
        name = name or tostring(u)
        table.insert(updater, { u, name } )
    end
end

local function UnregisterUpdater(u)
    local deleteCount = 0
    for i = #updater, 1, -1 do
        local v = updater[i]
        if v[1] == u then
            table.remove(updater, i)
            if deleteCount > 0 then
               print("Error ================== > Register Updater is repeated ! Repeated times is ".. deleteCount)
            end
            deleteCount = deleteCount + 1
        end
    end
end

-- 获得注册的所有对象
local function GetUpdater()
    return updater
end


-- 全局更新LUA事件时间
function _G.LuaUpdate(dt)
    LuaTime.Update(dt)

    frame = frame + 1
    for _, v in ipairs(updater) do
        if v[1].UpdateRealtime then
            v[1]:UpdateRealtime()
        end
    end

    local deltaTime = LuaTime.GetDt()
    for _, v in ipairs(updater) do
        v[1]:Update(deltaTime)
    end

    LuaTime.SetDt(0)
end


return
{
    RegisterUpdater     = _RegisterUpdater,
    UnregisterUpdater   = _UnregisterUpdater,
    GetUpdater          = _GetUpdater,
}


