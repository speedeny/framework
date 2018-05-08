local Scope     = require "Core.Event.LuaScope"
local UIPanel   = require 'Logic.UI.Core.UIPanel'
local LayerMgr  = require "Logic.UI.Core.PanelLayer"
local Eventer   = require 'Core.Event.Eventer'
local UIHelper = require "Interface.UIHelper"
local GameObject = CS.UnityEngine.GameObject

local UIPanelManager = {}
UIPanelManager.__index = UIPanelManager

function UIPanelManager:New()
    local obj = setmetatable({}, UIPanelManager)
    obj:Initialize()
    return obj
end

function UIPanelManager:BindEvent()
    local initScope = Scope.Create("global.init.ui_manager")

    initScope:Listen("LuaScriptLoaded", function()
        local uiRoot = GameObject.Find("_UI_ROOT")
        if uiRoot == nil then
            Log.Error("Can't find window '_UI_ROOT'!")
        else
            -- 重新设置控件继承关系
            ResetControlMetatable()

            -- 重新设置界面继承关系
            local basePanel = GetBasePanelClass()
            RebuildMetatable(self.panels, basePanel, "UIPanel")

            -- 初始化界面
            for name, panel in pairs(self.panels) do
                panel:_Initialize(name, uiRoot, panel.prefabName)
            end
        end        
    end)

    local uiScope = Scope.Create("global.ui.ui_manager")

    uiScope:Listen("UIOpenPanel", function(name, ...)
        self:__OpenPanel(name, ...)
        --self.layerMgr:Log()
    end)
    
    local FAST_OPEN_PANEL = {}
    uiScope:Listen("UIOpenPanelFast", function(name, args)
        self:__OpenPanelEx(name, FAST_OPEN_PANEL, args)
    end)

    uiScope:Listen("UIDestroyPanel", function(name)
        local opts=
        {
            action = UIOPT_DESTROY,
            animation = UIOPT_PLAY_ANIMATION,
        }
        self:__ClosePanel(name, opts)
        --self.layerMgr:Log()
    end)

    uiScope:Listen("UIDestroyPanelFast", function(name)
        local opts=
        {
            action = UIOPT_DESTROY,
            animation = UIOPT_NO_ANIMATION,
        }
        self:__ClosePanel(name, opts)
    end)

    uiScope:Listen("UIHidePanel", function(name)
        local opts=
        {
            action = UIOPT_HIDE,
            animation = UIOPT_PLAY_ANIMATION,
        }
        self:__ClosePanel(name, opts)
        --self.layerMgr:Log()
    end)

    uiScope:Listen("UICloseAllLobbyPanel", function()
        self:_CloseAllLobbyPanel()
    end)

    --- 清理后台面板
    uiScope:Listen("UIClearBackendPanel", function(name)
        self.layerMgr:Remove(name)
    end)
end

--- 关闭所有的大厅面板
function UIPanelManager:_CloseAllLobbyPanel()
    local opts=
    {
        action = UIOPT_DESTROY,
        animation = UIOPT_NO_ANIMATION,
    }

    --- 清除栈
    self.layerMgr:Clear()

    --- 关闭面板
    for name, panel in pairs(self.panels) do
        if panel:ProcedureVisible("lobby") then
            if panel:IsOpen() and panel:IsNormalOrPopupPanel() then
                self:__ClosePanel(name, opts)
            end
        end
    end
end

function UIPanelManager:Initialize()
    self.panels = {}
    self.dialogs = {}
    self:BindEvent()
    self.layerMgr = LayerMgr:New()
    self.helpMaskPanel = GameObject.Find("_ROOT/_UI_ROOT/_HANDLE_MASK_PANEL")
    self:UnlockPanelHandle()
end

function UIPanelManager:GetPanel(name)
    if name ~= nil then
        return self.panels[name]
    end
    Log.Warning("panel name is nil")
end

function UIPanelManager:IsPanelAllClose(procedureName)
    procedureName = procedureName or "lobby"
    for _, panel in pairs(self.panels) do
        if panel:ProcedureVisible(procedureName) then
            if panel:IsOpen() and panel:IsNormalOrPopupPanel() then
                return false
            end
        end
    end
    return true
end

function UIPanelManager:IsNormalPanelsVisible()
    local procedureName = "lobby"
    for _, panel in pairs(self.panels) do
        if panel:ProcedureVisible(procedureName) then
            if panel:IsOpen() and panel:IsNormalPanel() then
                return true
            end
        end
    end
    return false
end

local DEFAULT_OPEN_OPTS = {animation = UIOPT_PLAY_ANIMATION}

function UIPanelManager:__OpenPanel(name, ...)
    return self:__OpenPanelEx(name, DEFAULT_OPEN_OPTS, ...)
end

function UIPanelManager:__OpenPanelEx(name, opts, ...)
    local panel = self.panels[name]
    if panel == nil then
        return false
    end

    local succ = panel:__Open(opts, ...)
    if succ then
        self.layerMgr:PushPanel(panel)
    else
        Error("open panel faild, "..name)
    end

    return succ
end

function UIPanelManager:IsVisiable(name)
    if self.panels[name] ~= nil then
        return self.panels[name]:GetVisible()
    end

    return false
end

function UIPanelManager:AnyDialogsOpen()
    if next(self.dialogs) then
        return true
    end

    return false
end

function UIPanelManager:CloseAllPanel(exceptionTab)
    for i,v in pairs(self.panels) do
        local exception = false
        if exceptionTab then
            for i, exName in ipairs(exceptionTab) do
                if v.__name == exName then
                    exception = true
                    break
                end
            end
        end

        if not exception and (not v:IsStaticPanel()) and v.gameObject then
            local opts=
            {
                action = UIOPT_DESTROY,
                animation = UIOPT_NO_ANIMATION,
            }
            self:__ClosePanel(v.__PANEL_NAME, opts)
        end
    end
