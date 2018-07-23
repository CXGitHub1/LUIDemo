ExpandableListTestItem = ExpandableListTestItem or BaseClass(NExpandableListItem)

function ExpandableListTestItem:InitExpandableItem(transform)
    NExpandableListItem.InitExpandableItem(self, transform)
end

function ExpandableListTestItem:__delete()
end

function ExpandableListTestItem:SetData(data)
    self.listView:SetData(data)
end