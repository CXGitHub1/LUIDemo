LTreeNodeDataDemo1 = LTreeNodeDataDemo1 or BaseClass(LTreeNodeData)

function LTreeNodeDataDemo1:__init(data)
    self.name = data.name
    self.isFolder = data.isFolder
end