LMIScrollViewDemoItem2 = LMIScrollViewDemoItem2 or BaseClass(LItem)

function LMIScrollViewDemoItem2:__init()
    local transform = self.transform
    self.text = UtilsUI.GetText(transform, "Text")
    self.selectGo = transform:Find("Select").gameObject
end

function LMIScrollViewDemoItem2:SetData(data, commonData)
    self.text.text = self.index
    self:SetCommonData(commonData)
end

function LMIScrollViewDemoItem2:SetCommonData(commonData)
    self.selectGo:SetActive(self.index == commonData)
end