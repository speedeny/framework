local Panel = UIPanelMeta("TestPanelB")
Panel.prefabName = "TestPanel_B"
Panel.prefabDepth = 1020
--Panel.RESIDENT_PANEL = true
Panel.uiPanelType = UIPANEL_TYPE_POPUP

Panel.Windows = 
{
	Close = 
	{
		--Count = 2,
		Name = "Close",
		Events = 
		{
			ButtonClick = "ClickCloseButton",
		},
	},

	Open = 
	{
		--Count = 2,
		Name = "Open",
		Events = 
		{
			ButtonClick = "ClickOpenButton",
		},
	},
	
}

Panel.VisibleEvents = 
{
	["VisibleEvent_Test"] = "VisibleFuction",
}

Panel.PanelEvents =
{
    ["PanelEvents_Test"] = "PanelFunction",
}

function Panel.OnOpen(self, args)
	print("panel open: "..self.name)
end

function Panel.ClickCloseButton(self, sender)
	self:DestroyPanel()
end

function Panel.ClickOpenButton(self, sender)
	Eventer.Fire("UIOpenPanel", "TestPanelC", "222")
end

function Panel.VisibleFuction(self, params)
	print("call panel b's VisibleFuction", params)
end

function Panel.PanelFunction(self, params)
	print("call panel b's PanelFunction", params)
end

