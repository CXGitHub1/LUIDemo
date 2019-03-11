LScrollPage = LScrollPage or BaseClass()

function LScrollPage:__init(transform, itemType, row, column, direction)
    self.itemType = itemType
    self.row = row or 1
    self.column = column or 1
    self.itemLayoutDirection = direction or LDefine.Direction.horizontal
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.perPageCount = self.row * self.column

    self.contentTrans = transform:Find(LDefine.MASK_NAME .. "/" .. LDefine.CONTENT_NAME)
    self:_InitTemplateItem()
    self:_InitScrollRect(transform)
    self:_InitMask(transform:Find(LDefine.MASK_NAME))

    self.itemDict = {}
    self.itemPoolList = {}
    self.currentPage = 1
    self.ItemSelectEvent = EventLib.New()
end

function LScrollPage:_InitTemplateItem()
    local template = self.contentTrans:Find(LDefine.ITEM_NAME).gameObject
    self.template = template
    self.itemWidth = template.transform.sizeDelta.x
    self.itemHeight = template.transform.sizeDelta.y
    self.template:SetActive(true)
    self.template.transform.localScale = Vector3Zero
end

function LScrollPage:_InitScrollRect(transform)
    local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function() self:_OnValueChanged() end)
    scrollRect.inertia = false
    if scrollRect.vertical then
        self.scrollDirection = LDefine.Direction.vertical
    else
        self.scrollDirection = LDefine.Direction.horizontal
    end
    local dragEvent = transform.gameObject:AddComponent(DragEvent)
    dragEvent.onBeginDrag:AddListener(function(value) self:_OnBeginDragEvent() end)
    dragEvent.onEndDrag:AddListener(function(value) self:_OnEndDragEvent() end)
end

function LScrollPage:_InitMask(transform)
    self.mask = transform:GetComponent(Mask)
    self.maskImage = UtilsUI.GetImage(transform)
    self:_CalcMaskSize()
end

function LScrollPage:_CalcMaskSize()
    local maskWidth = self.paddingLeft + self.paddingRight + self.column * self.itemWidth + (self.column - 1) * self.gapHorizontal
    local maskHeight = self.paddingTop + self.paddingBottom + self.row * self.itemHeight + (self.row - 1) * self.gapVertical
    self.maskWidth = maskWidth
    self.maskHeight = maskHeight
    self.mask.transform.sizeDelta = Vector2(maskWidth, maskHeight)
end

function LScrollPage:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseTable(self, "eventNameList")
    UtilsBase.CancelTween(self, "tweenId")
    UtilsBase.ReleaseTable(self, "itemDict")
    UtilsBase.ReleaseTable(self, "itemPoolList")
end

function LScrollPage:_OnBeginDragEvent()
    UtilsBase.CancelTween(self, "tweenId")
    self.beginDragPosition = self.contentTrans.anchoredPosition
end

function LScrollPage:_OnEndDragEvent()
    local endDragPosition = self.contentTrans.anchoredPosition
    local page
    if self:_PageHorizontalLayout() then
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
    self:_TweenMove(page)
end

function LScrollPage:_OnValueChanged()
    if self:_IsDataListEmpty() then
        return
    end
    if self.startIndex ~= self:_GetStartIndex() or
        self.endIndex ~= self:_GetEndIndex() then
        self:_Update()
    end
end

-- public function
function LScrollPage:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    self:_CalcMaskSize()
end

function LScrollPage:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self:_CalcMaskSize()
end

function LScrollPage:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    table.insert(self.eventNameList, eventName)
    self[eventName] = EventLib.New()
end

function LScrollPage:InitCurrentPage(page)
    self.initPage = page
end

function LScrollPage:SetCurrentPage(page, tween)
    local page = Mathf.Clamp(page, 1, self.totalPage)
    self.currentPage = page
    if tween then
        self:_TweenMove(page)
    else
        if self:_PageHorizontalLayout() then
            UtilsUI.SetAnchoredX(self.contentTrans, self:_GetTargetPosition(page).x)
        else
            UtilsUI.SetAnchoredY(self.contentTrans, self:_GetTargetPosition(page).y)
        end
        self.dynamicCurrentPage = self:_GetDynamicCurrentPage()
        self:_Update()
    end
end

