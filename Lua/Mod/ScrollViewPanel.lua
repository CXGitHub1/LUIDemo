ScrollViewPanel = ScrollViewPanel or BaseClass()

function ScrollViewPanel:__init(gameObject)
    self.gameObject = gameObject
    local setting = ScrollViewSetting.New(ScrollViewTestItem)
    self.scrollView = ScrollView.New(gameObject.transform, setting)
    self.scrollView:SetData({1, 2, 3, 4, 5})
end