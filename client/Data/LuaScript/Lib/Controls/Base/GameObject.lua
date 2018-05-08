local GameObject = DefineUIControl("GameObject","")

function GameObject.IsNull(self)
    if self.gameObject ~= nil then
        return false
    end
    return true
end

function GameObject.SetVisible(self, v)
    UIHelper.SetActive(self.gameObject, v)
end

function GameObject.GetTransform(self)
    if self.gameObject ~= nil then
        return self.gameObject.transform
    end
end

function GameObject.GetVisible(self)
    return UIHelper.GetActive(self.gameObject)
end

function GameObject.GetCtlScope(self)
    return self.ctlScope
end