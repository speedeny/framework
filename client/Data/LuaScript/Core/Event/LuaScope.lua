-- 域

local LuaUpdate = require('Core.Event.LuaUpdate')
local LuaTime = require('Core.Event.LuaTime')
local Debug = require("Define.Debug")


local EVT_ACTIVE = 1
local EVT_UNACTIVE = 2
local EVT_DESTROY = 3

local function getRealTime()
    return os.clock()
end


--- 示例 'globe.functionName.nodeName'
local GLOBALNAME = 'global'

-- 所有事件存储表
local allevent = {}

-- 添加事件监听
local function addListener(name, f)
    local pool = allevent[name]
    if pool == nil then
        pool = {}
        allevent[name] = pool
    end
    table.insert(pool, { EVT_ACTIVE, f } )
end

-- 移除事件监听
local function removeListener(name, f)
    local pool = allevent[name]
    if pool then
        for _, v in ipairs(pool) do
            if v[2] == f then
                v[1] = EVT_DESTROY
                return
            end
        end
    end
end

--- 禁止事件监听
local function senListenerEnable(name, f, enable)
    local pool = allevent[name]
    if pool then
        for _, v in ipairs(pool) do
            if v[2] == f then
                if enable then
                    v[1] = EVT_ACTIVE
                else
                    v[1] = EVT_UNACTIVE
                end
                return
            end
        end
    end
end

--- 清理单个事件池
local function cleanupEvent(pool)
    local len = #pool
    for i=len, 1, -1 do
        local v = pool[i]
        if EVT_DESTROY == v[1] then
            table.remove(pool, i)
        end
    end
end

--- 清理所有的事件池
local function cleanupEvents()
    for _, pool in pairs(allevent) do
        cleanupEvent(pool)
    end
end

---------------------------------------------------------------------

local dbgEvts = {}

--- 派发事件
local function _Fire(name, ...)
    local pool = allevent[name]
    if pool then
        local len = #pool
        for i=1, len do
            local v = pool[i]
            if EVT_ACTIVE == v[1] then
                v[2](...)
            end
        end
    end
end

if Debug.DEBUG_EVENT_PROFILE == 1 then
    local fireFunc = _Fire
    function _Fire(name, ...)
        local e = dbgEvts[name]
        if e == nil then
            e = { fire = 0, respond = 0, name= name }
            dbgEvts[name] = e
        end

        local pool = allevent[name]
        if pool then
            for _, v in ipairs(pool) do
                if EVT_ACTIVE == v[1] then
                    e.respond = e.respond + 1
                end
            end
        end

        e.fire = e.fire + 1

        fireFunc(name, ...)
    end
end

---------------------------------------------------------------------

--- 所有的定时器
local allTimer =
{
    --- [1]:object, [2]:destroyed
}

--- 定时器的更新者
local timerUpdate ={}

--- 内部计时器,用于事件清理等工作
local rtick = 0

--- 清理事件的间隔
local interval = 60

--- 输出事件调试信息 （大于 minCount ） 
local function outputDbgEvtInfo(minCount)
    local pool = {}

    for _, v in pairs(dbgEvts) do
        if v.respond > minCount then
            table.insert(pool, v )
        end
    end

    table.sort(pool, function(a,b)
        return a.respond > b.respond
    end)

    for i=1, 5 do
        local curr= pool[i]
        if curr then
            print(string.format("%d. name=%s, fire=%d, respond=%d, respond per frame=%d",
                i, curr.name, curr.fire, curr.respond, math.ceil(curr.respond / interval)))
        end
    end
end

local function cleanupTimer()
    local len = #allTimer
    for i = len, 1, -1 do
        local tm = allTimer[i]
        if tm[2] then
            table.remove(allTimer, i)
        end
    end
end

function timerUpdate:UpdateRealtime()
    for _, tm in ipairs(allTimer) do
        if not tm[2] then
            tm[1]:UpdateRealtime()
        end
    end
end

function timerUpdate:Update()
    for _, tm in ipairs(allTimer) do
        if not tm[2] then
            tm[1]:Update()
        end
    end

    --- 每隔一段时间(2秒), 需要清理事件
    rtick = rtick + 1
    if rtick >= interval then
        rtick = 0

        cleanupEvents()
        cleanupTimer()

        if Debug.DEBUG_EVENT_PROFILE == 1 then
            outputDbgEvtInfo(10)
            dbgEvts = {}
        end
    end
end

LuaUpdate.RegisterUpdater(timerUpdate, "LuaScope")

local function removeTimer(tm)
    for _,v in ipairs(allTimer) do
        if v[1] == tm then
            v[2] = true
            return
        end
    end
end

---------------------------------------------------------------------

--- 域
local scope = {}
scope.__index = scope


--- 根据路径创建域
local function CreateNew(name)
    return setmetatable( { name=name, events={}, childs={}, timerCount=0 }, scope)
end

--- 添加监听函数
function scope:Listen(name, f)
    addListener(name, f)
    table.insert(self.events, {name=name, f=f})
end


--- 清除此域 -移除事件监听 -移除计时器
function scope:Clear()
    for _, v in pairs(self.childs) do
        v:Clear()
    end
    for _, v in ipairs(self.events) do
        removeListener(v.name, v.f)
    end

    self.events = {}
    self.childs = {}

    if self.timer then
        removeTimer(self)
        self.timer = nil
    end
