-- LScrollView 耗时严重分析

-- 1
-- 时刻维持着最小大小，会导致在滑动时出现问题，所以改为大小一直在扩展，看看向上滚动会不会出问题
-- drag的问题，因为它会记住上一次的位置，导致变化过大

-- 2
-- 因为mask降级到Content下面
-- Content只要返回自身大小就可以

-- 3
-- 如果一次偏移过大，没有ItemDict为空会如何
-- 经实验，ScrollView在一次偏移过大的情况下，比如mask为1，item的高度为1，一次向下拖拽会有5+以上的offset
-- 这时会在每一帧不断地添加item，直到包含Item的Content大小大于mask，再不断删减多余的Item
-- 整个过程不存在startIndex和endIndex之间为空的情况，因为不是先删除再添加，而是先添加再删除

-- 4
--好处 这样处理的好处是不用新增计算的接口 合并NScrollView和ScrollView
--待定 需要加边界误差处理 比如小于0？
--设计 不支持多行多列中 同一行不定长，同一列不定长，会假定那一列的第一行或者那一行的第一列为标准大小
--要求 做从左往右的方向，从上到下排列
--重写ScrollRect 因为要扩展ContentTranslate的接口

-- 5
-- 当同一行高度不等时，同一列宽度不等时，会出现显示异常，而且松手自滚动过程中会出现加速的情况

-- 6
-- 锚点要求为Vector2(0, 1)

-- 8 gap作用不言而喻，ScrollView必须的参数，而padding是否也是必须
--   padding有助于更细化的布局，所以还是不删减这个功能，但padding并非必须

-- 9 计算Content时 是否需要包含padding 如果Content不包含padding，那padding就失去意义，必须计算在内
--   计算Content时 是否需要包含gap，这点可要可不要
--   最终决定不包含gap，没有好处，也没有美感

-- 10 以transform为参数在于写法比较方便，传gameObject是我认为比较合理的方式，但并不实用

-- 11 由于ScrollView和ScrollPage合并的复杂度比较高
--    翻页布局交由ScrollPage处理
--    合并的复杂度在于布局方式处理与ScrollView有冲突
--    比如翻页的布局为
--    a a b b
--    a a b b
--    而ScrollView在翻页过程中会出现这样的布局
--    a a b
--    a a b
--    这时，不止于布局的方式变了，连坐标的连续性都难以保证，因此放弃合并

-- 12 考虑增加bottomAdd 功能

-- 13 多次SetData的情况 目前看来并不理想，但还能接受

-- 14 测试SetData从有到无的情况

-- 15 试过每帧只处理一个事件，结果导致创建了太多新Item

--focus只能瞬移(SetData) 要缓动只能提供个固定大小的参数

LScrollView = LScrollView or BaseClass()

LScrollView.Direction = {
    horizontal = 1,
    vertical = 2,
}

LScrollView.ITEM_NAME = "Item"
LScrollView.MASK_NAME = "Mask"
LScrollView.CONTENT_NAME = "Content"

function LScrollView:__init(transform, itemType, row, column)
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

    self.contentTrans = transform:Find(LScrollView.MASK_NAME .."/" .. LScrollView.CONTENT_NAME)
    self:_InitMask(transform:Find(LScrollView.MASK_NAME))
    self:_InitTemplateItem()
    self:_InitScrollRect(transform)


    self.itemDict = nil
    self.itemPoolList = {}
    self.tempItemDict = {}
    self.startIndex = nil
    self.endIndex = nil
end

function LScrollView:_InitMask(transform)
    local mask = transform:GetComponent(Mask)
    self.mask = mask
    self.maskWidth = mask.transform.sizeDelta.x
    self.maskHeight = mask.transform.sizeDelta.y
end

function LScrollView:_InitTemplateItem(transform)
    local template = self.contentTrans:Find(LScrollView.ITEM_NAME).gameObject
    self.template = template
    template:SetActive(false)
