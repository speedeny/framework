local Panel = UIPanelMeta("TestPanelA")
Panel.prefabName = "TestPanel_A"
Panel.prefabDepth = 1000
Panel.RESIDENT_PANEL = true

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
	Eventer.Fire("UIOpenPanel", "TestPanelB", "111")
end

function Panel.VisibleFuction(self, params)
	print("call panel a's VisibleFuction", params)
end

function Panel.PanelFunction(self, params)
	print("call panel a's PanelFunction", params)
end

