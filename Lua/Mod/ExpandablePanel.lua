ExpandablePanel = ExpandablePanel or BaseClass()

function ExpandablePanel:__init(gameObject)
    self.gameObject = gameObject
    local transform = gameObject.transform

    local listViewSetting = ListViewSetting.New(ExpandableTestItem, 1)
    local expandableListViewSetting = NExpandableListViewSettting.New(ExpandableListTestItem, 0, 0, 0, 0, 0, listViewSetting)
    self.expandableListView = NExpandableListView.New(transform:Find("Mask/Container"), expandableListViewSetting)
    self.expandableListView:SetData(
    {
        {1,2,3,4,5},
        {1,2,3},
        {1,2,3},
    })
end

function ExpandablePanel:__delete()
end
