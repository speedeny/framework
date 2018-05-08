local PanelRecord = require "Logic.UI.Core.PanelRecord"

------------------------------------------------------------- PanelLayer -------------------------------------------------------------
local PanelLayer = {}
PanelLayer.__index = PanelLayer
setmetatable(PanelLayer, {__index = _G})

function PanelLayer:New(panel)
    local obj = setmetatable({}, PanelLayer)
    obj:Initialize(panel)
    return obj
end

function PanelLayer:Initialize(panel)
    self.main = PanelRecord:New(panel)
    self.childs = {}
end

function PanelLayer:AddChild(panel)
    local record = PanelRecord:New(panel)
    table.insert(self.childs, record)
end

function PanelLayer:MainPanelEqual(name)
    if self.main.panel ~= nil then
        return self.main.panel.name == name
    end
    return false
end

function PanelLayer:IsEmpty()
    return self.main == nil
end

function PanelLayer:Show()
    if self.main then
        self.main:Show()
    end

    for _, panel in ipairs(self.childs) do
        panel:Show()
    end
end

function PanelLayer:Hide()
    if self.main then
        self.main:Hide()
    end

    for _, panel in ipairs(self.childs) do
        panel:Hide()
    end
end

function PanelLayer:Pop(panel)
    if self.main:Equal(panel) then
        self.main = nil
        return true
    end

    if next(self.childs) ~= nil then
        for i, p in ipairs(self.childs) do
            if p:Equal(panel) then
                table.remove(self.childs, i)
                return true
            end
        end
    end

    return false
end

function PanelLayer:Log()
    local s
    if self.main ~= nil and self.main.panel ~= nil then
        s = "main -"..self.main.panel.name.."\r\n"
    else
        s = "main -\r\n"
    end

    for _, p in ipairs(self.childs) do
        s = s .."  |_ "..p.panel.name.."\r\n"
    end

    s = s .. "\r\n"

    return s
end

------------------------------------------------------------- LayerMgr -------------------------------------------------------------

local LayerMgr = {}
LayerMgr.__index = LayerMgr

function LayerMgr:New()
    local obj = setmetatable({}, LayerMgr)
    obj:Initialize()
    return obj
end

function LayerMgr:Initialize()
    self.layers = {}
    self.holds = {}
end

function LayerMgr:CurrentLayer()
    local len = #self.layers
    return self.layers[len]
end

function LayerMgr:Clear()
    self.layers = {}
end

--- 根节点
function LayerMgr:PushRoot(panel, panelType)
    --print("PushRoot", panel.name)
    local newLayer
    if panelType == UIPANEL_TYPE_NORMAL then
        newLayer = PanelLayer:New(panel)
    elseif panelType == UIPANEL_TYPE_POPUP then
        newLayer = PanelLayer:New(nil)
        newLayer:AddChild(panel)
    end
    self.layers = { newLayer }
end

--- 普通面板
function LayerMgr:PushNormal(panel, panelType)
    --print("PushNormal", panel.name)

    if panelType == UIPANEL_TYPE_NORMAL then
        local lastLayer = self:CurrentLayer()
        if lastLayer ~= nil then
            print("隐藏上一层显示...")
            lastLayer:Hide()
        end
        local currLayer = PanelLayer:New(panel)
        table.insert(self.layers, currLayer)
    elseif panelType == UIPANEL_TYPE_POPUP then
        local layer = self:CurrentLayer()
        layer:AddChild(panel)
    end
end

function LayerMgr:PushPanel(panel)  
    local panelType = panel.uiPanelType or UIPANEL_TYPE_NORMAL
    if panelType == UIPANEL_TYPE_PLUGIN then
        return
    end  

    --print("PushPanel", panel.name)

    if self:CurrentLayer() == nil then
        self:PushRoot(panel, panelType)
    else
        self:PushNormal(panel, panelType)
    end
end

function LayerMgr:CurrentLayerToggle(visible)
    local current = self:CurrentLayer()
    if current ~= nil then
        if visible then
            current:Show()
        else
            current:Hide()
        end
    end
end

function LayerMgr:PopPanel(panel, opts)
    local panelType = panel.uiPanelType or UIPANEL_TYPE_NORMAL
    if panelType == UIPANEL_TYPE_PLUGIN then
        return
    end

    --print("PopPanel", panel.name)

    local layer = self:CurrentLayer()
    if layer == nil then
        return
    end

    local succ = layer:Pop(panel)
    if not succ then
        return
    end

    if not layer:IsEmpty() then
        return
    end

    local len = #self.layers
    table.remove(self.layers, len)


    local lastLayer = self:CurrentLayer()
    if lastLayer ~= nil then
        print("还原上一层显示...")
        lastLayer:Show()
    end
end

function LayerMgr:CloseLobbyPanel()
    self:CurrentLayerToggle(false)

    self.holds = {}
    local panels = UIPanelManagerIns:GetPanels()
    for name, panel in pairs(panels) do
        if panel:IsOpen()                                --- 如果界面是打开的
                and panel:ProcedureVisible("lobby")     --- 如果是大厅界面托管的
                and (not panel:IsStaticPanel())         --- 如果不是静态界面( 静态界面比如Loading界面...)
                and panel:GetVisible() then             --- 如果可见
            panel:Suspend()
            table.insert(self.holds, name)
        end
    end
end

function LayerMgr:OpenLobbyPanel()
    self:CurrentLayerToggle(true)

    for _, name in pairs(self.holds) do
        local panel = UIPanelManagerIns:GetPanel(name)
        if panel ~= nil then
            panel:Resume()
        end
    end
end

function LayerMgr:Log()
    local s = "\r\n"
    for index,layer in ipairs(self.layers) do
        s = s .. tostring(index).."."..layer:Log()
    end
    print(s)
end

function LayerMgr:Remove(name)
    local len = #self.layers
    for i=len, 1, -1 do
        if self.layers[i]:MainPanelEqual(name) then
            table.remove(self.layers, i)
        end
    end
end

return LayerMgr
