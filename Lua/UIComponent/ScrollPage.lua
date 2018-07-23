-- @author chenquan
-- 水平滚动翻页组件
--
-- Prefab的格式如下(pivot和anchored都为左上角)
-- ScrollPage(ScrollRect组件)
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

ScrollPageSetting = ScrollPageSetting or BaseClass()

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
function ScrollPageSetting:__init(itemType, row, column, gapHorizontal, gapVertical, paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.itemType = itemType
    self.row = row
    self.column = column
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self.changeMaskShader = false
end

function ScrollPageSetting:SetChangeMaskShader()
    self.changeMaskShader = true
end

ScrollPage = ScrollPage or BaseClass()

ScrollPage.ITEM_NAME = "Item"
ScrollPage.GET_ITEM_WAY = {
    new = 1,        --新建
    exist = 2,      --已有
    cache = 3,      --缓存获取
}

function ScrollPage:__init(transform, setting)
    self.itemType = setting.itemType
    self.row = setting.row
    self.column = setting.column
    self.gapHorizontal = setting.gapHorizontal
    self.gapVertical = setting.gapVertical
    self.paddingLeft = setting.paddingLeft
    self.paddingRight = setting.paddingRight
    self.paddingTop = setting.paddingTop
    self.paddingBottom = setting.paddingBottom
    self.changeMaskShader = setting.changeMaskShader
    self.perPageCount = setting.row * setting.column

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

function ScrollPage:InitMask(transform)
    self.mask = transform:GetComponent(Mask)
    local maskWidth = self.paddingLeft + self.paddingRight + self.column * self.itemWidth + (self.column - 1) * self.gapHorizontal
    local maskHeight = self.paddingTop + self.paddingBottom + self.row * self.itemHeight + (self.row - 1) * self.gapVertical
    self.maskWidth = maskWidth
    self.maskHeight = maskHeight
    self.mask.transform.sizeDelta = Vector2(maskWidth, maskHeight)
    self.maskImage = UtilsUI.GetImage(transform)
    if self.changeMaskShader then
        UtilsBase.SetMaskMat(self.maskImage)
    end
end

function ScrollPage:InitTemplateItem()
    local template = self.contentTrans:Find(ScrollPage.ITEM_NAME).gameObject
    self.template = template
    template.transform.localScale = Vector3.zero
    self.itemWidth = template.transform.sizeDelta.x
    self.itemHeight = template.transform.sizeDelta.y
end

function ScrollPage:InitScrollRect(transform)
	local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function() self:OnValueChanged() end)
    scrollRect.inertia = false
end

function ScrollPage:InitScrollPageEventDispatcher(transform)
    local controller = transform.gameObject:AddComponent(CustomDragButton)
    self.customDragButton = controller
    controller.onBeginDrag:AddListener(function(value) self:OnBeginDragEvent() end)
    controller.onEndDrag:AddListener(function(value) self:OnEndDragEvent() end)
end

function ScrollPage:InitTurnButton(transform)
    -- self.leftButton = UtilsUI.GetButton(transform, "LeftButton")
    -- self.leftButton.onClick:AddListener(function()
    --     self:SetCurrentPage(self.currentPage - 1, true)
    -- end)
    -- self.rightButton = UtilsUI.GetButton(transform, "RightButton")
    -- self.rightButton.onClick:AddListener(function()
    --     self:SetCurrentPage(self.currentPage + 1, true)
    -- end)
end

function ScrollPage:__delete()
    UtilsBase.TweenDelete(self, "tweenId")
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
end

function ScrollPage:OnBeginDragEvent()
    UtilsBase.TweenDelete(self, "tweenId")
    self.beginDragX = self.contentTrans.localPosition.x
end

function ScrollPage:OnEndDragEvent()
    local endDragX = self.contentTrans.localPosition.x
    local page = math.ceil(-endDragX / self.maskWidth)
    if endDragX - self.beginDragX < 0 then --鼠标向左拉动
        page = page + 1
    end
    page = Mathf.Clamp(page, 1, self.totalPage)
    self.currentPage = page
    self:_tweenMove(page)
end

function ScrollPage:OnValueChanged()
    local dynamicCurrentPage = self:_getDynamicCurrentPage()
    if self.dynamicCurrentPage ~= dynamicCurrentPage then
        self.dynamicCurrentPage = dynamicCurrentPage
        self:_refresh()
    end
end

-- public function
function ScrollPage:SetInitPage(page)
    self.initPage = page
end

function ScrollPage:GetPageNumByItemIndex(itemIndex)
    return math.ceil(itemIndex / self.perPageCount)
