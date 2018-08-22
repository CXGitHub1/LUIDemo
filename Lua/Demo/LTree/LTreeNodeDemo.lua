LTreeNodeDemo = LTreeNodeDemo or BaseClass(LTreeNode)

function LTreeNodeDemo:__init(gameObject, key)
	local transform = self.transform
	self.text = UtilsUI.GetText(transform, "Text")
	self.selectGo = transform:Find("Select").gameObject
	self.arrowGo = transform:Find("Arrow").gameObject
end

function LTreeNodeDemo:SetData(nodeData, commonData)
	self.nodeData = nodeData
	local data = nodeData.data
	self.text.text = data.name
	self.selectGo:SetActive(nodeData:GetKey() == commonData)
	if nodeData:HaveChild() then
		self.arrowGo:SetActive(true)
		if nodeData.expand then
			self.arrowGo.transform.eulerAngles = Vector3(0, 0, -45)
		else
			self.arrowGo.transform.eulerAngles = Vector3(0, 0, 0)
		end
	else
		self.arrowGo:SetActive(false)
	end
end
