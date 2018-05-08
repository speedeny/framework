local b = DefineUIControl("b", "a")

b.Windows = 
{

}

b.Visible_Events = 
{
	["Visible_Events_b"] = "VisibleFunc",
}

b.Panel_Events = 
{
	["Panel_Events_b"] = "PanelFunc",
}

function b.Func(self)
	print("call b's Func")
	-- body
end

function b.VisibleFunc(self)
	print("call b's VisibleFunc")
	-- body
end

function b.PanelFunc(self)
	print("call b's PanelFunc")
	-- body
end
