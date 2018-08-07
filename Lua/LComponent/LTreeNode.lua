LTreeNode = LTreeNode or BaseClass(LItem)

function LTreeNode:__init(gameObject, key)
    self:SetKey(key)
end

function LTreeNode:SetKey(key)
    self.key = key
    self.gameObject.name = "Item" .. key
end

function LTreeNode:InitFromCache(key)
    self:SetKey(key)
end

function LTreeNode:OnClick()
    self.ItemSelectEvent:Fire(self.key, self)
end

-- function LTreeNode:SetData(data)
--     self.data = data
--     self.text.text = data.name
--     local pivot = self.transform.pivot
--     local sizeDelta = self.transform.sizeDelta
--     UtilsUI.SetAnchoredX(self.transform, self.nodeData.depth * 30 + pivot.x * sizeDelta.x)
-- end


-- function LTreeNode:SetPosition(position)
--     local pivot = self.transform.pivot
--     local sizeDelta = self.transform.sizeDelta
--     UtilsUI.SetAnchoredY(self.transform, position.y + (pivot.y - 1) * sizeDelta.y)
-- end
