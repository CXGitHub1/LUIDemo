ListViewPanel = ListViewPanel or BaseClass()

function ListViewPanel:__init(gameObject)
    self.gameObject = gameObject
    local setting = ListViewSetting.New(ListViewTestItem, 1)
    self.listView = ListView.New(gameObject.transform, setting)
    self.listView:SetData({1, 2, 3, 4, 5})
end

function ListViewPanel:__delete()
end
