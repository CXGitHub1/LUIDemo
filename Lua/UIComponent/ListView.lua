--chen quan
ListViewSetting = ListViewSetting or BaseClass()

function ListViewSetting:__init(itemType, column, gapHorizontal, gapVertical, paddingLeft, paddingRight, paddingTop, paddingBottom, anchorMiddle)
    self.itemType = itemType
    self.column = column or UtilsBase.INT32_MAX
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self.anchorMiddle = anchorMiddle
    self.eventNameList = {}
end

function ListViewSetting:AddEventName(eventName)
    table.insert(self.eventNameList, eventName)
end

function ListViewSetting:SetStaticData(data)
    self.staticData = data
end

ListView = ListView or BaseClass()

ListView.ITEM_NAME = "Item"

function ListView:__init(transform, setting)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.setting = setting

    self.template = transform:Find(ListView.ITEM_NAME).gameObject
    self.template:SetActive(false)
    local itemTrans = self.template.transform
    self.itemWidth = itemTrans.sizeDelta.x
    self.itemHeight = itemTrans.sizeDelta.y

    self.cacheList = {}
    self.itemList = {}
    self.tweenIdList = {}

    for i = 1, #setting.eventNameList do
        local eventName = setting.eventNameList[i]
        self[eventName] = EventLib.New()
    end

    self.ItemSelectEvent = EventLib.New()
end

function ListView:__delete()
    for i = 1, #self.setting.eventNameList do
        local eventName = self.setting.eventNameList[i]
        UtilsBase.FieldDeleteMe(self, eventName)
    end
    self.setting.eventNameList = {}
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.TableDeleteMe(self, "cacheList")
    UtilsBase.FieldDeleteMe(self, "timeLine")
    UtilsBase.TweenDelete(self, "focusTweenId")
    for _, tweenId in pairs(self.tweenIdList) do
        Tween.Instance:Cancel(tweenId)
    end
end

function ListView:SetData(dataList, commonData)
    self.itemList = {}
    for index, data in ipairs(dataList) do
        local item = self:getItem(index)
        item:Show()
        item:SetData(data, commonData)
        table.insert(self.itemList, item)
    end
    self:HideCacheList()
    self:Layout()
end

function ListView:SetSelectActive(key)
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        item:SetSelectActive(key)
    end
end

function ListView:Layout()
    local width = 0
    local height = 0
    local setting = self.setting
    for index, item in ipairs(self.itemList) do
        local columnIndex = (index - 1) % setting.column
        local rowIndex = math.floor((index - 1) / setting.column)
        local x = setting.paddingLeft + columnIndex * (setting.gapHorizontal + self.itemWidth)
        local y = setting.paddingTop + rowIndex * (setting.gapVertical + self.itemHeight)
        local borderX = x + self.itemWidth + setting.paddingRight
        local borderY = y + self.itemHeight + setting.paddingBottom
        if borderX > width then width = borderX end
        if borderY > height then height = borderY end
        item:SetDefaultAnchor()
        item:SetAnchoredPositoin(Vector2(x, -y))
        if setting.anchorMiddle then
            item:SetMiddelCenterAnchor()
        end
    end
    self.transform.sizeDelta = Vector2(width, height)
end

function ListView:GetSize()
    return self.transform.sizeDelta
end

function ListView:GetItemCount()
    return #self.itemList
end

function ListView:Show()
    self.gameObject:SetActive(true)
end

function ListView:Hiden()
    self.gameObject:SetActive(false)
end

function ListView:OnHide()
    UtilsBase.FieldDeleteMe(self, "timeLine")
    UtilsBase.TweenDelete(self, "focusTweenId")
    for _, tweenId in pairs(self.tweenIdList) do
        Tween.Instance:Cancel(tweenId)
    end
end

function ListView:getItem(index)
    local setting = self.setting
    local itemType = setting.itemType
    local item = self.cacheList[index]
    if item == nil then
        local go = GameObject.Instantiate(self.template)
        go.name = ListView.ITEM_NAME .. tostring(index)
        go.transform:SetParent(self.transform, false)
        item = itemType.New(go, index)
        if setting.staticData ~= nil then
            item:InitStaticData(setting.staticData)
        end
        self.cacheList[index] = item
        item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
        for i = 1, #setting.eventNameList do
            local eventName = setting.eventNameList[i]
            item[eventName]:AddListener(function(...) self[eventName]:Fire(...) end)
        end
    end
    return item