end

function ScrollPage:SetCurrentPage(page, tween)
    local page = Mathf.Clamp(page, 1, self.totalPage)
    if page == self.currentPage then
        return
    end
    self.currentPage = page
    if tween then
        self:_tweenMove(page)
    else
        UtilsUI.SetX(self.contentTrans, self:_getTargetX(page))
        self.dynamicCurrentPage = self:_getDynamicCurrentPage()
        self:_refresh()
    end
end

function ScrollPage:GetTotalPage()
    return self.totalPage
end

function ScrollPage:SetData(dataList)
    self.dataList = dataList
    self.totalPage = math.ceil(#dataList / self.perPageCount)

    local startIndex, endIndex = self:_getIndexRange(self.currentPage)
    self:_cacheItemList(startIndex, endIndex)
    self.itemList = {}
    for index = startIndex, endIndex do
        local item = self:_getItem(index, startIndex, endIndex)
        item:Show()
        item:SetData(dataList[index])
        table.insert(self.itemList, item)
    end
    self:_setDragableComponentEnabled(#dataList > self.perPageCount)
    self:_hideOutRangeList()
    self:Layout()
    self:_recalculateSize()
    self:_refreshTurnButton()
    if (math.abs(self.contentTrans.localPosition.x)) > math.abs(self:_getTargetX(self.totalPage)) then
        UtilsUI.SetX(self.contentTrans, self:_getTargetX(self.totalPage))
    end
end

function ScrollPage:Layout()
    for _, item in ipairs(self.itemList) do
        local index = item.index
        local page = math.floor((index - 1) / self.perPageCount)
        local columnIndex = (index - 1) % self.column
        local x = page * self.maskWidth + self.paddingLeft + columnIndex * (self.itemWidth + self.gapHorizontal)
        local rowIndex = math.floor((index - 1) / self.column) % self.row
        local y = self.paddingTop + rowIndex * (self.itemHeight + self.gapVertical)
        item:SetDefaultAnchor()
        item:SetPosition(x + self.itemWidth * 0.5, -y - self.itemHeight * 0.5)
    end
end

-- private function
function ScrollPage:_tweenMove(page)
    self.tweenId = Tween.Instance:MoveLocalX(self.contentTrans.gameObject, self:_getTargetX(page), 0.3).id
end

function ScrollPage:_recalculateSize()
    self.contentTrans.sizeDelta = Vector2(self.totalPage * self.maskWidth, self.maskHeight)
end

function ScrollPage:_setDragableComponentEnabled(enabled)
    if not self.changeMaskShader then
        self.scrollRect.enabled = enabled
        self.customDragButton.enabled = enabled
        self.mask.enabled = enabled
        self.maskImage.enabled = enabled
    end
end

function ScrollPage:_getTargetX(page)
    return -(page - 1) * self.maskWidth
end

function ScrollPage:_hideOutRangeList()
    if self.cacheOutRangeList then
        for i = 1, #self.cacheOutRangeList do
            self.cacheOutRangeList[i]:Hiden()
        end
    end
end

function ScrollPage:_getIndexRange(currentPage)
    local startIndex = (currentPage - 2) * self.perPageCount + 1
    local endIndex = (currentPage + 1) * self.perPageCount
    return math.max(startIndex, 1), math.min(endIndex, #self.dataList)
end

function ScrollPage:_cacheItemList(startIndex, endIndex)
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

function ScrollPage:_refresh()
    local dataList = self.dataList
    local startIndex, endIndex = self:_getIndexRange(self.dynamicCurrentPage)
    self:_cacheItemList(startIndex, endIndex)
    self.itemList = {}
    for index = startIndex, endIndex do
        local item, getWay = self:_getItem(index)
        item:Show()
        if getWay ~= ScrollPage.GET_ITEM_WAY.exist then
            item:SetData(dataList[index])
        end
        table.insert(self.itemList, item)
    end
    self:_hideOutRangeList()
    self:Layout()
    self:_refreshTurnButton()
end

function ScrollPage:_getDynamicCurrentPage()
    local page = math.ceil((-self.contentTrans.localPosition.x + self.maskWidth / 2) / self.maskWidth)
    return Mathf.Clamp(page, 1, self.totalPage)
end

function ScrollPage:_getItem(index)
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

function ScrollPage:_refreshTurnButton()
    -- self.leftButton.gameObject:SetActive(self.currentPage ~= 1)
    -- self.rightButton.gameObject:SetActive(self.currentPage ~= self.totalPage)
end