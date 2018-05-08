local a = DefineUIControl("a")

a.Windows = 
{

}

a.Visible_Events = 
{
	["Visible_Events_a"] = "VisibleFunc",
}

a.Panel_Events = 
{
	["Panel_Events_a"] = "PanelFunc",
}

function a.Func(self)
	print("call a's Func")
	-- body
end

function a.VisibleFunc(self)
	print("call a's VisibleFunc")
	-- body
end

function a.PanelFunc(self)
	print("call a's PanelFunc")
	-- body
end