end

function ListView:GetItem(itemIndex)
    return self.itemList[itemIndex]
end

function ListView:GetItemList()
    return self.itemList
end

function ListView:GetSetting()
    return self.setting
end

function ListView:HideCacheList()
    for i = #self.itemList + 1, #self.cacheList do
        self.cacheList[i]:Hiden()
    end
end

function ListView:Clear()
    for _, item in ipairs(self.itemList) do
        item:Hiden()
    end
    self.itemList = {}
end

function ListView:FocusTweening()
    return self.focusTweenId ~= nil
end

function ListView:Focus(index, maskHeight, tweenMove)
    local size = self:GetSize()
    local item = self.itemList[index]
    local itemPosition = item:GetUpperLeftPosition()
    local targetY = math.min(-itemPosition.y, math.max(0, (size.y - maskHeight)))
    if tweenMove then
        self.focusTweenId = Tween.Instance:MoveLocalY(self.gameObject, targetY, 0.3, function()
            self.focusTweenId = nil
        end).id
    else
        UtilsUI.SetY(self.transform, targetY)
    end
end

function ListView:HorizonalFocus(index, maskWidth, tweenMove)
    local size = self:GetSize()
    local item = self.itemList[index]
    local itemPosition = item:GetUpperLeftPosition()
    local targetX = math.min(itemPosition.x, math.max(0, (size.x - maskWidth)))
    if tweenMove then
        self.focusTweenId1 = Tween.Instance:MoveLocalX(self.gameObject, targetX, 0.3, function()
            self.focusTweenId1 = nil
        end).id
    else
        UtilsUI.SetAnchoredX(self.transform, -targetX)
    end
end

function ListView:RightToLeftTween(offsetX, intervalTime, tweenTime)
    UtilsBase.FieldDeleteMe(self, "timeLine")
    for _, tweenId in pairs(self.tweenIdList) do
        Tween.Instance:Cancel(tweenId)
    end
    self.timeLine = TimeLine.New()
    local itemList = self.itemList
    local time = 0
    for i = 1, #itemList do
        local item = itemList[i]
        item:Hiden()
        self.timeLine:AddNode(time, function()
            local x = item.transform.localPosition.x
            if item.SetAlpha then
                item:SetAlpha(0)
            end
            UtilsUI.SetX(item.transform, item.transform.localPosition.x + offsetX)
            item:Show()
            local tweenId1, tweenId2 = UtilsTween.MoveLocalX(item.transform.gameObject, x, tweenTime)
            self:InsertTweenId(tweenId1)
            self:InsertTweenId(tweenId2)
        end)
        time = time + intervalTime
    end
    self.timeLine:Start()
end

function ListView:UpToBottomTween(offsetY, intervalTime, tweenTime)
    UtilsBase.FieldDeleteMe(self, "timeLine")
    for _, tweenId in pairs(self.tweenIdList) do
        Tween.Instance:Cancel(tweenId)
    end
    self.timeLine = TimeLine.New()
    local itemList = self.itemList
    local time = 0
    for i = 1, #itemList do
        local item = itemList[i]
        item:Hiden()
        self.timeLine:AddNode(time, function()
            local y = item.transform.localPosition.y
            if item.SetAlpha then
                item:SetAlpha(0)
            end
            UtilsUI.SetY(item.transform, item.transform.localPosition.y + offsetY)
            item:Show()
            local tweenId1, tweenId2 = UtilsTween.MoveLocalY(item.transform.gameObject, y, tweenTime)
            self:InsertTweenId(tweenId1)
            self:InsertTweenId(tweenId2)
        end)
        time = time + intervalTime
    end
    self.timeLine:Start()
end

function ListView:InsertTweenId(tweenId)
    if tweenId then
        table.insert(self.tweenIdList, tweenId)
    end
end
