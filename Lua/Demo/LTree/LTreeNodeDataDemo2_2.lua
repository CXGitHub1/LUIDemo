LTreeNodeDataDemo2_2 = LTreeNodeDataDemo2_2 or BaseClass(LTreeNodeData)

function LTreeNodeDataDemo2_2:__init(data, depth, key)
end

function LTreeNodeDataDemo2_2:GetRandomValue()
	return math.random(0, self.data.value)
end
