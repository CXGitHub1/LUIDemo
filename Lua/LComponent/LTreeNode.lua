LTreeNode = LTreeNode or BaseClass(LItem)

function LTreeNode:__init(gameObject)
    local transform = self.transform
    self.transform = transform
    self.text = transform:Find("Text"):GetComponent(Text)
end

function LTreeNode:SetKey(key, depth)
    self.key = key
    self.depth = depth
end

function LTreeNode:SetData()
    self.text.text = "key:" .. self.key-- .. " depth:" .. self.depth
end
