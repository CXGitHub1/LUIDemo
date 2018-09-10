NScrollView = NScrollView or BaseClass()

function NScrollView:__init(transform, itemType, row, column)
    self.gameObject = transform.gameObject
    self.itemType = itemType
    self.row = row or UtilsBase.INT32_MAX
    self.column = column or UtilsBase.INT32_MAX
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.ItemSelectEvent = EventLib.New()
    self.ReachBottomEvent = EventLib.New()
    self.eventNameList = nil

    self.itemDict = nil
    self.itemPoolListDict = {}

    self:_InitComponent(transform)
    self:_InitTemplate()
end

function NScrollView:_InitComponent(transform)
     local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    if scrollRect.vertical then
        self.scrollDirection = LDefine.Direction.vertical
    else
        self.scrollDirection = LDefine.Direction.horizontal
    end
    local maskTrans = transform:Find(LDefine.MASK_NAME)
    local mask = maskTrans:GetComponent(Mask)
    self.mask = mask
    self.maskWidth = maskTrans.sizeDelta.x
    self.maskHeight = maskTrans.sizeDelta.y
    self.contentTrans = maskTrans:Find(LDefine.CONTENT_NAME)
end

function NScrollView:_InitTemplate()
    local itemTrans = self.contentTrans:Find(LDefine.ITEM_NAME)
    self.template = itemTrans.gameObject
    self.itemWidth = itemTrans.sizeDelta.x
    self.itemHeight = itemTrans.sizeDelta.y
end

function NScrollView:__release()
    UtilsBase.CancelTween(self, "focusTweenId")
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseTable(self, "itemDict")
    for key, itemPoolList in pairs(self.itemPoolListDict) do
        for i = 1, #itemPoolList do
            itemPoolList[i]:Release()
        end
    end
    self.itemPoolListDict = nil
end

-- public function --
function NScrollView:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
end

function NScrollView:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
end

function NScrollView:SetCommonData(commonData)
    self.commonData = commonData
    for _, item in pairs(self.itemDict) do
        item:SetCommonData(commonData)
    end
end

-- dataList的结构为
-- {
--     {type = itemType, data = data},
--     {type = itemType, data = data},
--     {type = itemType, data = data},
-- }
function NScrollView:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    self:_InitData(dataList)

    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    if not self:_IsDataListEmpty() then
        if self.itemDict == nil then self.itemDict = {} end
        for index = self.startIndex, self.endIndex do
            local item = self:_GetItem(index)
            item:SetActive(true)
            item:SetData(self.dataList[index], commonData)
            item:SetPosition(Vector2(0, self.yList[index]))
            self.itemDict[index] = item
        end 
    end
    self:_AdjustContentPosition()
end

function NScrollView:ResetPosition()
    self.contentTrans.anchoredPosition = Vector2.zero
    self.scrollRect:StopMovement()
end

function NScrollView:Focus(index, tweenMove)
    if not self.yList[index] then
        return
    end
    self.scrollRect:StopMovement()
    local targetY = -self.yList[index]
    local maxY = self.height - self.maskHeight
    if targetY > maxY then
        targetY = maxY
    end
    if tweenMove then
        self.focusTweenId = Tween.Instance:MoveLocalY(self.contentTrans.gameObject, targetY, 0.3, function()
            self.focusTweenId = nil
        end).id
    else
        UtilsUI.SetAnchoredY(self.contentTrans, targetY)
    end
end

-- public function end --

function NScrollView:_InitData(dataList)
    local y = 0
    self.yList = {}
    if dataList then
        for i = 1, #dataList do
            local data = dataList[i]
            local type = data.type
            table.insert(self.yList, y)
            y = y - self.itemTypeDict[type].height - self.gapVertical
        end
    end
    self.contentTrans.sizeDelta = Vector2(self.width, -y)
    self.height = -y
end

function NScrollView:_OnValueChanged(value)
    if self:_IsDataListEmpty() then
        return
    end
    if self.startIndex ~= self:_GetStartIndex() or
        self.endIndex ~= self:_GetEndIndex() then
        self:_Update()
    end
end

