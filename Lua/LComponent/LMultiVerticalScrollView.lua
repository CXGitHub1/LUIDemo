LMultiVerticalScrollView = LMultiVerticalScrollView or BaseClass()

function LMultiVerticalScrollView:__init(transform, itemTypeList)
    self.gameObject = transform.gameObject
    self.itemTypeList = itemTypeList
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.ItemSelectEvent = EventLib.New()
    self.eventNameList = nil

    self:_InitComponent(transform)

    self.itemList = nil
    -- self.selectKey = nil
    -- self.dynamicIndex = 1
    self.ItemSelectEvent = EventLib.New()
end

function LMultiVerticalScrollView:_InitComponent(transform)
     local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    local maskTrans = transform:Find(LDefine.MASK_NAME)
    local mask = maskTrans:GetComponent(Mask)
    self.mask = mask
    self.maskWidth = mask.transform.sizeDelta.x
    self.maskHeight = mask.transform.sizeDelta.y
    self.contentTrans = maskTrans:Find(LDefine.CONTENT_NAME)
    self:_InitTemplate()
end

function LMultiVerticalScrollView:_InitTemplate(transform)
    self.itemTypeDict = {}
    for i = 1, #self.itemTypeList do
        local itemType = self.itemTypeList[i]
        local trans = self.contentTrans:Find(LDefine.ITEM_NAME .. "_" .. depth)
        trans.gameObject:SetActive(false)
        self.itemTypeDict[i] = {
            itemType = itemType,
            template = trans.gameObject
            height = trans.sizeDelta.y
        }
    end
end

function LMultiVerticalScrollView:__delete()
    UtilsBase.TweenDelete(self, "focusTweenId")
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    if self.itemList then
        for _,v in pairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = nil
    end
    self.selectKey = nil
end

function LMultiVerticalScrollView:SetGap(gapVertical)
    self.gapVertical = gapVertical or 0
end

function LMultiVerticalScrollView:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
end


function LMultiVerticalScrollView:_GetItem(index)
    if self.itemList and self.itemList[index] then
    else
    end
end

function LMultiVerticalScrollView:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    self:_InitHeightList(dataList)


    local startIndex = self:_GetStartIndex()
    local endIndex = self:_GetEndIndex()
    self.startIndex = startIndex
    self.endIndex = endIndex

    if self.itemList == nil then self.itemList = {} end
    for index = startIndex, endIndex do
        local item = self:_GetItem(index)
        item:Show()
        item:SetData(self.dataList[index], commonData)
        if self.selectKey then
            item:SetSelectActive(self.selectKey)
        end
        table.insert(self.itemList, item)
    end

   
    -- self:_cacheItemList(startIndex, endIndex)
    -- self.itemList = {}
    -- for index = startIndex, endIndex do
    --     local item = self:_getItem(index)
    --     item:Show()
    --     item:SetData(self.dataList[index], commonData)
    --     if self.selectKey then
    --         item:SetSelectActive(self.selectKey)
    --     end
    --     table.insert(self.itemList, item)
    -- end
    -- self:_hideOutRangeList()
    -- self:Layout()
    -- self:_recalculateSize()
    -- self:_setDragableComponentEnabled()
    -- self:_adjustContentPosition()
end

function LMultiVerticalScrollView:_InitHeightList(dataList)
    local y = 0
    self.yList = {}
    for i = 1, #dataList do
        local data = dataList[i]
        local type = data.type
        table.insert(self.yList, y)
        y = y - self.itemTypeDict[type].height
    end
end

function LMultiVerticalScrollView:_GetIndexByY(targetY)
    if self.dataList == nil then
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
        local height = self.itemTypeList[itemType].height
        if y > targetY and targetY >= (y - height) then
            result = mid
            break
        end
        if targetY >= nodeY then
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

function LMultiVerticalScrollView:_GetStartIndex()
    return self:_GetIndexByY(self:_GetMaskTop())
end

function LMultiVerticalScrollView:_GetEndIndex()
    return self:_GetIndexByY(self:_GetMaskBottom()) 
end

-- function LMultiVerticalScrollView:_GetRowIndex(y)
--     local result = math.ceil((y - self.paddingTop) / (self.itemHeight + self.gapVertical))
--     return result < 1 and 1 or result
-- end

function LMultiVerticalScrollView:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LMultiVerticalScrollView:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

