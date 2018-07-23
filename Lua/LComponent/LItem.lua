LItem = LItem or BaseClass()

function LItem:__init(gameObject)
    self.gameObject = gameObject
    local transform = gameObject.transform
    self.transform = transform

    self.ItemSelectEvent = EventLib.New()
    local button = transform:GetComponent(Button)
    if button then
        button.onClick:AddListener(function() self:OnClick() end)
    end
end

function LItem:__delete()
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
end

function LItem:InitStaticData(data)
    self.staticData = data
end

function LItem:SetActive(active)
    self.gameObject:SetActive(active)
end

function LItem:SetIndex(index)
    self.index = index
    self.gameObject.name = "Item" .. index
end

function LItem:GetIndex()
    return self.index
end

function LItem:GetSize()
    return self.transform.sizeDelta
end

function LItem:GetPosition()
    local pivot = self.transform.pivot
    local sizeDelta = self.transform.sizeDelta
    return self.transform.anchoredPosition - Vector2(pivot.x * sizeDelta.x, (pivot.y - 1) * sizeDelta.y)
end

function LItem:SetPosition(position)
    local pivot = self.transform.pivot
    local sizeDelta = self.transform.sizeDelta
    self.transform.anchoredPosition = position + Vector2(pivot.x * sizeDelta.x, (pivot.y - 1) * sizeDelta.y)
end

function LItem:Translate(position)
    self.transform.anchoredPosition = self.transform.anchoredPosition + position
end

function LItem:SetData(data, commonData)
    Log.Error("需要重写SetData方法")
end

function LItem:OnClick()
    self.ItemSelectEvent:Fire(self.index, self)
end
