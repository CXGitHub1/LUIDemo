-- chen quan
ListItem = ListItem or BaseClass()

function ListItem:__init(gameObject, index)
    self.gameObject = gameObject
    self.index = index
    local transform = gameObject.transform
    self.transform = transform

    self.ItemSelectEvent = EventLib.New()
    local button = transform:GetComponent(Button)
    if button then
        button.onClick:AddListener(function() self:OnClick() end)
    end
end

function ListItem:__delete()
    UtilsBase.TweenDelete(self, "_tweenId1")
    UtilsBase.TweenDelete(self, "_tweenId2")
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.DestroyGameObject(self, "gameObject")
end

function ListItem:InitStaticData()
end

function ListItem:SetIndex(index)
    self.index = index
    self.gameObject.name = ScrollView.ITEM_NAME .. index
end

function ListItem:SetDefaultAnchor()
    local transform = self.transform
    transform.anchorMin = Vector2(0, 1)
    transform.anchorMax = Vector2(0, 1)
    transform.pivot = Vector2(0, 1)
end

function ListItem:SetMiddelCenterAnchor()
    UtilsUI.SetPivot(self.transform, Vector2(0.5, 0.5))
end

function ListItem:GetPosition()
    return self.transform.localPosition
end

function ListItem:SetPosition(x, y)
    self.transform.localPosition = Vector2(x, y)
end

function ListItem:SetAnchoredPositoin(position)
    self.transform.anchoredPosition = position
end

function ListItem:GetUpperLeftPosition()
    local size = self.transform.sizeDelta
    local pivot = self.transform.pivot
    return self.transform.localPosition - Vector3(pivot.x * size.x, (pivot.y - 1) * size.y)
end

function ListItem:Show()
    self.gameObject:SetActive(true)
end

function ListItem:Hiden()
    self.gameObject:SetActive(false)
end

function ListItem:SetData()
    print("需要重写SetData方法")
end

function ListItem:GetSize()
    return self.transform.sizeDelta
end

function ListItem:OnClick()
    self.ItemSelectEvent:Fire(self.index, self)
end

function ListItem:BottomToTopTween(delayTime)
    UtilsBase.TweenDelete(self, "_tweenId1")
    UtilsBase.TweenDelete(self, "_tweenId2")
    local gameObject = self.gameObject
    local position = self.transform.localPosition
    UtilsUI.SetY(gameObject.transform, position.y - 150)
    self._tweenId1 = Tween.Instance:MoveLocalY(gameObject, position.y, NExpandableListItem.BOTTOM_TO_TOP_TWEEN_TIME, nil, LeanTweenType.linear):setDelay(delayTime).id
    self._tweenId2 = UtilsTween.CanvasFadeIn(gameObject, NExpandableListItem.BOTTOM_TO_TOP_TWEEN_TIME, LeanTweenType.linear, 0.5, delayTime)
    return delayTime + NExpandableListItem.BOTTOM_TO_TOP_INTERVAL_TIME
end

function ListItem:SetSelectActive(key)
    self.selectGo:SetActive(self.index == key)
end