function LScrollPage:GetTotalPage()
    return self.totalPage
end

function LScrollPage:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData

    local initPage = self.initPage
    self.initPage = nil
    if dataList then
        self.totalPage = math.ceil(#dataList / self.perPageCount)
    else
        self.totalPage = 0
    end

    self:
        --TODO
    if initPage then
        self.currentPage = initPage
    else
        self.startIndex = self:_GetStartIndex()
        self.endIndex = self:_GetEndIndex()
    end


    -- self.currentPage = math.min(self.currentPage, self.totalPage)

    self:_PushUnUsedItem()
    for index = self.startIndex, self.endIndex do
        local item = self:_GetItem(index)
        item:SetActive(true)
        item:SetData(dataList[index], commonData)
        item:SetPosition(self:_GetPosition(index))
        self.itemDict[index] = item
    end
    self:_CalculateSize()
    -- if initPage then
    --     self:SetCurrentPage(self.currentPage)
    -- end
    if self:_PageHorizontalLayout() then
        if (math.abs(self.contentTrans.localPosition.x)) > math.abs(self:_GetTargetPosition(self.totalPage).x) then
            UtilsUI.SetAnchoredX(self.contentTrans, self:_GetTargetPosition(self.totalPage).x)
        end
    else
        if (math.abs(self.contentTrans.localPosition.y)) > math.abs(self:_GetTargetPosition(self.totalPage).y) then
            UtilsUI.SetAnchoredY(self.contentTrans, self:_GetTargetPosition(self.totalPage).y)
        end
    end
end

-- private function
function LScrollPage:_TweenMove(page)
    UtilsBase.CancelTween(self, "tweenId")
    if self:_PageHorizontalLayout() then
        self.tweenId = Tween.Instance:MoveLocalX(self.contentTrans.gameObject, self:_GetTargetPosition(page).x, 0.3).id
    else
        self.tweenId = Tween.Instance:MoveLocalY(self.contentTrans.gameObject, self:_GetTargetPosition(page).y, 0.3).id
    end
end

function LScrollPage:_CalculateSize()
    if self:_PageHorizontalLayout() then
        self.contentTrans.sizeDelta = Vector2(self.totalPage * self.maskWidth, self.maskHeight)
    else
        self.contentTrans.sizeDelta = Vector2(self.maskWidth, self.totalPage * self.maskHeight)
    end
end

function LScrollPage:_GetTargetPosition(page)
    if self:_PageHorizontalLayout() then
        return Vector2(-(page - 1) * self.maskWidth, 0)
    else
        return Vector2(0, (page - 1) * self.maskHeight)
    end
end

function LScrollPage:_PushPool(item)
    item:SetActive(false)
    self.itemDict[item.index] = nil
    if self.itemPoolList == nil then
        self.itemPoolList = {}
    end
    table.insert(self.itemPoolList, item)
end

function LScrollPage:_PushUnUsedItem()
    if self.itemDict then
        for index, item in pairs(self.itemDict) do
            if index < self.startIndex or index > self.endIndex then
                self:_PushPool(item)
            end
        end
    end
end

function LScrollPage:_GetIndexRange(currentPage)
    local startIndex = (currentPage - 2) * self.perPageCount + 1
    local endIndex = (currentPage + 1) * self.perPageCount
    return math.max(startIndex, 1), math.min(endIndex, #self.dataList)
end

function LScrollPage:_Update()
    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    for index = self.startIndex, self.endIndex do
        local item, getWay = self:_GetItem(index)
        item:SetActive(true)
        if getWay ~= LDefine.GetItemWay.exist then
            item:SetData(self.dataList[index], self.commonData)
            item:SetPosition(self:_GetPosition(index))
            self.itemDict[index] = item
        end
    end
end

function LScrollPage:_GetPosition(index)
    local pageIndex = (index - 1) % self.perPageCount + 1
    local x, y
    local offset
    if self:_ItemHorizontalLayout() then
        column = (pageIndex - 1) % self.column + 1
        row = math.floor((pageIndex - 1) / self.column) + 1
    else
        row = (pageIndex - 1) % self.row + 1
        column = math.floor((pageIndex - 1) / self.row) + 1
    end
    x = self.paddingLeft + (column - 1) * (self.itemWidth + self.gapHorizontal)
    y = self.paddingTop + (row - 1) * (self.itemHeight + self.gapVertical)
    local page = math.floor((index - 1) / self.perPageCount)
    if self:_PageHorizontalLayout() then
        return Vector2(x + page * self.maskWidth, -y)
    else
        return Vector2(x, -y + -page * self.maskWidth)
    end
end

function LScrollPage:_GetDynamicCurrentPage()
    local page
    if self:_PageHorizontalLayout() then
        page = math.ceil((-self.contentTrans.anchoredPosition.x + self.maskWidth / 2) / self.maskWidth)
    else
        page = math.ceil((self.contentTrans.anchoredPosition.y + self.maskHeight / 2) / self.maskHeight)
    end
    return Mathf.Clamp(page, 1, self.totalPage)
end

function LScrollPage:_GetItem(index)
    if self.itemDict[index] then
        return self.itemDict[index], LDefine.GetItemWay.exist
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        item = table.remove(self.itemPoolList)
        item:InitFromCache(index) 
        return item, LDefine.GetItemWay.cache
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = self.itemType.New(go)
    item:SetIndex(index)
    item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            item[eventName]:AddListener(function(...) self[eventName]:Fire(...) end)
        end
    end
    return item, LDefine.GetItemWay.new
end

function LScrollPage:_ItemHorizontalLayout()
    return self.itemLayoutDirection == LDefine.Direction.horizontal
end

function LScrollPage:_PageHorizontalLayout()
    return self.scrollDirection == LDefine.Direction.horizontal
end

function LScrollPage:_GetStartIndex()
    if self:_IsVerticalScroll() then
        local rowIndex = self:_GetStartRowIndex()
        return (rowIndex - 1) * self.column + 1
    else
        local columnIndex = self:_GetStartColumnIndex()
        return (columnIndex - 1) * self.row + 1
    end
end

function LScrollPage:_GetEndIndex()
    local result
    if self:_IsVerticalScroll() then
        local rowIndex = self:_GetEndRowIndex()
        result = rowIndex * self.column
    else
        local columnIndex = self:_GetEndColumnIndex()
        result = columnIndex * self.row
    end
    local dataLength = self:_GetDataLength()
    return result <= dataLength and result or dataLength
end


function LScrollPage:_GetStartRowIndex()
    return self:_GetRowIndex(self:_GetMaskTop())
end

function LScrollPage:_GetEndRowIndex()
    return self:_GetRowIndex(self:_GetMaskBottom()) 
end

function LScrollPage:_GetStartColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskLeft())
end

function LScrollPage:_GetEndColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskRight()) 
end

