LTreeNodeDemo_1 = LTreeNodeDemo_1 or BaseClass(LTreeNode)

function LTreeNodeDemo_1:__init(gameObject, key)
    local transform = self.transform
    self.text = UtilsUI.GetText(transform, "Text")
    self.selectGo = transform:Find("Select").gameObject
end

function LTreeNodeDemo_1:SetData(nodeData, commonData)
    self.nodeData = nodeData
    local data = nodeData.data
    self.text.text = data.name .. "value:" .. data.value
    self.selectGo:SetActive(nodeData:GetKey() == commonData)
end
