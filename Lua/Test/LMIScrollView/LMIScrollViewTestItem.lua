LMIScrollViewTestItem = LMIScrollViewTestItem or BaseClass(LTestItem)

function LMIScrollViewTestItem:__init()
    local transform = self.transform
    if transform:Find("Select") then
        self.selectGo = transform:Find("Select").gameObject
    end
end

function LMIScrollViewTestItem:SetData(data, commonData)
    self.text.text = "I:" .. self.index .. "  T:0"
    self:SetCommonData(commonData)
end

function LMIScrollViewTestItem:SetCommonData(commonData)
    if self.selectGo then
        self.selectGo:SetActive(self.index == commonData)
    end
end

function LMIScrollViewTestItem:__release()
end
