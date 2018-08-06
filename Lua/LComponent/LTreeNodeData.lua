LTreeNodeData = LTreeNodeData or BaseClass()

function LTreeNodeData:__init(data, depth, key)
    self.data = data
    self.depth = depth
    self.key = key
    self.expand = true
end

function LTreeNodeData:__release()
end

function LTreeNodeData:SetOrder(order)
    self.order = order
end

function LTreeNodeData:SetParent(parent)
    self.parent = parent
end

function LTreeNodeData:AddChild(child)
    if self.childList == nil then
        self.childList = {}
    end
    table.insert(self.childList, child)
end

function LTreeNodeData:HaveChild()
    return self.childList
end

function LTreeNodeData:GetChildList()
    return self.childList
end
