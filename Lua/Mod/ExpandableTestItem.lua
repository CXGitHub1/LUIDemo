ExpandableTestItem = ExpandableTestItem or BaseClass(ListItem)

function ExpandableTestItem:__init()
    local transform = self.transform
    self.selectGo = transform:Find("Select").gameObject
    self.normalGo = transform:Find("Normal").gameObject
end

function ExpandableTestItem:__delete()
end

function ExpandableTestItem:SetData()
end