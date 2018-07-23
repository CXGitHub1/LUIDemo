-- @author chenquan
-- 垂直滑动组件
--
-- Prefab的格式如下(pivot和anchored都为左上角)
-- ScrollView(ScrollRect组件)
--      Mask(Mask组件)
--          Content
--              Item
-- 主要调用以下接口
--  SetData(dataList) 设置数据
--  SetSelectActive(key) 通过key设置某一Item是否显示
--
--  注意：ScrollView只会生成满足Mask大小的列表
--        目前只支持垂直滚动

ScrollViewSetting = ScrollViewSetting or BaseClass()

function ScrollViewSetting:__init(itemType, row, column, direction, gapHorizontal, gapVertical, paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.itemType = itemType
    self.row = row or UtilsBase.INT32_MAX
    self.column = column or 1
    self.direction = direction or ScrollView.Direction.vertical
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self.changeMaskShader = false
end

function ScrollViewSetting:SetChangeMaskShader()
    self.changeMaskShader = true
end

function ScrollViewSetting:SetReachBottomCb(cb)
    self.reachBottomCb = cb
end

ScrollView = ScrollView or BaseClass()

ScrollView.Direction = {
    horizontal = 1,
    vertical = 2,
}

ScrollView.ITEM_NAME = "Item"

function ScrollView:__init(transform, setting)
    self.gameObject = transform.gameObject
    self.itemType = setting.itemType
    self.row = setting.row
    self.column = setting.column
    self.direction = setting.direction
    self.gapHorizontal = setting.gapHorizontal
    self.gapVertical = setting.gapVertical
    self.paddingLeft = setting.paddingLeft
    self.paddingRight = setting.paddingRight
    self.paddingTop = setting.paddingTop
    self.paddingBottom = setting.paddingBottom
    self.changeMaskShader = setting.changeMaskShader
    self.reachBottomCb = setting.reachBottomCb
    self.sendReachBottomCb = false

    self.contentTrans = transform:Find("Mask/Content")
    self:InitMask(transform:Find("Mask"))
    self:InitTemplateItem()
    self:InitScrollRect(transform)

    self.selectKey = nil
    self.dynamicIndex = 1
    self.ItemSelectEvent = EventLib.New()
end

function ScrollView:InitMask(transform)
    local mask = transform:GetComponent(Mask)
    self.mask = mask
    self.maskWidth = mask.transform.sizeDelta.x
    self.maskHeight = mask.transform.sizeDelta.y
    self.maskImage = UtilsUI.GetImage(transform)
    if self.changeMaskShader then
        UtilsBase.SetMaskMat(self.maskImage)
    end
end

function ScrollView:InitTemplateItem(transform)
    local template = self.contentTrans:Find(ScrollPage.ITEM_NAME).gameObject
    self.template = template
    template.transform.localScale = Vector3.zero
    self.itemWidth = template.transform.sizeDelta.x
    self.itemHeight = template.transform.sizeDelta.y
end

function ScrollView:InitScrollRect(transform)
	local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function(value) self:OnValueChanged(value) end)
end

function ScrollView:__delete()
    UtilsBase.TweenDelete(self, "focusTweenId")
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    self.selectKey = nil
end

function ScrollView:OnValueChanged(value)
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

function ScrollView:_cacheItemList(startIndex, endIndex)
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

function ScrollView:Layout()
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

function ScrollView:_getRowStartIndex()
    local y = self.contentTrans.localPosition.y
    return self:_getRowIndex(y)
end

function ScrollView:_getRowEndIndex()
    local y = self.contentTrans.localPosition.y
    return self:_getRowIndex(y + self.maskHeight)
end

function ScrollView:_getRowIndex(y)
    local result = math.ceil((y - self.paddingTop) / (self.itemHeight + self.gapVertical))
    return result < 1 and 1 or result
end

