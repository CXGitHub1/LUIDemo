ScrollPageItem = ScrollPageItem or BaseClass()

function ScrollPageItem:__init(gameObject)
    self.gameObject = gameObject
    local transform = gameObject.transform
    self.transform = transform
    local button = transform:GetComponent(Button)
    if button then
        button.onClick:AddListener(function() self:OnClick() end)
    end

    self.ItemSelectEvent = EventLib.New()
end

function ScrollPageItem:SetIndex(index)
    self.index = index
    self.gameObject.name = ScrollPage.ITEM_NAME .. index
end

function ScrollPageItem:__delete()
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.DestroyGameObject(self, "gameObject")
end

function ScrollPageItem:SetDefaultAnchor()
    local transform = self.transform
    transform.anchorMin = Vector2(0, 1)
    transform.anchorMax = Vector2(0, 1)
    transform.pivot = Vector2(0.5, 0.5)
end

function ScrollPageItem:SetPosition(x, y)
    self.transform.localPosition = Vector2(x, y)
end

function ScrollPageItem:Show()
    self.transform.localScale = Vector3.one
end

function ScrollPageItem:Hiden()
    self.transform.localScale = Vector3.zero
end

function ScrollPageItem:CacheClear(index)
    self:SetIndex(index)
end

function ScrollPageItem:SetData()
    print("需要重写SetData方法")
end

function ScrollPageItem:OnClick()
    self.ItemSelectEvent:Fire(self.index, self)
end