-- function LMultiVerticalScrollView:_GetIndexRange()
--     local y = self.contentTrans.anchoredPosition.y
--     local startIndex = self:_GetRowIndex(y)
--     local endIndex = self:_GetRowIndex(y + self.maskHeight)
--     startIndex = math.clamp(startIndex, 1, #self.dataList)
--     endIndex = math.clamp(endIndex, 1, #self.dataList)
--     return startIndex, endIndex
-- end

function LMultiVerticalScrollView:OnValueChanged(value)
    if self.dataList == nil then
        return
    end

    if self.startIndex ~= self:_GetStartIndex() or
        self.endIndex ~= self:_GetEndIndex() then
        self:_Update()
    end

end

--undo



function LMultiVerticalScrollView:OnValueChanged(value)
    if self.dataList == nil then
        return
    end
    if self.rowStartIndex ~= self:_getRowStartIndex() or self.rowEndIndex ~= self:_getRowEndIndex() then
        self:_refresh()
    end
    if value then
        if value.y < 0 then
            if self.reachBottomCb then
                if self.sendReachBottomCb == false then
                    self.sendReachBottomCb = true
                    self.reachBottomCb()
                end
            end
        else
            self.sendReachBottomCb = false
        end
    end
end

function LMultiVerticalScrollView:_cacheItemList(startIndex, endIndex)
    if self.itemList == nil then
        return
    end
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        if item.index < startIndex or endIndex < item.index then
            if self.cacheOutRangeList == nil then
                self.cacheOutRangeList = {}
            end
            table.insert(self.cacheOutRangeList, item)
        else
            if self.cacheInRangeDict == nil then
                self.cacheInRangeDict = {}
            end
            self.cacheInRangeDict[item.index] = item
        end
    end
end

function LMultiVerticalScrollView:Layout()
    for _, item in ipairs(self.itemList) do
        local index = item.index
        local columnIndex = (index - 1) % self.column
        local x = self.paddingLeft + columnIndex * (self.itemWidth + self.gapHorizontal)
        local rowIndex = math.floor((index - 1) / self.column)
        local y = self.paddingTop + rowIndex * (self.itemHeight + self.gapVertical)
        item:SetDefaultAnchor()
        item:SetPosition(x + self.itemWidth * 0.5, -y - self.itemHeight * 0.5)
    end
end



function LMultiVerticalScrollView:SetSelectActive(key)
    self.selectKey = key
    if self.itemList == nil then
        return
    end
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        item:SetSelectActive(key)
    end
end

function LMultiVerticalScrollView:ResetPosition()
    self.contentTrans.anchoredPosition = Vector2.zero
    self.scrollRect:StopMovement()
end

function LMultiVerticalScrollView:Focus(index, tweenMove)
    self.scrollRect:StopMovement()
    local size = self.contentTrans.sizeDelta
    local rowIndex = math.floor((index - 1) / self.column)
    local y = self.paddingTop + rowIndex * (self.itemHeight + self.gapVertical)
    local targetY = math.min(y, math.max(0, (size.y - self.maskHeight)))
    if tweenMove then
        self.focusTweenId = Tween.Instance:MoveLocalY(self.contentTrans.gameObject, targetY, 0.3, function()
            self.focusTweenId = nil
        end).id
    else
        UtilsUI.SetY(self.contentTrans, targetY)
    end
end

function LMultiVerticalScrollView:Show()
    self.gameObject:SetActive(true)
end

function LMultiVerticalScrollView:Hiden()
    self.gameObject:SetActive(false)
end

function LMultiVerticalScrollView:Select(index)
    local item = self:GetItem(index)
    self.selectKey = index
    if item then
        item:OnClick()
    else
        self:Focus(index)
        self:OnValueChanged()
        local item = self:GetItem(index)
        item:OnClick()
    end
end

function LMultiVerticalScrollView:GetItem(index)
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        if item.index == index then
            return item
        end
    end
end

function LMultiVerticalScrollView:_refresh()
    local startIndex, endIndex, rowStartIndex, rowEndIndex = self:_GetIndexRange()
    self.rowStartIndex = rowStartIndex
    self.rowEndIndex = rowEndIndex
    self:_cacheItemList(startIndex, endIndex)
    self.itemList = {}
    for index = startIndex, endIndex do
        local item, getWay = self:_getItem(index)
        item:Show()
        if getWay ~= ScrollPage.GET_ITEM_WAY.exist then
            item:SetData(self.dataList[index], self.commonData)
            if self.selectKey then
                item:SetSelectActive(self.selectKey)
            end
        end
        table.insert(self.itemList, item)
    end
    self:_hideOutRangeList()
    self:Layout()
end

function LMultiVerticalScrollView:_setDragableComponentEnabled()
    local enabled = self.contentTrans.sizeDelta.y > self.maskHeight
    self.scrollRect.enabled = enabled
    self.mask.enabled = enabled
    self.maskImage.enabled = enabled
end

function LMultiVerticalScrollView:_adjustContentPosition()
    local maxY = self.contentTrans.sizeDelta.y - self.maskHeight
    maxY = maxY < 0 and 0 or maxY
    if (-self.contentTrans.anchoredPosition.y) > maxY then
        UtilsUI.SetY(self.contentTrans, maxY)
    end
end

function LMultiVerticalScrollView:_recalculateSize()
    local maxColumnNum = math.min(#self.dataList, self.column)
    local width = self.paddingLeft + self.paddingRight + maxColumnNum * self.itemWidth
    if maxColumnNum > 1 then width = width + (maxColumnNum - 1) * self.gapHorizontal end
    local maxRowNum = math.ceil(#self.dataList / self.column)
    local height = self.paddingTop + self.paddingBottom + maxRowNum * self.itemHeight
    if maxRowNum > 1 then height = height + (maxRowNum - 1) * self.gapVertical end
    self.contentTrans.sizeDelta = Vector2(width, height)
end

function LMultiVerticalScrollView:_getItem(index)
    if self.cacheInRangeDict and self.cacheInRangeDict[index] then
        local item = self.cacheInRangeDict[index]
        self.cacheInRangeDict[index] = nil
        return item, ScrollPage.GET_ITEM_WAY.exist
    elseif self.cacheOutRangeList and #self.cacheOutRangeList > 0 then
        local item = table.remove(self.cacheOutRangeList)
        item:CacheClear(index)
        return item, ScrollPage.GET_ITEM_WAY.cache
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = self.itemType.New(go)
    item:SetIndex(index)
    item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
    return item, ScrollPage.GET_ITEM_WAY.new
end

function LMultiVerticalScrollView:_hideOutRangeList()
    if self.cacheOutRangeList then
        for i = 1, #self.cacheOutRangeList do
            self.cacheOutRangeList[i]:Hiden()
        end
    end
end
