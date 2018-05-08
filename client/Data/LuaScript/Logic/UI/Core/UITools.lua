local UIHelper  = require "Interface.UIHelper"
local UIMsgBind = require "Core.UIMsgBind"

local UITools = {}
UITools.__index = UITools
setmetatable(UITools, {__index = _G})

function UITools:BindEvents(gameObj, rootObj, Events, class, childCtl, ctlScope)
    if gameObj == nil or type(class) ~= "table" or type(Events) ~= "table" then
        return
    end

    for evtName, pName in pairs(Events) do
        local cb = class[pName]
        if cb then
            if "ButtonClick" == evtName then
                UIMsgBind:BindButtonClickEvent(gameObj, ctlScope, function() cb(rootObj, childCtl) end)            
            elseif "Press" == evtName then
                UIMsgBind:BindPressEvent(gameObj, ctlScope, function(state, x, y) cb(rootObj, state, x, y, childCtl) end)            
            end
        end
    end  
end

function UITools:LoadChild(gameObject, cfg, rootObj, class, ctlScope, parentPanel)
    local typeName = cfg.Type or "GameObject"
    local childCtl = CreateBaseControl(gameObject, typeName, ctlScope, parentPanel)
    if childCtl then        
        self:BindEvents(childCtl.gameObject, rootObj, cfg.Events, class, childCtl, ctlScope)
    end
    return childCtl   
end

function UITools:LoadWindow(pools, gameObject, Windows, rootObj, class, Events, ctlScope, parentPanel)
    if Windows then
        for k, cfg in pairs(Windows) do
            if cfg.Name then
                if cfg.Count then
                    for i = 1, cfg.Count do
                        local name = string.format("%s%d", cfg.Name, i)
                        local child = UIHelper.FindChildByName(gameObject, name)
                        if child then
                            childs[i] = self:LoadChild(child, cfg, rootObj, class, ctlScope, parentPanel)
                        elseif cfg.Dynamic == nil then
                            print(string.format("<color=red>绑定%s的第%d个子控件%s到%s失败,请检查 Prefab: %s</color>",
                                class.__name, i, k, name, gameObject.name))
                        end
                    end
                else
                    local child = UIHelper.FindChildByName(gameObject, cfg.Name)
                    if child then
                        pools[k] = self:LoadChild(child, cfg, rootObj, class, ctlScope, parentPanel)
                    elseif not cfg.Dynamic then
                        print(string.format("<color=red>绑定控件%s之子控件%s到%s失败,请检查 Prefab: %s</color>",
                            class.__name, k, cfg.Name, gameObject.name))
                    end
                end
            else
                print(string.format("<color=red>控件定义非法: [%s], 没有定义子控件的 Name!</color>", class.__name))
            end
        end
    end
    self:BindEvents(gameObject, rootObj, Events, class, nil, ctlScope)
end

function UITools:ListenEvents(parentPanel, class, rootObj, VisibleEvents, PanelEvents)
    if parentPanel == nil then
        return
    end

    if VisibleEvents ~= nil then
        for evtName, fname in pairs(VisibleEvents) do
            local cb = class[fname]
            if type(cb) == "function" then
                parentPanel.visibleScope:Listen(evtName, function(...)
                    cb(rootObj, ...)
                end)
            end
        end
    end

    if PanelEvents ~= nil then
        for evtName, fname in pairs(PanelEvents) do
            local cb = class[fname]
            if type(cb) == "function" then
                parentPanel.panelScope:Listen(evtName, function(...)
                    cb(rootObj, ...)
                end)
            end
        end
    end  
end

function UITools:LoadControl(gameObject, class, Windows, Events, VisibleEvents, ControlEvents, ctlScope, parentPanel)
    local rootObj = class
    local pools = {}
    while true do
        --- controlObject : self在被继承多次后任然保持不变
        --- obj 组件类，可被多次继承
        self:LoadWindow(pools, gameObject, Windows, rootObj, class, Events, ctlScope, parentPanel)
        self:ListenEvents(parentPanel, class, rootObj, VisibleEvents, ControlEvents)
        class = class.__super
        if class == nil then
            break
        end

        Windows = rawget(class, "Windows")
        Events = rawget(class, "Events")
        VisibleEvents = rawget(class, "Visible_Events")
        ControlEvents = rawget(class, "Panel_Events")
    end
    return pools   
end

return UITools