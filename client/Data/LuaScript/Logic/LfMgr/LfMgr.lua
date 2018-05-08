
local luaScope = require "Core.Event.LuaScope"

local LfMgr = {funcId=0,funcs={}}
LfMgr.__index = LfMgr
setmetatable(LfMgr, {__index = _G})

local function id2f(id, funcs)
    local p = funcs[id]
    if p then
        return p[1]
    end
end

function LfMgr:Initialize()
    self.funcId = 0
    self.funcs = {}
    funcs = self.funcs
    local scope = luaScope.Create("global.event.base")

    scope:Listen("LuaCallback0", function(fid)
        local f = id2f(fid, funcs)
        if f then
            f()
        end
    end)

    scope:Listen("LuaCallback1", function(fid, a1)
        local f = id2f(fid, funcs)
        if f then
            f(a1)
        end
    end)

    scope:Listen("LuaCallback2", function(fid, a1, a2)
        local f = id2f(fid, funcs)
        if f then
            f(a1, a2)
        end
    end)

    scope:Listen("LuaCallback3", function(fid, a1, a2, a3)
        local f = id2f(fid, funcs)
        if f then
            f(a1, a2, a3)
        end
    end)
    self.init = true
    -- body
end

function LfMgr:Bind(f, scopeName)
    if self.init == nil then
        self:Initialize()
    end

    -- if DEBUG_MODE then
    --     if type(scopeName) ~= "string" then
    --         error("LfMgrBind Name Error1:")
    --         return 0
    --     end

    --     if string.find(scopeName, ":") then
    --         error("LfMgrBind Name Error2:")
    --         return 0
    --     end

    --     if type(f) ~= "function" then
    --         error("LfMgrBind Func Error:")
    --         return 0
    --     end
    -- end
    self.funcId = self.funcId + 1
    self.funcs[self.funcId] = { f, scopeName }
    return self.funcId
end

function LfMgr:Clear(scopeName)
    local rm = {}

    for key,v in pairs(self.funcs) do
        if v[2] == scopeName then
            table.insert(rm, key)
        end
    end

    for _, key in ipairs(rm) do
        self.funcs[key] = nil
    end
end

function LfMgr:Report()
    local pools = {}
    local all = 0

    for _, v in pairs(self.funcs) do
        local name = v[2]
        pools[name] = (pools[name] or 0) + 1
        all = all + 1
    end

    local sb = {}
    for name, num in pairs(pools) do
        table.insert(sb, string.format("%s=%d\r\n", name, num))
    end

    print("当前统计报告,总个数="..tostring(all).."\r\n"..table.concat(sb))
end

return LfMgr