local PanelRecord = {}
PanelRecord.__index = PanelRecord
setmetatable(PanelRecord, {__index = _G})

function PanelRecord:New(panel)
    local obj = setmetatable({}, PanelRecord)
    obj:Initialize(panel)
    return obj
end

function PanelRecord:Initialize(panel)
    --- 面板对象
    self.panel = panel
    --- 上下文,用于保存挡掉(被关闭)的面板的上下文,用来恢复现场
    self.context = {}
end

function PanelRecord:Equal(panel)
    return self.panel == panel
end

function PanelRecord:Hide()
    if self.panel == nil then
        return
    end

    if self.panel.SUSPEND_RESUME_PANEL == true then
        self.panel:Suspend()
        return
    end

    --- 默认销毁面板
    local action = UIOPT_DESTROY
    --- 如果标记为常驻面板, 则隐藏
    if self.panel.RESIDENT_PANEL == true then
        action = UIOPT_HIDE
    end

    local opts=
    {
        action = action,
        animation = UIOPT_NO_ANIMATION,
    }

    self.openArgs = self.panel.openArgs or {}

    if self.panel.GetContext then
        self.context = self.panel:GetContext()
    end
    self.panel:__Close(opts)
end

--- 默认还原的情况下是不播放动画的
local DEFAULT_SHOW_OPTS = { }

function PanelRecord:Show()
    if self.panel == nil then
        return
    end

    if self.panel.SUSPEND_RESUME_PANEL == true then
        self.panel:Resume()
        return
    end

    if self.openArgs ~= nil then
        self.panel:__Open( DEFAULT_SHOW_OPTS,  table.unpack(self.openArgs) )
        if self.panel.SetContext then
            self.panel:SetContext(self.context)
        end
    end
end

return PanelRecord
