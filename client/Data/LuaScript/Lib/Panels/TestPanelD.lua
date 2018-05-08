local Panel = UIPanelMeta("TestPanelD")
Panel.prefabName = "TestPanel_D"
Panel.prefabDepth = 1040
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
	--Eventer.Fire("UIOpenPanel", "TestPanelD", "222")
end

function Panel.VisibleFuction(self, params)
	print("call panel d's VisibleFuction", params)
end

function Panel.PanelFunction(self, params)
	print("call panel d's PanelFunction", params)
end

