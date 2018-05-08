local Scope    = require "Core.Event.LuaScope"
local UIHelper = require "Interface.UIHelper"
local UITools  = require "Logic.UI.Core.UITools"
local Eventer  = require ("Core.Event.Eventer")
local LfMgr    = require "Logic.LfMgr.LfMgr"
local GameObject = CS.UnityEngine.GameObject

local ANIMATOR_ROOT_NAME = "AnimatorRoot"
local OPEN_ANIMATION = "Open"
local CLOSE_ANIMATION = "Close"
local AUTO_CLOSE_DELAY_TIME = 5

local UIPanel = {}
UIPanel.__index = UIPanel
setmetatable(UIPanel, { __index = _G })

function UIPanel:_Initialize(name, parent, prefabName)
    self.__parent = parent
    self.gameObject = nil
    self.prefabName = prefabName
    self.name = name
    self.isOpen = false
    self.Context = {}
    self.module = false ---新手引导用，控制弹出界面点击背景是否可以关闭，true为不能关闭
    self.visibleScope = Scope.Create("global.lobby.ui.panel.visible."..self.name)
    self.globalScope  = Scope.Create("global.lobby.ui.panel.global."..self.name)
    self.panelScope   = Scope.Create("global.lobby.ui.panel.panel."..self.name)
    self:_BindEvents("GlobalEvents", self.globalScope)

    self.globalScope:Listen("PanelLoadedAsync", function(panelName, gameObject)
        self:_OnLoadPanelFinished_Async(panelName, gameObject)
    end)
    
    if self.Initialize then
        self:Initialize()
    end
end

function UIPanel:_BindEvents(name, scope)
    local events = rawget(self, name)
    local obj = self
    while true do
        if events then
            for name, funName in pairs(events) do
                local f = self[funName]
                if f then
                    scope:Listen(name, function(...)
                        f(self, ...)
                    end)
                end
            end
        end
        local parent = obj.__super
        if not parent then
            parent = getmetatable(obj)
        end
        if (parent == UIPanel) or (parent == nil) then
            break
        end
        obj = parent
        events = rawget(obj, name)
    end
end

function UIPanel:_CallOnPanelShow()
    if self.OnPanelShow then
        self:OnPanelShow()
    end
end

function UIPanel:PlayAnimation(index)
    -- local aniRoot = self:FindWindow(ANIMATOR_ROOT_NAME)
    -- if aniRoot ~= nil then
    --     return AnimationUtils.PlayClip(aniRoot, index)
    -- end
    return 0
end

function UIPanel:__Open(opts, ...)
    if self:IsOpen() then
        --- 当界面已经被打开的情况下, 不再重复打开
        return
    end

    --- 如果正在关闭中, 则快速将其关闭
    if self.closingOpts ~= nil then
        --print("__DoClose", self.name, 55555)
        self:__DoClose(self.closingOpts)
    end

    self.isOpen = true
    self.module = false

    self.openArgs = {...}

    local val = self:__DoOpen(...)

    if self.gameObject ~= nil and val and opts.animation == UIOPT_PLAY_ANIMATION then
        self.openAnimaTime = self:PlayAnimation(OPEN_ANIMATION)
    end

    if self.OnOpen then
        self:OnOpen(...)
    end

    self:_CallOnPanelShow()

    return true
end


function UIPanel:__DoOpen(...)
    if self:GetVisible() then
        return false
    end

    if self.OnOpenBefore then
        self:OnOpenBefore()
    end

    if nil == self.gameObject then
        if true == self.async then
            print("async load panel is unabled !")
            self:_AsyncLoadPanel()
        else
            self:_LoadPanel()
        end
    else
        self:SetActive(true)
        self.visibleScope:Clear()
        self:_BindEvents("VisibleEvents", self.visibleScope)

        self.panelScope:Clear()
        self:_BindEvents("PanelEvents", self.panelScope)
    end 
    return true
end

function UIPanel:_LoadPanel()
    local gameObject = UIHelper.AddChildPrefab(self.__parent, self.prefabName)
    self:_OnLoadPanelFinished(gameObject)
end


function UIPanel:_AsyncLoadPanel()
    -- 根据 prefabName 异步加载界面预制
    -- UIHelper.AddChildPrefab_Async(self.__parent, self.prefabName, "PanelLoadedAsync")
end

-- 同步加载界面
function UIPanel:_OnLoadPanelFinished(gameObject)
    if nil == gameObject then
        return
    end

    self.gameObject = gameObject
    UIHelper.ChangeUIPanelDepth(self.gameObject, self.prefabDepth or 0)
    self.Controls   = UITools:LoadControl(self.gameObject, self, self.Windows, nil, nil, nil, self.name, self)

    if self.OnPanelLoad then
        self:OnPanelLoad()
    end

    self.visibleScope:Clear()
    self:_BindEvents("VisibleEvents", self.visibleScope)

    self.panelScope:Clear()
    self:_BindEvents("PanelEvents", self.panelScope)
