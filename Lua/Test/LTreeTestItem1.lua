LTreeTestItem1 = LTreeTestItem1 or BaseClass(LTreeNode)

function LTreeTestItem1:__init(gameObject, key)
	local transform = self.transform
	self.text = UtilsUI.GetText(transform, "Text")
	self.selectGo = transform:Find("Select").gameObject
end

function LTreeTestItem1:SetData(nodeData, commonData)
	self.nodeData = nodeData
	local data = nodeData.data
	self.text.text = data.name
	self.selectGo:SetActive(nodeData:GetKey() == commonData)
end