end

--- 域的启用/关闭 - 所有子节点 -事件是否可用
function scope:SetEnable(val)
    local enable = val == true
   
    self._enable = enable
    --- 设置字节点
    for _, v in pairs(self.childs) do
        v:SetEnable(enable)
    end
    --- 将事件
    for _, v in ipairs(self.events) do
        senListenerEnable(v.name, v.f, enable)
    end
end

-- 更新域的真实时间
function scope:UpdateRealtime()
    if self.timer and self.timerFun == getRealTime then
        self:Update()
    end
end

--- 更新域的定时器
function scope:Update()
    --- 是否启用
    if self.timer and self._enable ~= false then
        local now = LuaTime.GetTime()
        if self.timerFun then
            now = self.timerFun()
        end

        local len = #self.timer
        for i=len, 1, -1 do
            local timer = self.timer[i]
            if timer.destroyed then
                table.remove(self.timer, i)
            elseif now - timer.curr - timer.inv >= -1e-5 then

                timer.f()

                if self.timer == nil then
                    return
                end

                timer.curr = now
                if timer.times > 0 then
                    timer.times = timer.times - 1
                    if timer.times == 0 then
                        table.remove(self.timer, i)
                    end
                end
            end
        end
    end
end

--- 设置计时器函数
function scope:SetTimerFun(f)
    self.timerFun = f
end

--- 根据创建一个子域
function scope:AddChild(name)
    local child = self.childs[name]
    if nil == child then
        child = CreateNew(name)
        child.parent = self
        self.childs[name] = child
    end
    return child
end

--- 根据名字查找域
function scope:Find(name)
    return self.childs[name]
end

--- 设置定时器 
--  times 次数 == 0 （无限）
--  Inv 间隔时间 单位秒
--  f 每次执行函数
function scope:SetTimer(times, inv, f)
    self.timerCount = self.timerCount + 1
    local now = LuaTime.GetTime()
    if self.timerFun then
        now = self.timerFun()
    end
    local tm = { times = times, inv = (inv or 0), f = f, curr= now, timerId = self.timerCount, destroyed = false }
    if self.timer == nil then
        self.timer = { tm }
        ---  [1] object, [2] destroyed (init=false)
        table.insert(allTimer, { self, false } )
    else
        table.insert( self.timer, tm)
    end
    return self.timerCount
end

--- 清除计时器
function scope:ClearTimer(timerId)
    if self.timer == nil then
        return
    end
    for i, k in ipairs(self.timer) do
        if k.timerId == timerId then
            k.destroyed = true
            break
        end
    end
end

--- 延时调用
--  delay 延时单位秒
function scope:Invoke(delay, f)
    if type(f) ~= "function" then
        Log.Error("Invoke, f ~= function!")
        return
    end

    self:SetTimer(1, delay, f)
end

---------------------------------------------------------------------

--- 全局根域
Global = CreateNew(GLOBALNAME)

--- 根据路径创建域 
local function _Create(path)
    if nil == path then
        return
    end

    local current
    for name in string.gmatch(path, "[^.]+") do
        if current == nil then
            if name ~= GLOBALNAME then
                print("Error ======================= >> Scope Create global name not exsit ")
                return
            else
                current = Global
            end
        else
            current = current:AddChild(name)
        end
    end

    return current
end

--- 创建真实时间域
local function _CreateScopeRealTime(path)
    local current = _Create(path)
    current:SetTimerFun(getRealTime)
    return current
end

local autoId = 1
-- 增加子节点域
local function _AddChild(path, name)
    local parent = _Create(path)
    if parent then
        if name == nil then
            name = string.format("$%d", autoId)
            autoId = autoId + 1
        else
            name = tostring(name)
        end
        return parent:AddChild(name)
    end
end

--- 根据路径名字查找域
local function _Find(path)
    if nil == path then
        return
    end

    local current
    for name in string.gmatch(path, "[^.]+") do
        if current == nil then
            if name ~= GLOBALNAME then
                return
            else
                current = Global
            end
        else
            current = current:Find(name)
            if current == nil then
                return
            end
        end
    end

    return current
end

--- 清除指定的域 （包括子域）
local function _Clear(path)
    local s = _Find(path)
    if s then
        s:Clear()
    end
end

--- 获得所有域信息
local function _report(p, lv, out, total)
    local tb = ""
    for i=1, lv do
        tb = tb.."\t"
    end

    table.insert(out, tb..p.name)

    total.scope = total.scope + 1

    for k,v in pairs(p.events) do
        local str = string.format("%s\t* %s", tb, v.name)
        table.insert(out, str)
        total.count = total.count + 1
    end

    for k,v in pairs(p.childs) do
        _report(v, lv+1, out, total)
    end
end

--- 所有域信息 方便调试打印
local function _GetReport()
    local r = {}
    local total = { count = 0, scope = 0 }
    _report(Global, 0, r, total)
    local str = table.concat(r, '\n')
    local head = string.format("Event=%d, Scope=%d, Timer=%d\n", total.count, total.scope, #allTimer)
    return head..str
end



return {
    Create              = _Create,
    CreateScopeRealTime = _CreateScopeRealTime,
    AddChild            = _AddChild,
    Find                = _Find,
    Clear               = _Clear,
    GetReport           = _GetReport,
    Fire                = _Fire,
}



