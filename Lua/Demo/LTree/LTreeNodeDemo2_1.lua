LTreeNodeDemo2_1 = LTreeNodeDemo2_1 or BaseClass(LTreeNode)

function LTreeNodeDemo2_1:__init(gameObject, key)
    local transform = self.transform
    self.transform = transform
    self.text = transform:Find("Text"):GetComponent(Text)
    self.selectGo = transform:Find("Select").gameObject
end

function LTreeNodeDemo2_1:SetData(nodeData, commonData)
    self.nodeData = nodeData
    local data = nodeData.data
    self.text.text = data.name
    self.selectGo:SetActive(commonData == self.key)
end

