ScrollViewItem = ScrollViewItem or BaseClass()

function ScrollViewItem:__init(gameObject)
    self.gameObject = gameObject
    local transform = gameObject.transform
    self.transform = transform
    local button = transform:GetComponent(Button)
    if button then
        button.onClick:AddListener(function() self:OnClick() end)
    end

    self.ItemSelectEvent = EventLib.New()
end

function ScrollViewItem:SetIndex(index)
    self.index = index
    self.gameObject.name = ScrollView.ITEM_NAME .. index
end

function ScrollViewItem:__delete()
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.DestroyGameObject(self, "gameObject")
end

function ScrollViewItem:SetDefaultAnchor()
    local transform = self.transform
    transform.anchorMin = Vector2(0, 1)
    transform.anchorMax = Vector2(0, 1)
    transform.pivot = Vector2(0.5, 0.5)
end

function ScrollViewItem:SetPosition(x, y)
    self.transform.localPosition = Vector2(x, y)
end

function ScrollViewItem:Show()
    self.transform.localScale = Vector3.one
end

function ScrollViewItem:Hiden()
    self.transform.localScale = Vector3.zero
end

function ScrollViewItem:CacheClear(index)
    self:SetIndex(index)
end

function ScrollViewItem:SetData()
    print("需要重写SetData方法")
end

function ScrollViewItem:OnClick()
    self.ItemSelectEvent:Fire(self.index, self)
end

function ScrollViewItem:SetSelectActive(key)
    self.selectGo:SetActive(self.index == key)
end