function ScrollView:_getColumnIndex(x)
    local result = math.ceil((y - self.paddingTop) / (self.itemWidth + self.gapHorizontal))
    return math.clamp(result, 1, #self.dataList)
end

function ScrollView:_getIndexRange()
    if #self.dataList == 0 then
        return 0, -1
    end
    local startIndex
    local endIndex
    local rowStartIndex
    local rowEndIndex
    if self.direction == ScrollView.Direction.vertical then
        local y = self.contentTrans.localPosition.y
        rowStartIndex = self:_getRowIndex(y)
        rowEndIndex = self:_getRowIndex(y + self.maskHeight)
        startIndex = (rowStartIndex - 1) * self.column + 1
        endIndex = rowEndIndex * self.column
    else
        --TODO
    end
    startIndex = Mathf.Clamp(startIndex, 1, #self.dataList)
    endIndex = Mathf.Clamp(endIndex, 1, #self.dataList)
    return startIndex, endIndex, rowStartIndex, rowEndIndex
end

-- public function
function ScrollView:SetData(dataList)
    self.dataList = dataList or {}
    local startIndex, endIndex, rowStartIndex, rowEndIndex = self:_getIndexRange()
    self.rowStartIndex = rowStartIndex
    self.rowEndIndex = rowEndIndex
    self:_cacheItemList(startIndex, endIndex)
    self.itemList = {}
    for index = startIndex, endIndex do
        local item = self:_getItem(index)
        item:Show()
        item:SetData(self.dataList[index])
        if self.selectKey then
            item:SetSelectActive(self.selectKey)
        end
        table.insert(self.itemList, item)
    end
    self:_hideOutRangeList()
    self:Layout()
    self:_recalculateSize()
    self:_setDragableComponentEnabled()
    self:_adjustContentPosition()
end

function ScrollView:SetSelectActive(key)
    self.selectKey = key
    if self.itemList == nil then
        return
    end
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        item:SetSelectActive(key)
    end
end

function ScrollView:ResetPosition()
    self.contentTrans.localPosition = Vector2.zero
    self.scrollRect:StopMovement()
end

function ScrollView:Focus(index, tweenMove)
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

function ScrollView:Show()
    self.gameObject:SetActive(true)
end

function ScrollView:Hiden()
    self.gameObject:SetActive(false)
end

function ScrollView:Select(index)
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

function ScrollView:GetItem(index)
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        if item.index == index then
            return item
        end
    end
end

function ScrollView:_refresh()
    local startIndex, endIndex, rowStartIndex, rowEndIndex = self:_getIndexRange()
    self.rowStartIndex = rowStartIndex
    self.rowEndIndex = rowEndIndex
    self:_cacheItemList(startIndex, endIndex)
    self.itemList = {}
    for index = startIndex, endIndex do
        local item, getWay = self:_getItem(index)
        item:Show()
        if getWay ~= ScrollPage.GET_ITEM_WAY.exist then
            item:SetData(self.dataList[index])
            if self.selectKey then
                item:SetSelectActive(self.selectKey)
            end
        end
        table.insert(self.itemList, item)
    end
    self:_hideOutRangeList()
    self:Layout()
end

function ScrollView:_setDragableComponentEnabled()
    if not self.changeMaskShader then
        local enabled
        if self.direction == ScrollView.Direction.vertical then
            enabled = self.contentTrans.sizeDelta.y > self.maskHeight
        else
            enabled = self.contentTrans.sizeDelta.x > self.maskWidth
        end
        self.scrollRect.enabled = enabled
        self.mask.enabled = enabled
        self.maskImage.enabled = enabled
    end
end

function ScrollView:_adjustContentPosition()
    if self.direction == ScrollView.Direction.vertical then
        local maxY = self.contentTrans.sizeDelta.y - self.maskHeight
        maxY = maxY < 0 and 0 or maxY
        if (-self.contentTrans.localPosition.y) > maxY then
            UtilsUI.SetY(self.contentTrans, maxY)
        end
    else
        --TODO
    end
end

function ScrollView:_recalculateSize()
    if self.direction == ScrollView.Direction.vertical then
        local maxColumnNum = math.min(#self.dataList, self.column)
        local width = self.paddingLeft + self.paddingRight + maxColumnNum * self.itemWidth
        if maxColumnNum > 1 then width = width + (maxColumnNum - 1) * self.gapHorizontal end
        local maxRowNum = math.ceil(#self.dataList / self.column)
        local height = self.paddingTop + self.paddingBottom + maxRowNum * self.itemHeight
        if maxRowNum > 1 then height = height + (maxRowNum - 1) * self.gapVertical end
        self.contentTrans.sizeDelta = Vector2(width, height)
    else
        --TODO
    end
end

function ScrollView:_getItem(index)
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

function ScrollView:_hideOutRangeList()
    if self.cacheOutRangeList then
        for i = 1, #self.cacheOutRangeList do
            self.cacheOutRangeList[i]:Hiden()
        end
    end
end
