LMIScrollViewDemoItem1 = LMIScrollViewDemoItem1 or BaseClass(LItem)

function LMIScrollViewDemoItem1:__init()
    local transform = self.transform
    self.text = UtilsUI.GetText(transform, "Text")
    self.selectGo = transform:Find("Select").gameObject
end

function LMIScrollViewDemoItem1:SetData(data, commonData)
    self.text.text = self.index
    self:SetCommonData(commonData)
end

function LMIScrollViewDemoItem1:SetCommonData(commonData)
    self.selectGo:SetActive(self.index == commonData)
end