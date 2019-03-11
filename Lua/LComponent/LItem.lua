LItem = LItem or BaseClass()

function LItem:__init(gameObject)
    self.gameObject = gameObject
    local transform = gameObject.transform
    self.transform = transform
    self.pivot = transform.pivot
    self.sizeDelta = transform.sizeDelta

    self.ItemSelectEvent = EventLib.New()
    local button = transform:GetComponent(Button)
    if button then
        button.onClick:AddListener(function() self:OnClick() end)
    end
end

function LItem:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
end

function LItem:InitFromCache(index)
    self:SetIndex(index)
end

function LItem:SetActive(active)
    if active then
        self.transform.localScale = Vector3One
    else
        self.transform.localScale = Vector3Zero
    end
end

--MultiVericalScrollView 所使用的类型
function LItem:SetItemType(type)
    self._itemType = type
end

function LItem:GetItemType(type)
    return self._itemType
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
    return Vector2(self.transform.anchoredPosition.x - (self.pivot.x * self.sizeDelta.x),
        self.transform.anchoredPosition.y - ((self.pivot.y - 1) * self.sizeDelta.y))
    -- return self.transform.anchoredPosition -
    -- Vector2(pivot.x * sizeDelta.x, (pivot.y - 1) * sizeDelta.y)
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
    pError("需要重写SetData方法")
end

function LItem:SetCommonData(commonData)
    pError("需要重写SetCommonData方法")
end

function LItem:OnClick()
    self.ItemSelectEvent:Fire(self.index, self)
end
