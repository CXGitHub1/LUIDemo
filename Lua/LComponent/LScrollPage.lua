-- @author chenquan
-- 水平滚动翻页组件
--
-- Prefab的格式如下(pivot和anchored都为左上角)
-- LScrollPage(ScrollRect组件)
--      LeftButton
--      RightButton
--      Mask(Mask组件)
--          Content
--              Item
--
-- 主要调用以下接口
--  SetData(dataList) 设置每一页的数据
--  SetCurrentPage(pageNum, tween) 跳转到指定页
--
--  注意：ScrollPage最多生成三页的Item 即currentPage - 1, currentPage, currentPage + 1

-- 待测试
-- SetData为空的情况
-- SetData有数据之后又为空的情况

--ScrollPage参数设置
--itemType Item的基类
--row 每页显示行数
--column 每页显示列数
--gapHorizontal Item 之间的水平间隙
--gapVertical Item 之间的垂直间隙
--paddingLeft 每页左边第一个Item与Mask左边缘的偏移值
--paddingRight 每页右边第一个Item与Mask右边缘的偏移值
--paddingTop 每页上边第一个Item与Mask顶部边缘的偏移值
--paddingBottom 每页下边第一个Item与Mask底部边缘的偏移值
LScrollPage = LScrollPage or BaseClass()

LScrollPage.ITEM_NAME = "Item"
LScrollPage.GET_ITEM_WAY = {
    new = 1,        --新建
    exist = 2,      --已有
    cache = 3,      --缓存获取
}

LScrollPage.Direction = {
    horizontal = 1,
    vertical = 2,
}

function LScrollPage:__init(transform, itemType, row, column, direction)
    self.itemType = itemType
    self.row = row
    self.column = column
    self.itemLayoutDirection = direction or LScrollPage.Direction.horizontal
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.perPageCount = row * column

    self.transform = transform
    self.contentTrans = transform:Find("Mask/Content")
    self:InitTemplateItem()
    self:InitMask(transform:Find("Mask"))
    self:InitScrollRect(transform)
    self:InitScrollPageEventDispatcher(transform)
    self:InitTurnButton(transform)

    self.currentPage = 1
    self.currentPageDynamic = self.currentPage
    self.ItemSelectEvent = EventLib.New()
end

function LScrollPage:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    self:CalcMaskSize()
end

function LScrollPage:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self:CalcMaskSize()
end

function LScrollPage:InitMask(transform)
    self.mask = transform:GetComponent(Mask)
    self.maskImage = UtilsUI.GetImage(transform)
    self:CalcMaskSize()
end

function LScrollPage:CalcMaskSize()
    local maskWidth = self.paddingLeft + self.paddingRight + self.column * self.itemWidth + (self.column - 1) * self.gapHorizontal
    local maskHeight = self.paddingTop + self.paddingBottom + self.row * self.itemHeight + (self.row - 1) * self.gapVertical
    self.maskWidth = maskWidth
    self.maskHeight = maskHeight
    self.mask.transform.sizeDelta = Vector2(maskWidth, maskHeight)
end

function LScrollPage:InitTemplateItem()
    local template = self.contentTrans:Find(LScrollPage.ITEM_NAME).gameObject
    self.template = template
    self.itemWidth = template.transform.sizeDelta.x
    self.itemHeight = template.transform.sizeDelta.y
end

function LScrollPage:InitScrollRect(transform)
    local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function() self:OnValueChanged() end)
    scrollRect.inertia = false
    if scrollRect.vertical then
        self.pageLayoutDirection = LScrollPage.Direction.vertical
    else
        self.pageLayoutDirection = LScrollPage.Direction.horizontal
    end
end

function LScrollPage:InitScrollPageEventDispatcher(transform)
    local controller = transform.gameObject:AddComponent(CustomDragButton)
    self.customDragButton = controller
    controller.onBeginDrag:AddListener(function(value) self:OnBeginDragEvent() end)
    controller.onEndDrag:AddListener(function(value) self:OnEndDragEvent() end)
end

function LScrollPage:InitTurnButton(transform)
    -- self.leftButton = UtilsUI.GetButton(transform, "LeftButton")
    -- self.leftButton.onClick:AddListener(function()
    --     self:SetCurrentPage(self.currentPage - 1, true)
    -- end)
    -- self.rightButton = UtilsUI.GetButton(transform, "RightButton")
    -- self.rightButton.onClick:AddListener(function()
    --     self:SetCurrentPage(self.currentPage + 1, true)
    -- end)
