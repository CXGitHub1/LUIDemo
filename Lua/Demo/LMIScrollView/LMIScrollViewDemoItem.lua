LMIScrollViewDemoItem = LMIScrollViewDemoItem or BaseClass(LItem)

function LMIScrollViewDemoItem:__init()
    local transform = self.transform
    self.text = UtilsUI.GetText(transform, "Text")
    self.selectGo = transform:Find("Select").gameObject
end

function LMIScrollViewDemoItem:SetData(data, commonData)
    self.text.text = self.index
    self:SetCommonData(commonData)
end

function LMIScrollViewDemoItem:SetCommonData(commonData)
    self.selectGo:SetActive(self.index == commonData)
end