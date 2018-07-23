LScrollViewHorizontalPanel = LScrollViewHorizontalPanel or BaseClass()

function LScrollViewHorizontalPanel:__init(gameObject)
    self.listView = LScrollView.New(gameObject.transform, LTestItem, 1, UtilsBase.INT32_MAX)
    self.listView.startIndex = 2
    self.listView:SetData({1, 2, 3, 4, 5, 6, 7, 8})
end

function LScrollViewHorizontalPanel:__delete()
    UtilsBase.FieldDeleteMe(self, "listView")
end

LScrollViewVerticalPanel = LScrollViewVerticalPanel or BaseClass()

function LScrollViewVerticalPanel:__init(gameObject)
    self.listView = LScrollView.New(gameObject.transform, LTestItem, UtilsBase.INT32_MAX, 1)
    self.listView.startIndex = 2
    self.listView:SetData({1, 2, 3, 4, 5, 6, 7, 8})
end

function LScrollViewVerticalPanel:__delete()
    UtilsBase.FieldDeleteMe(self, "listView")
end

MultiVerticalPanel = MultiVerticalPanel or BaseClass()

function MultiVerticalPanel:__init(gameObject)
    self.listView = LScrollView.New(gameObject.transform, LTestItem, UtilsBase.INT32_MAX, 2)
    self.listView:SetStartIndex(3)
    self.listView.paddingTop = 5
    self.listView.paddingBottom = 15
    self.listView.gapVertical = 5
    local data = {}
    for i = 1, 20 do
        table.insert(data, i)
    end
    self.listView:SetData(data)
end

function MultiVerticalPanel:__delete()
    UtilsBase.FieldDeleteMe(self, "listView")
end

MultiHorizontalPanel = MultiHorizontalPanel or BaseClass()

function MultiHorizontalPanel:__init(gameObject)
    self.listView = LScrollView.New(gameObject.transform, LTestItem, 2, UtilsBase.INT32_MAX)
    self.listView.startIndex = 26
    self.listView.paddingLeft = 40
    self.listView.paddingRight = 20
    self.listView.gapHorizontal = 10
    local data = {}
    for i = 1, 40 do
        table.insert(data, i)
    end
    self.listView:SetData(data)
end

function MultiHorizontalPanel:__delete()
    UtilsBase.FieldDeleteMe(self, "listView")
end