end

function LScrollPage:__delete()
end

function LScrollPage:OnBeginDragEvent()
    UtilsBase.TweenDelete(self, "tweenId")
    self.beginDragPosition = self.contentTrans.anchoredPosition
end

function LScrollPage:OnEndDragEvent()
    local endDragPosition = self.contentTrans.anchoredPosition
    local page
    if self:PageHorizontalLayout() then
        page = math.ceil(-endDragPosition.x / self.maskWidth)
        if endDragPosition.x < self.beginDragPosition.x then --鼠标向左拉动
            page = page + 1
        end
    else
        page = math.ceil(endDragPosition.y / self.maskHeight)
        if endDragPosition.y > self.beginDragPosition.y then --鼠标向上拉动
            page = page + 1
        end
    end
    page = Mathf.Clamp(page, 1, self.totalPage)
    self.currentPage = page
    self:_tweenMove(page)
end

function LScrollPage:OnValueChanged()
    local dynamicCurrentPage = self:_getDynamicCurrentPage()
    if self.dynamicCurrentPage ~= dynamicCurrentPage then
        self.dynamicCurrentPage = dynamicCurrentPage
        self:_refresh()
    end
end

-- public function
function LScrollPage:InitCurrentPage(page)
    self.currentPage = page
end

function LScrollPage:GetPageNumByItemIndex(itemIndex)
    return math.ceil(itemIndex / self.perPageCount)
end

function LScrollPage:SetCurrentPage(page, tween)
    local page = Mathf.Clamp(page, 1, self.totalPage)
    -- if page == self.currentPage then
    --     return
    -- end
    self.currentPage = page
    if tween then
        self:_tweenMove(page)
    else
        if self:PageHorizontalLayout() then
            UtilsUI.SetAnchoredX(self.contentTrans, self:_getTargetPosition(page).x)
        else
            UtilsUI.SetAnchoredY(self.contentTrans, self:_getTargetPosition(page).y)
        end
        self.dynamicCurrentPage = self:_getDynamicCurrentPage()
        self:_refresh()
    end
end

function LScrollPage:GetTotalPage()
    return self.totalPage
end

function LScrollPage:_emptyCacheItemList()
    if self.itemList then
        for i = 1, #self.itemList do
            --TODO
        end
    end
end