end

-- 异步加载界面结束
function UIPanel:_OnLoadPanelFinished_Async(panelName, gameObject)
    if self.name ~= panelName then
        return
    end

    if nil == gameObject then
        print("async load panel failed, prefabName = "..self.prefabName)
        return
    end

    self.gameObject = gameObject
    self.Controls   = UITools.LoadControl(self.gameObject, self, self.Windows, nil, nil, nil, self.name, self)
    UIHelper.ChangeUIPanelDepth(self.gameObject, self.prefabDepth or 0)

    if self.OnPanelLoad then
        self:OnPanelLoad()
    end

    self.visibleScope:Clear()
    self:_BindEvents("VisibleEvents", self.visibleScope)

    self.panelScope:Clear()
    self:_BindEvents("PanelEvents", self.panelScope)
end

if DEBUG_SHOW_PANEL_OPEN_TIME == 1 then
    local __openf = UIPanel.__Open
    function UIPanel:__Open(...)
        LuaProfile.Start("OpenPanel:"..self.name)
        __openf(self, ...)
        LuaProfile.Stop()
    end
end

function UIPanel:__Close(opts)
    if not self:IsOpen() then
        if opts.action == UIOPT_DESTROY then
            --print("__DoClose", self.name, 66666)
            self:__DoClose(opts)
        end
        return
    end

    self.isOpen = false
    if self.gameObject ~= nil then
        self.closingOpts = opts
        self:__PlayAniAndDoClose(opts)
    end
end

function UIPanel:__DoClose(opts)
    if nil == self.gameObject then
        return
    end 

    if opts.action == UIOPT_DESTROY then
        -- 销毁界面
        self.panelScope:Clear()
        LfMgr:Clear(self.name)
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    else
        -- 隐藏界面
        self:SetActive(false)
    end

    self.closingOpts = nil
    self.visibleScope:Clear()

    if self.OnClose then
        self:OnClose(destroy)
    end    
end

function UIPanel:__PlayAniAndDoClose(opts)
    local playAnimation = opts.animation == UIOPT_PLAY_ANIMATION

    if not playAnimation then
        --print("__DoClose", self.name, 11111)
        self:__DoClose(opts)
        return
    end

    if self.PLAY_CLOSE_ANIMATION ~= true then
        --print("__DoClose", self.name, 22222)
        self:__DoClose(opts)
        return
    end

    local len = self:PlayAnimation(CLOSE_ANIMATION)
    if len < 0.0001 then
        --print("__DoClose", self.name, 33333, len)
        self:__DoClose(opts)
        return
    end

    self.visibleScope:Invoke(len, function()
        --print("__DoClose", self.name, 44444)
        self:__DoClose(opts)
    end)
end

function UIPanel:DestroyPanel()
    Eventer.Fire("UIDestroyPanel", self.__PANEL_NAME)
end

function UIPanel:SetActive(active)
   UIHelper.SetActive(self.gameObject, active == true)
end

function UIPanel:GetVisible()
    if nil ~= self.gameObject then
        UIHelper.GetActive(self.gameObject)
    end
    return false
end

function UIPanel:SetPosition(x, y, z)
    if self.gameObject then
        --self.gameObject.transform.localPosition = Vector3(x,y,z)
    end
end

function UIPanel:SetModule(state)
    self.module = state
end

function UIPanel:IsOpen()
    return self.isOpen
end

function UIPanel:IsStaticPanel()
    return self.STATIC_PANEL == true
end

function UIPanel:IsNormalOrPopupPanel()
    if self.uiPanelType == UIPANEL_TYPE_NORMAL or self.uiPanelType == UIPANEL_TYPE_POPUP then
        return true
    end    
    return false
end

function UIPanel:IsNormalPanel()
    if self.uiPanelType == UIPANEL_TYPE_NORMAL then
        return true
    end
    return false
end

function UIPanel:Resume()
    self:SetActive(true)
    self.visibleScope:SetEnable(true)
    self:_CallOnPanelShow()
end

function UIPanel:Suspend()
    self.visibleScope:SetEnable(false)
    self:SetActive(false)
end

-- 默认都是大厅的界面
local DEFAULT_PROCEDURE_SCOPE =  { "lobby" }

function UIPanel:ProcedureVisible(scopeName)
    local scope = self.procedureScope or DEFAULT_PROCEDURE_SCOPE
    
    for _, name in pairs(scope) do
        if name == scopeName then
            return true
        end
    end
    
    return false
end

function _G.GetBasePanelClass()
    return UIPanel
end