end

function LScrollView:_InitScrollRect(transform)
    local scrollRect = transform:GetComponent(LScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    if scrollRect.vertical then
        self.scrollDirection = LScrollView.Direction.vertical
    else
        self.scrollDirection = LScrollView.Direction.horizontal
    end
end

function LScrollView:__delete()
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.FieldDeleteMe(self, "ReachBottomEvent")
    UtilsBase.TableDeleteMe(self, "eventNameList")
end

-- public function
function LScrollView:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    if self.gapHorizontal < 0 or self.gapVertical < 0 then
        Debug.LogError("不支持gap小于0")
    end
end

function LScrollView:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    if self.paddingLeft < 0 or
        self.paddingRight < 0 or
        self.paddingTop < 0 or
        self.paddingBottom < 0 then
        Debug.LogError("不支持padding小于0")
    end
end

function LScrollView:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    table.insert(self.eventNameList, eventName)
    self[eventName] = EventLib.New()
end

-- SetStartIndex之后需要调用SetData才生效
function LScrollView:SetStartIndex(index)
    self.startIndex = self:_GetStartIndex(index)
end

function LScrollView:SetData(dataList, commonData)
    self:_InitData(dataList, commonData)
    if dataList == nil then
        self:_CalcSize()
        self:_ClearTempItemDict()
        return
    end
    local startIndex = self.startIndex or 1
    if startIndex > #dataList then
        startIndex = 1
    end
    local isFirst = startIndex == 1
    local x = self.paddingLeft
    local y = -self.paddingTop
    if not isFirst then
        if self:_IsVerticalScroll() then
            y = 0
        else
            x = 0
        end
    end

    self.itemDict = {}
    local endIndex = #dataList
    for index = startIndex, #dataList do
        local item = self:_GetItem(index)
        self.itemDict[index] = item
        item:SetActive(true)
        item:SetData(self.dataList[index], commonData)
        item:SetPosition(Vector2(x, y))
        local size = item:GetSize()
        if self:_IsVerticalScroll() then
            if self:_IsColumnMax(index) then
                y = y - (size.y + self.gapVertical)
                x = self.paddingLeft
            else
                x = x + size.x + self.gapHorizontal
            end
        else
            if self:_IsRowMax(index) then
                y = -self.paddingTop
                x = x + size.x + self.gapHorizontal
            else
                y = y - (size.y + self.gapVertical)
            end
        end
        if self:_EndOutMask(x, y) then
            endIndex = index
            break
        end
    end
    self.startIndex = startIndex
    self.endIndex = endIndex
    self:_CalcSize()
    self:_ClearTempItemDict()
end

function LScrollView:_OnValueChanged(value)
    self:_FireReachBottomEvent(value)
    if not self:_ContentContainMask() then
        while(self:_CanAddAtStart()) do
            self:_RemoveEndOutMask()
            self:_AddAtStart()
        end
        while(self:_CanAddAtEnd()) do
            self:_RemoveStartOutMask()
            self:_AddAtEnd()
        end
    end
end

function LScrollView:_CanAddAtStart()
    return self.startIndex > 1 and self:_ContentStartInMask()
end

function LScrollView:_AddAtStart()
    local addEndIndex = self.startIndex - 1
    local addStartIndex = self:_GetStartIndex(addEndIndex)
    local size
    local isFirst = addStartIndex == 1
    local x = 0
    local y = 0
    if self:_IsVerticalScroll() then
        x = self.paddingLeft
        if isFirst then
            y = -self.paddingTop
        end
    else
        y = -self.paddingTop
        if isFirst then
            x = self.paddingLeft
        end
    end
    for index = addStartIndex, addEndIndex do
        local item = self:_GetItem(index)
        item:SetActive(true)
        item:SetData(self.dataList[index], self.commonData)
        item:SetPosition(Vector2(x, y))
        size = item:GetSize()
        if not self:_IsVerticalScroll() then
            y = y - (size.y + self.gapVertical)
        else
            x = x + size.x + self.gapHorizontal
        end
        self.itemDict[index] = item
    end

    local offset
    if self:_IsVerticalScroll() then
        local offsetY = -(size.y + self.gapVertical)
        if isFirst then
            offsetY = offsetY - self.paddingTop
        end
        offset = Vector2(0, offsetY)
    else
        local offsetX = size.x + self.gapHorizontal
        if isFirst then
            offsetX = offsetX + self.paddingLeft
        end
        offset = Vector2(offsetX, 0)
    end

    for index = self.startIndex, self.endIndex do
        local item = self.itemDict[index]
        item:Translate(offset)
    end
    self.scrollRect:ContentTranslate(-offset)

    self.startIndex = addStartIndex
    self:_CalcSize()
end

function LScrollView:_CanAddAtEnd()
    return self.endIndex < #self.dataList and self:_ContentEndInMask()
end

function LScrollView:_AddAtEnd()
    local addStartIndex = self.endIndex + 1
    local addEndIndex = self:_GetEndIndex(addStartIndex)
    if addEndIndex > #self.dataList then
        addEndIndex = #self.dataList
    end

    local endLineStartIndex = self:_GetStartIndex(self.endIndex)
    local endItem = self.itemDict[endLineStartIndex]
    local endPosition = endItem:GetPosition()
    local size = endItem:GetSize()

    local x = endPosition.x
    local y = endPosition.y
    if self:_IsVerticalScroll() then
        x = self.paddingLeft
        y = y - (size.y + self.gapVertical)
    else
        y = -self.paddingTop
        x = x + size.x + self.gapHorizontal
    end

    for index = addStartIndex, addEndIndex do
        local item = self:_GetItem(index)
        item:SetActive(true)
        item:SetData(self.dataList[index], self.commonData)
        item:SetPosition(Vector2(x, y))
        if self:_IsVerticalScroll() then
            x = x + item:GetSize().x + self.gapHorizontal
        else
            y = y - (item:GetSize().y + self.gapVertical)
        end
        self.itemDict[index] = item
    end
    self.endIndex = addEndIndex
    self:_CalcSize()
end

function LScrollView:_RemoveStartOutMask()
    local startIndex = self.startIndex
    local startItem = self.itemDict[startIndex]
    if self:_IsOutOfView(startItem) then
        local endIndex = self:_GetEndIndex(startIndex)
        if endIndex > #self.dataList then
            endIndex = #self.dataList
        end
        for index = startIndex, endIndex do
            self:_PushPool(index)
        end

        local size = startItem:GetSize()
        local isFirst = startIndex == 1
        local offset
        if self:_IsVerticalScroll() then
            local y = size.y + self.gapVertical
            if isFirst then y = y + self.paddingTop end
            offset = Vector2(0, y)
        else
            local x = -(size.x + self.gapHorizontal)
            if isFirst then x = x - self.paddingLeft end
            offset = Vector2(x, 0)
        end

        self.startIndex = endIndex + 1
        for index = self.startIndex, self.endIndex do
            local item = self.itemDict[index]
            item:Translate(offset)
        end
        self.scrollRect:ContentTranslate(-offset)
        self:_CalcSize()
        return true
    end
    return false
end

function LScrollView:_RemoveEndOutMask()
    local endIndex = self.endIndex
    local item = self.itemDict[endIndex]
    if self:_IsOutOfView(item) then
        local startIndex = self:_GetStartIndex(endIndex)
        for index = startIndex, endIndex do
            self:_PushPool(index)
        end

        self.endIndex = startIndex - 1
        self:_CalcSize()
        return true
    end
    return false
end

function LScrollView:_FireReachBottomEvent(value)
    if self.endIndex == #self.dataList then
        if self:_IsVerticalScroll() then
            if value.y < -0.1 then
                if not self.reachBottomFire then
                    self.ReachBottomEvent:Fire()
                    self.reachBottomFire = true
                end
            else
                self.reachBottomFire = false
            end
        else
            if value.x > 1.1 then
                if self.reachBottomFire == false then
                    self.ReachBottomEvent:Fire()
                    self.reachBottomFire = true
                end
            else
                self.reachBottomFire = false
            end
        end
    end
end

function LScrollView:_InitData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    local length = dataList and #dataList or 0
    if self:_IsVerticalScroll() then
        self.columnMax = length > self.column and self.column or length
        self.rowMax = math.floor((length - 1) / self.column) + 1
    else
        self.rowMax = length > self.row and self.row or length
        self.columnMax = math.floor((length - 1) / self.row) + 1
    end
    self.tempItemDict = self.itemDict
end

function LScrollView:_CalcSize()
    if self.dataList == nil or next(self.dataList) == nil then
        self.contentTrans.sizeDelta = Vector2(0, 0)
        return
    end
    local right = UtilsBase.INT32_MIN
    local bottom = UtilsBase.INT32_MAX
    local startItem = self.itemDict[self.startIndex]
    local position = startItem:GetPosition()
    local left = position.x
    local top = position.y
    if self.startIndex == 1 then
        left = 0
        top = 0
    else
        if self:_IsVerticalScroll() then
            left = left - self.paddingLeft
        else
            top = top + self.paddingTop
        end
    end

    local currentColumnMax
    local currentRowMax
    if self:_IsVerticalScroll() then
        currentColumnMax = self.columnMax
        currentRowMax = self:_GetRow(self.endIndex)
    else
        currentColumnMax = self:_GetColumn(self.endIndex)
        currentRowMax = self.rowMax
    end

    for index = self.startIndex, self.endIndex do
        local item = self.itemDict[index]
        local position = item:GetPosition()
        local size = item:GetSize()
        if self:_GetColumn(index) == currentColumnMax then
            local padding = 0
            if self:_IsColumnMax(index) then
                padding = self.paddingRight
            end
            if (position.x + size.x + padding) > right then
                right = position.x + size.x + padding
            end
        end
        if self:_GetRow(index) == currentRowMax then
            local padding = 0
            if self:_IsRowMax(index) then
                padding = self.paddingBottom
            end
            if (position.y - size.y - padding) < bottom then
                bottom = position.y - size.y - padding
            end
        end
    end

    self.contentTrans.sizeDelta = Vector2(right - left, top - bottom)
end

function LScrollView:_IsOutOfView(item)
    local position = item:GetPosition()
    if self:_IsVerticalScroll() then
        local top = position.y + self.gapVertical
        local bottom = position.y - item:GetSize().y - self.gapVertical
        if self:_BelowMaskBottom(top) or self:_AboveMaskTop(bottom) then
            return true
        end
    else
        local left = position.x - self.gapHorizontal
        local right = position.x + item:GetSize().x + self.gapHorizontal
        if self:_LessThanMaskLeft(right) or self:_GreaterThanMaskRight(left) then
            return true
        end
    end
    return false
end

function LScrollView:_GetItem(index)
    local item
    if self.tempItemDict and self.tempItemDict[index] then
        item = self.tempItemDict[index]
        self.tempItemDict[index] = nil
        item:InitFromCache(index)
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        item = table.remove(self.itemPoolList)
        item:InitFromCache(index)
    else
        local go = GameObject.Instantiate(self.template)
        go.transform:SetParent(self.contentTrans, false)
        item = self.itemType.New(go)
        item.ItemSelectEvent:AddListener(function(index, item)
            self.ItemSelectEvent:Fire(index, item)
        end)
        if self.eventNameList then
            for i = 1, #self.eventNameList do
                local eventName = self.eventNameList[i]
                item[eventName]:AddListener(function(...) self[eventName]:Fire(...) end)
            end
        end
        item:SetIndex(index)
    end
    return item
end

function LScrollView:_PushPool(index)
    local item = self.itemDict[index]
    table.insert(self.itemPoolList, item)
    item:SetActive(false)
    self.itemDict[index] = nil
end

function LScrollView:_ClearTempItemDict()
    if self.tempItemDict ~= nil then
        for index, item in pairs(self.tempItemDict) do
            item:SetActive(false)
            table.insert(self.itemPoolList, item)
        end
        self.tempItemDict = nil
    end
end

function LScrollView:_GetContentBound()
    return 0, self.contentTrans.sizeDelta.x, 0, -self.contentTrans.sizeDelta.y
end

function LScrollView:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LScrollView:_GetMaskLeft()
    return -self.contentTrans.anchoredPosition.x
end

function LScrollView:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function LScrollView:_GetMaskRight()
    return -self.contentTrans.anchoredPosition.x + self.maskWidth
end

function LScrollView:_AboveMaskBottom(y)
    return y >= self:_GetMaskBottom()
end

function LScrollView:_GreaterThanMaskLeft(x)
    return x >= self:_GetMaskLeft()
end

function LScrollView:_BelowMaskTop(y)
    return y <= self:_GetMaskTop()
end

function LScrollView:_LessThanMaskRight(x)
    return x <= self:_GetMaskRight()
end

function LScrollView:_BelowMaskBottom(y)
    return y < self:_GetMaskBottom()
end

function LScrollView:_LessThanMaskLeft(x)
    return x < self:_GetMaskLeft()
end

function LScrollView:_AboveMaskTop(y)
    return y > self:_GetMaskTop()
end

function LScrollView:_GreaterThanMaskRight(x)
    return x > self:_GetMaskRight()
end

function LScrollView:_IsVerticalScroll()
    return self.scrollDirection == LScrollView.Direction.vertical
end

function LScrollView:_ContentContainMask()
    local left, right, top, bottom = self:_GetContentBound()
    if self:_IsVerticalScroll() then
        return self:_AboveMaskTop(top) and self:_BelowMaskBottom(bottom)
    else
        return self:_LessThanMaskLeft(left) and self:_GreaterThanMaskRight(right)
    end
end

function LScrollView:_ContentStartInMask()
    local left, right, top, bottom = self:_GetContentBound()
    if self:_IsVerticalScroll() then
        return self:_BelowMaskTop(top)
    else
        return self:_GreaterThanMaskLeft(left)
    end
end

function LScrollView:_ContentEndInMask()
    local left, right, top, bottom = self:_GetContentBound()
    if self:_IsVerticalScroll() then
        return self:_AboveMaskBottom(bottom)
    else
        return self:_LessThanMaskRight(right)
    end
end

function LScrollView:_EndOutMask(x, y)
    if self:_IsVerticalScroll() then
        return self:_BelowMaskBottom(y)
    else
        return self:_GreaterThanMaskRight(x)
    end
end

function LScrollView:_IsRowMax(index)
    return self:_GetRow(index) == self.rowMax
end

function LScrollView:_IsColumnMax(index)
    return self:_GetColumn(index) == self.columnMax
end

function LScrollView:_GetRow(index)
    if self:_IsVerticalScroll() then
        return math.floor((index - 1) / self.column) + 1
    else
        return (index - 1) % self.row + 1
    end
end

function LScrollView:_GetColumn(index)
    if self:_IsVerticalScroll() then
        return (index - 1) % self.column + 1
    else
        return math.floor((index - 1) / self.row) + 1
    end
end

function LScrollView:_GetStartIndex(index)
    if self:_IsVerticalScroll() then
        return (self:_GetRow(index) - 1) * self.column + 1
    else
        return (self:_GetColumn(index) - 1) * self.row + 1
    end
end

function LScrollView:_GetEndIndex(index)
    if self:_IsVerticalScroll() then
        return self:_GetRow(index) * self.column
    else
        return self:_GetColumn(index) * self.row
    end
end