function LScrollPage:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    if dataList == nil then
        self:_emptyCacheItemList()
        return
    end
    self.totalPage = math.ceil(#dataList / self.perPageCount)
    local startIndex, endIndex = self:_getIndexRange(self.currentPage)
    self:_cacheItemList(startIndex, endIndex)
    self.itemList = {}
    for index = startIndex, endIndex do
        local item = self:_getItem(index)
        item:SetActive(true)
        item:SetData(dataList[index], commonData)
        table.insert(self.itemList, item)
    end
    self:_setDragableComponentEnabled(#dataList > self.perPageCount)
    self:_hideOutRangeList()
    self:Layout()
    self:_recalculateSize()
    self:_refreshTurnButton()
    if self:PageHorizontalLayout() then
        if (math.abs(self.contentTrans.localPosition.x)) > math.abs(self:_getTargetPosition(self.totalPage).x) then
            UtilsUI.SetAnchoredX(self.contentTrans, self:_getTargetPosition(self.totalPage).x)
        end
    else
        if (math.abs(self.contentTrans.localPosition.y)) > math.abs(self:_getTargetPosition(self.totalPage).y) then
            UtilsUI.SetAnchoredY(self.contentTrans, self:_getTargetPosition(self.totalPage).y)
        end
    end
end

function LScrollPage:Layout()
    for _, item in ipairs(self.itemList) do
        local index = item.index
        local page = math.floor((index - 1) / self.perPageCount)
        local pageIndex = (index - 1) % self.perPageCount + 1
        local x, y
        local offset
        if self:PageHorizontalLayout() then
            offset = Vector2(page * self.maskWidth, 0)
        else
            offset = Vector2(0, -page * self.maskHeight)
        end
        if self:ItemHorizontalLayout() then
            column = (pageIndex - 1) % self.column + 1
            row = math.floor((pageIndex - 1) / self.column) + 1
        else
            row = (pageIndex - 1) % self.row + 1
            column = math.floor((pageIndex - 1) / self.row) + 1
        end
        x = self.paddingLeft + (column - 1) * (self.itemWidth + self.gapHorizontal)
        y = self.paddingTop + (row - 1) * (self.itemHeight + self.gapVertical)
        item:SetPosition(Vector2(x, -y) + offset)
    end
end

-- private function
function LScrollPage:_tweenMove(page)
    if self:PageHorizontalLayout() then
        self.tweenId = Tween.Instance:MoveLocalX(self.contentTrans.gameObject, self:_getTargetPosition(page).x, 0.3).id
    else
        self.tweenId = Tween.Instance:MoveLocalY(self.contentTrans.gameObject, self:_getTargetPosition(page).y, 0.3).id
    end
end

function LScrollPage:_recalculateSize()
    if self:PageHorizontalLayout() then
        self.contentTrans.sizeDelta = Vector2(self.totalPage * self.maskWidth, self.maskHeight)
    else
        self.contentTrans.sizeDelta = Vector2(self.maskWidth, self.totalPage * self.maskHeight)
    end
end

function LScrollPage:_setDragableComponentEnabled(enabled)
    self.scrollRect.enabled = enabled
    self.customDragButton.enabled = enabled
    self.mask.enabled = enabled
    self.maskImage.enabled = enabled
end

function LScrollPage:_getTargetPosition(page)
    if self:PageHorizontalLayout() then
        return Vector2(-(page - 1) * self.maskWidth, 0)
    else
        return Vector2(0, (page - 1) * self.maskHeight)
    end
end

function LScrollPage:_hideOutRangeList()
    if self.cacheOutRangeList then
        for i = 1, #self.cacheOutRangeList do
            self.cacheOutRangeList[i]:SetActive(false)
        end
    end
end

function LScrollPage:_getIndexRange(currentPage)
    local startIndex = (currentPage - 2) * self.perPageCount + 1
    local endIndex = (currentPage + 1) * self.perPageCount
    return math.max(startIndex, 1), math.min(endIndex, #self.dataList)
end

function LScrollPage:_cacheItemList(startIndex, endIndex)
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

function LScrollPage:_refresh()
    local dataList = self.dataList
    local startIndex, endIndex = self:_getIndexRange(self.dynamicCurrentPage)
    self:_cacheItemList(startIndex, endIndex)
    self.itemList = {}
    for index = startIndex, endIndex do
        local item, getWay = self:_getItem(index)
        item:SetActive(true)
        if getWay ~= LScrollPage.GET_ITEM_WAY.exist then
            item:SetData(dataList[index], self.commonData)
        end
        table.insert(self.itemList, item)
    end
    self:_hideOutRangeList()
    self:Layout()
    self:_refreshTurnButton()
end

function LScrollPage:_getDynamicCurrentPage()
    local page
    if self:PageHorizontalLayout() then
        page = math.ceil((-self.contentTrans.anchoredPosition.x + self.maskWidth / 2) / self.maskWidth)
    else
        page = math.ceil((self.contentTrans.anchoredPosition.y + self.maskHeight / 2) / self.maskHeight)
    end
    return Mathf.Clamp(page, 1, self.totalPage)
end

function LScrollPage:_getItem(index)
    if self.cacheInRangeDict and self.cacheInRangeDict[index] then
        local item = self.cacheInRangeDict[index]
        self.cacheInRangeDict[index] = nil
        return item, LScrollPage.GET_ITEM_WAY.exist
    elseif self.cacheOutRangeList and #self.cacheOutRangeList > 0 then
        local item = table.remove(self.cacheOutRangeList)
        item:SetIndex(index)
        return item, LScrollPage.GET_ITEM_WAY.cache
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = self.itemType.New(go)
    item:SetIndex(index)
    item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
    return item, LScrollPage.GET_ITEM_WAY.new
end

function LScrollPage:_refreshTurnButton()
    -- self.leftButton.gameObject:SetActive(self.currentPage ~= 1)
    -- self.rightButton.gameObject:SetActive(self.currentPage ~= self.totalPage)
end

function LScrollPage:ItemHorizontalLayout()
    return self.itemLayoutDirection == LScrollPage.Direction.horizontal
end

function LScrollPage:PageHorizontalLayout()
    return self.pageLayoutDirection == LScrollPage.Direction.horizontal
end
