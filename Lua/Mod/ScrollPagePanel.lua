ScrollPagePanel = ScrollPagePanel or BaseClass()

function ScrollPagePanel:__init(gameObject)
    self.gameObject = gameObject
    local setting = ScrollPageSetting.New(ScrollPageTestItem, 1, 1)
    self.scrollPage = ScrollPage.New(gameObject.transform, setting)
    self.scrollPage:SetData({1, 2, 3, 4, 5})
end

function ScrollPagePanel:__delete()
end