function LScrollPage:_GetRowIndex(y)
    local result = math.ceil((-y - self.paddingTop) / (self.itemHeight + self.gapVertical))
    return result < 1 and 1 or result
end

function LScrollPage:_GetColumnIndex(x)
    local result = math.ceil((x - self.paddingLeft) / (self.itemWidth + self.gapHorizontal))
    return result < 1 and 1 or result
end

function LScrollPage:_GetMaskLeft()
    return -self.contentTrans.anchoredPosition.x
end

function LScrollPage:_GetMaskRight()
    return -self.contentTrans.anchoredPosition.x + self.maskWidth
end

function LScrollPage:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LScrollPage:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function LScrollPage:_IsVerticalScroll()
    return self.scrollDirection == LDefine.Direction.vertical
end

function LScrollPage:_IsDataListEmpty()
    return self.dataList == nil or next(self.dataList) == nil
end

function LScrollPage:_GetDataLength()
    return self.dataList and #self.dataList or 0
end


--Add
function LScrollPage:_GetOrderIndex()

    if self:_PageHorizontalLayout() then
        page = math.ceil((-self.contentTrans.anchoredPosition.x + self.maskWidth / 2) / self.maskWidth)
    else
        page = math.ceil((self.contentTrans.anchoredPosition.y + self.maskHeight / 2) / self.maskHeight)
    end

    
    if self:_IsVerticalScroll() then
        local rowIndex = self:_GetStartRowIndex()
        return (rowIndex - 1) * self.column + 1
    else
        local columnIndex = self:_GetStartColumnIndex()
        return (columnIndex - 1) * self.row + 1
    end
end
