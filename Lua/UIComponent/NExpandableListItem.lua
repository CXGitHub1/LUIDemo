--chen quan
NExpandableListItem = NExpandableListItem or BaseClass()

NExpandableListItem.ITEM_NAME = "ExpandableItem"
NExpandableListItem.LIST_VIEW_NAME = "Content"
NExpandableListItem.BOTTOM_TO_TOP_TWEEN_TIME = 0.1
NExpandableListItem.BOTTOM_TO_TOP_INTERVAL_TIME = 0.1
NExpandableListItem.EXPANDABLE_TWEEN_TIME = 0.1

function NExpandableListItem:__init(gameObject, index, setting, expandableListView)
    self.expandableListView = expandableListView
    self.gameObject = gameObject
    self.index = index
    self.itemSetting = setting

    local transform = gameObject.transform
    self.transform = transform
    local itemTransform = transform:Find(NExpandableListItem.ITEM_NAME)
    self.contentTransform = transform:Find(NExpandableListItem.LIST_VIEW_NAME)
    self.itemTransform = itemTransform
    self:InitExpandableItem(itemTransform)
    itemTransform:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
    self.listView = ListView.New(transform:Find(NExpandableListItem.LIST_VIEW_NAME), setting)
    self.listView.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(self.index, index, item) end)

    self.OnClickEvent = EventLib.New()
    self.ItemSelectEvent = EventLib.New()
    self.status = NExpandableListView.STATUS.collapse
end

function NExpandableListItem:__delete()
    UtilsBase.FieldDeleteMe(self, "OnClickEvent")
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.FieldDeleteMe(self, "listView")
    UtilsBase.TweenDelete(self, "_tweenId1")
    UtilsBase.TweenDelete(self, "_tweenId2")
    UtilsBase.TweenDelete(self, "_tweenId3")
end

function NExpandableListItem:InitExpandableItem(transform)
    local normalTrans = transform:Find("Normal")
    if normalTrans then
        self.normalGo = normalTrans.gameObject
    end

    local selectTrans = transform:Find("Select")
    if selectTrans then
        self.selectGo = selectTrans.gameObject
    end
end

function NExpandableListItem:SetData(data)
end

function NExpandableListItem:RefreshSelect()
    if self.status == NExpandableListView.STATUS.expand then
        self:SetSelectGoActive(true)
        self:SetNormalGoActive(false)
        if self.listView:GetItemCount() ~= 0 then
            self.listView:Show()
            self.listView:SetSelectActive(self.expandableListView.itemIndex)
        else
            self.listView:Hiden()
        end
    else
        self:SetNormalGoActive(true)
        self:SetSelectGoActive(false)
        self.listView:Hiden()
    end
    UtilsUI.CalculateSize(self.transform)
end

function NExpandableListItem:Show()
    self.gameObject:SetActive(true)
end

function NExpandableListItem:Hiden()
    self.gameObject:SetActive(false)
end

function NExpandableListItem:OnHide()
    UtilsBase.TweenDelete(self, "_tweenId1")
    UtilsBase.TweenDelete(self, "_tweenId2")
    UtilsBase.TweenDelete(self, "_tweenId3")
    self.listView:OnHide()
end

function NExpandableListItem:GetItem(itemIndex)
    return self.listView:GetItem(itemIndex)
end

function NExpandableListItem:GetSize()
    return self.transform.sizeDelta
end

function NExpandableListItem:SetPosition(x, y)
    self.transform.anchoredPosition = Vector2(x, y)
end

function NExpandableListItem:GetStatus()
    return self.status
end

function NExpandableListItem:SetStatus(status)
    self.status = status
end

function NExpandableListItem:SavePosition()
    self._cachePoisition = self.transform.localPosition
end

function NExpandableListItem:GetExpandableItemStartPositionY()
    return self.itemTransform.sizeDelta.y + self.itemSetting.paddingTop
end

-- on function
function NExpandableListItem:OnClick()
    self.OnClickEvent:Fire(self)
end

-- tool function
function NExpandableListItem:BottomToTopTween(delayTime)
    local gameObject = self.gameObject
    local position = self.transform.localPosition
    UtilsUI.SetY(gameObject.transform, position.y - 150)
    UtilsBase.TweenDelete(self, "_tweenId1")
    UtilsBase.TweenDelete(self, "_tweenId2")
    self._tweenId1 = Tween.Instance:MoveLocalY(gameObject, position.y, NExpandableListItem.BOTTOM_TO_TOP_TWEEN_TIME, nil, LeanTweenType.linear):setDelay(delayTime).id
    self._tweenId2 = UtilsTween.CanvasFadeIn(gameObject, NExpandableListItem.BOTTOM_TO_TOP_TWEEN_TIME, LeanTweenType.linear, 0.5, delayTime)
    delayTime = delayTime + NExpandableListItem.BOTTOM_TO_TOP_INTERVAL_TIME

    if self.status == NExpandableListView.STATUS.expand then
        local itemList = self.listView.itemList
        self.listView:Layout()
        for i = 1, #itemList do
            local item = itemList[i]
            delayTime = item:BottomToTopTween(delayTime)
        end
    end
    return delayTime
end

function NExpandableListItem:PlayExpandableTween()
    local gameObject = self.gameObject
    UtilsBase.TweenIdListDelete(self, "_expandableTweenIdList")
    self._expandableTweenIdList = {}
    local position = self.transform.localPosition
    self.transform.localPosition = self._cachePoisition
    local tweenId = Tween.Instance:MoveLocalY(gameObject, position.y, NExpandableListItem.EXPANDABLE_TWEEN_TIME, nil, LeanTweenType.linear).id
    table.insert(self._expandableTweenIdList, tweenId)

    if self.status == NExpandableListView.STATUS.expand then
        local itemList = self.listView.itemList
        for i = 1, #itemList do
            local item = itemList[i]
            local position = item.transform.localPosition
            UtilsUI.SetY(item.transform, self:GetExpandableItemStartPositionY())
            tweenId = Tween.Instance:MoveLocalY(item.gameObject, position.y, NExpandableListItem.EXPANDABLE_TWEEN_TIME, nil, LeanTweenType.linear).id
            table.insert(self._expandableTweenIdList, tweenId)
            tweenId = UtilsTween.CanvasFadeIn(item.gameObject, NExpandableListItem.EXPANDABLE_TWEEN_TIME, LeanTweenType.linear, 0)
            table.insert(self._expandableTweenIdList, tweenId)
        end
    end
end

function NExpandableListItem:SetNormalGoActive(active)
    if self.normalGo then
        self.normalGo:SetActive(active)
    end
end

function NExpandableListItem:SetSelectGoActive(active)
    if self.selectGo then
        self.selectGo:SetActive(active)
    end
end

function NExpandableListItem:GetItemAPositionByIndex(index)
    local itemList = self.listView.itemList
    local item = itemList[index]
    if item == nil then return 0,0,0 end
    return GetAPosition(item.transform)
end

function NExpandableListItem:GetAPosition()
    return GetAPosition(self.transform)
end

function NExpandableListItem:GetContentAPosition()
    return GetAPosition(self.contentTransform)
end