function NScrollView:_Update()
    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    for index = self.startIndex, self.endIndex do
        local item, getWay = self:_GetItem(index)
        item:SetActive(true)
        if getWay ~= LDefine.GetItemWay.exist then
            item:SetData(self.dataList[index], self.commonData)
            item:SetPosition(Vector2(0, self.yList[index]))
            self.itemDict[index] = item
        end
    end
end

function NScrollView:_GetIndexByY(targetY)
    if self:_IsDataListEmpty() then
        return 0
    end
    local startIndex = 1
    local endIndex = #self.dataList
    if endIndex <= startIndex then
        return 1
    end
    local result
    while true do
        local mid = math.floor((startIndex + endIndex) / 2)
        local itemType = self.dataList[mid].type
        local y = self.yList[mid]
        local height = self.itemTypeDict[itemType].height
        if y > targetY and targetY >= (y - height) then
            result = mid
            break
        end
        if targetY >= y then
            endIndex = mid - 1
        else
            startIndex = mid + 1
        end
        if endIndex - startIndex <= 0 then
            result = startIndex
            break
        end
    end
    return result
end

function NScrollView:_GetData(index)
    if self.dataList then
        return self.dataList[index]
    end
end

function NScrollView:_IsDataListEmpty()
    return self.dataList == nil or next(self.dataList) == nil
end

function NScrollView:_GetItem(index)
    local itemType = self.dataList[index].type
    if self.itemDict and self.itemDict[index] then
        local item = self.itemDict[index]
        if item:GetItemType() == itemType then
            return item, LDefine.GetItemWay.exist
        else
            self:_PushPool(item)
        end
    elseif self.itemPoolListDict[itemType] and #self.itemPoolListDict[itemType] > 0 then
        local itemPoolList = self.itemPoolListDict[itemType]
        local item = table.remove(itemPoolList)
        item:InitFromCache(index) 
        return item, LDefine.GetItemWay.cache
    end
    local itemConfig = self.itemTypeDict[itemType]
    local go = GameObject.Instantiate(itemConfig.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = itemConfig.itemType.New(go)
    item:SetIndex(index)
    item:SetItemType(itemType)
    item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
    return item, LDefine.GetItemWay.new
end




function NScrollView:_PushPool(item)
    item:SetActive(false)
    self.itemDict[item.index] = nil
    local itemType = item:GetItemType()
    if self.itemPoolListDict[itemType] == nil then
        self.itemPoolListDict[itemType] = {}
    end
    table.insert(self.itemPoolListDict[itemType], item)
end

function NScrollView:_PushUnUsedItem()
    if self.itemDict then
        for index, item in pairs(self.itemDict) do
            if index < self.startIndex or
                index > self.endIndex then
                self:_PushPool(item)
            else
                local data = self:_GetData(index)
                if data == nil or data.type ~= item:GetItemType() then
                    self:_PushPool(item)
                end
            end
        end
    end
end

function NScrollView:_AdjustContentPosition()
    local maxY = self.height - self.maskHeight
    maxY = maxY < 0 and 0 or maxY
    if self.contentTrans.anchoredPosition.y > maxY then
        UtilsUI.SetAnchoredY(self.contentTrans, maxY)
    end
end


function NScrollView:_GetRowStartIndex()
    return self:_GetRowIndex(self:_GetMaskTop())
end

function NScrollView:_GetRowEndIndex()
    return self:_GetRowIndex(self:_GetMaskBottom()) 
end

function NScrollView:_GetColumnStartIndex()
    return self:_GetColumnIndex(self:_GetMaskLeft())
end

function NScrollView:_GetColumnEndIndex()
    return self:_GetColumnIndex(self:_GetMaskRight()) 
end

function NScrollView:_GetRowIndex(y)
    local result = math.ceil((y - self.paddingTop) / (self.itemHeight + self.gapVertical))
    return result < 1 and 1 or result
end

function NScrollView:_GetColumnIndex(x)
    local result = math.ceil((-x - self.paddingLeft) / (self.itemWidth + self.gapHorizontal))
    return result < 1 and 1 or result
end

function NScrollView:_GetMaskLeft()
    return -self.contentTrans.anchoredPosition.x
end

function NScrollView:_GetMaskRight()
    return -self.contentTrans.anchoredPosition.x + self.maskWidth
end

function NScrollView:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function NScrollView:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end