LTreeNode = LTreeNode or BaseClass(LItem)

function LTreeNode:__init(gameObject, nodeData)
    local transform = self.transform
    self.transform = transform
    self.text = transform:Find("Text"):GetComponent(Text)
    self.nodeData = nodeData
end

function LTreeNode:SetData(data)
    self.data = data
    self.text.text = data.name
    print(self.nodeData.depth)
    UtilsUI.SetAnchoredX(self.transform, self.nodeData.depth * 20)
end

function LTreeNode:InitFromCache(index)
    self:SetIndex(index)
end


function LTreeNode:SetPosition(position)
    UtilsUI.SetAnchoredY(self.transform, position.y)
end
