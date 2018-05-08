
local LfMgr = require "Logic.LfMgr.LfMgr"
local UIHelper = CS.UIHelper

local UIMsgBind = {}
UIMsgBind.__index = UIMsgBind
setmetatable(UIMsgBind, {__index = _G})

function UIMsgBind:BindButtonClickEvent(obj, ctlScope, callback)
	local fpalysound = function()
		print("play sound")
	end
    local call = function ()
        fpalysound()
        callback()
    end

    UIHelper.BindClickEvent(obj, LfMgr:Bind(call, ctlScope))
end

function UIMsgBind:BindPressEvent(obj, ctlScope, callback)
    local f = function(state, x, y)
        callback(state, x, y)
    end
    UIHelper.BindPressEvent(obj, LfMgr:Bind(f, ctlScope))
end

function UIMsgBind:BindDragEvent(obj, ctlScope, callback)
    local f = function(x, y)
        callback(x, y)
    end
    UIHelper.BindDragEvent(obj, LfMgr:Bind(f, ctlScope))
end

return UIMsgBind