end

function UIPanelManager:HideAllPanel(exceptionTab)
    ---仅隐藏界面，不会清楚界面的状态，剧情对话用
    self.hidePanel = {}
    for _, panel in pairs(self.panels) do
        local exception = false
        if exceptionTab then
            for _, exName in ipairs(exceptionTab) do
                if panel.__name == exName then
                    exception = true
                    break
                end
            end
        end

        --- 收集所有可见的界面
        --- IsOpen的界面,未必可见!
        if (not exception) and (not panel:IsStaticPanel())
                and panel:IsCreated() and panel:GetVisible() then

            panel:SetActive(false)

            table.insert(self.hidePanel, panel)
        end
    end
end

function UIPanelManager:ResumeAllHiddenPanel()
    if self.hidePanel then
        for _, panel in pairs(self.hidePanel) do
            --- 如果该窗口有效,并且是打开状态,则显示
            --- 如果在HideAllPanel的过程中对窗体进行了Close,则不再显示
            if panel:IsCreated() and panel:IsOpen() then
                panel:SetActive(true)
            end
        end
    end
    self.hidePanel = nil
end

function UIPanelManager:__ClosePanel(name, opts)
    local panel = self.panels[name]
    if panel ~= nil then
        panel:__Close(opts)
        self.layerMgr:PopPanel(panel, opts)
        Eventer.Fire("UIPanelChange", name, false)
    end
end

function UIPanelManager:PopErrorCodeBox(code, cb, dialogType)
    -- local content = NetDefine.GetProtoErrorMsg(code)
    -- self:PopMsgBox(content, dialogType or DIALOG_CONFIRM, cb)
end

function UIPanelManager:GetPanels()
    return self.panels
end

local dialogMsgColor = "EEEEEE"

function UIPanelManager:PopDebugMsgBox(content, dialogType, cb, debugMessage)
    self:PopMsgBoxEx(content, dialogType, DEFAULT_OPEN_OPTS, cb, debugMessage)
end

function UIPanelManager:PopMsgBoxEx(content, dialogType, opts, cb, debugMessage)
    content = formatColor(content)

    content = string.format("[%s]%s[-]",dialogMsgColor,content)
    local callback = function(args, result)
        if type(cb) == "function" then
            cb(result)
        end
        Eventer.Fire("Guide_DialogClose")
        for i, v in ipairs(self.dialogs) do
            if v == args then
                table.remove(self.dialogs, i)
                break
            end
        end

        local len = #self.dialogs
        local topArgs = self.dialogs[len]
        if topArgs then
            self:__OpenPanelEx("UIPanelCommonDialog", topArgs.opts, topArgs)
        end
    end

    local args =
    {
        title = "",
        content = content or "",
        dialogType = dialogType,
        cb = callback,
        opts = opts,
        debugMessage = debugMessage,
    }

    local succ = self:__OpenPanelEx("UIPanelCommonDialog", opts, args)

    if true == succ then
        local panel = self:GetPanel("UIPanelCommonDialog")
        Eventer.Fire("Guide_DialogOpen", panel)
        table.insert(self.dialogs, args)
    end
end

function UIPanelManager:PopMsgBox(content, dialogType, cb)
    self:PopMsgBoxEx(content, dialogType, DEFAULT_OPEN_OPTS, cb)
end

function UIPanelManager:ShowLoading(timeOutEvent, timeOut)
    --Eventer.Fire("UIOpenPanel", "UIPanelLoading", timeOutEvent, timeOut)
end

function UIPanelManager:CloseLoading()
    --Eventer.Fire("UICloseLoading")
end

function UIPanelManager:Alert(msg)
    if msg == nil then
        return
    end

    if string.len(msg) == 0 then
        return
    end

    Eventer.Fire("ShowAlertOSD", msg)
end

function UIPanelManager:AlertConfigString(str)
    Eventer.Fire("ShowConfigAlertOSD", str)
end

function UIPanelManager:AlertBox(str, showTime)
    local time = showTime or 2
    Eventer.Fire("ShowAlertMsg", str, time)
end

function UIPanelManager:AlertErrorCode(code, timeOut)
    -- local time = showTime or 2
    -- self:Alert(NetDefine.GetProtoErrorMsg(code), timeOut)
end

function UIPanelManager:LockPanelHandle()
    UIHelper.SetActive(self.helpMaskPanel, true)
end

function UIPanelManager:UnlockPanelHandle()
    UIHelper.SetActive(self.helpMaskPanel, false)
end

function UIPanelManager:PanelIsOpen(name)
    if name ~= nil then
        local panel = self.panels[name]
        if panel ~= nil then
            return panel:IsOpen()
        end
    end
    return false
end

function UIPanelManager:Report()
    for panelName, panel in pairs(self.panels) do
        local s = string.format("************* Report *************: %s <<---- %s",panelName, panel.__base)
        print(s)
    end
end

_G.UIPanelManagerIns = UIPanelManager:New()

function _G.UIPanelMeta(panelName, parentName)
    local panel = UIPanelManagerIns.panels[panelName]
    if panel then
        return panel
    else
        local parent = GetBasePanelClass()
        local panel = {}
        panel.__name  = panelName
        panel.__index = panel
        panel.__base  = parentName or "UIPanel"
        panel.__super = parent
        panel.__PANEL_NAME = panelName
        setmetatable(panel, parent)
        UIPanelManagerIns.panels[panelName] = panel
        return panel    
    end
end