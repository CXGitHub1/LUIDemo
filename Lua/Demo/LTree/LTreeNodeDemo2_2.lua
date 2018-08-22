LTreeNodeDemo2_2 = LTreeNodeDemo2_2 or BaseClass(LTreeNode)

function LTreeNodeDemo2_2:__init(gameObject, key)
    local transform = self.transform
    self.transform = transform
    self.text = transform:Find("Text"):GetComponent(Text)
    self.selectGo = transform:Find("Select").gameObject
end

function LTreeNodeDemo2_2:SetData(nodeData, commonData)
    self.nodeData = nodeData
    local data = nodeData.data
    self.text.text = data.name .. ":" .. nodeData:GetValue()
    self.selectGo:SetActive(commonData == self.key)
end
