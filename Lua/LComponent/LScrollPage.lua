--翻页组件

--预设结构要求
--  LScrollPage(带ScrollRect组件)
--      Mask(带Mask组件)
--          Content
--              Item(Anchors要求为左上角，方便计算，Pivot无要求)

--注意点
--ScrollRect和Mask的大小会动态设置

--关键接口
--__init(transform, itemType, row, column, itemLayoutDirection)  初始化函数
--SetGap(gapHorizontal, gapVertical)        设置格子与格子之间的间隔
--SetData(dataList, commonData)             通过传入的数据创建格子并自动布局
--SetMaskMat()                              限制特效不超过Mask范围，记得在Item中修改特效的Shader
--Focus(index, tweenMove)                   跳转到指定下标的格子
--ResetPosition()                           重置展示内容
--ItemSelectEvent                           格子点击事件
--ReachBottomEvent                          拖动到结尾事件
--GetItem(index)                            获取下标对应的Item，如果不在显示范围内会返回空，注意判空

--其它常用接口
--SetCommonData 重新设置公共数据
--SetStaticData 设置格子静态数据
--AddItemEvent  扩展监听格子的派发事件
--SetPadding    设置边界与格子的偏移值


LScrollPage = LScrollPage or BaseClass(LBaseScroll)

LScrollPage.TweenTime = 0.3

local _math_ceil = math.ceil
local _math_floor = math.floor


--初始化函数
--transform LScrollPage对应的节点
--itemType  每个格子对应的类（需要继承FSItem）
--column    表格的最大列数（默认UtilsBase.INT32_MAX）
--row       表格的最大行数（默认UtilsBase.INT32_MAX）
function LScrollPage:__init(transform, itemType, row, column, itemLayoutDirection)
    self.itemType = itemType
    self.row = row or 1
    self.column = column or 1
    self.itemLayoutDirection = itemLayoutDirection or LDefine.Direction.horizontal
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.perPageCount = self.row * self.column

    self.scrollRect.inertia = false
    self:_AddDragEvent(transform)
    self:_CalcMaskSize()

    self.currentPage = 1
end

function LScrollPage:__release()
    UtilsBase.CancelTween(self, "tweenId")
end

function LScrollPage:_OnBeginDragEvent()
    UtilsBase.CancelTween(self, "tweenId")
    self.beginDragPosition = self.contentTrans.anchoredPosition
end

function LScrollPage:_OnEndDragEvent()
    local endDragPosition = self.contentTrans.anchoredPosition
    local page
    if self:_HorizontalScroll() then
        page = _math_ceil(-endDragPosition.x / self.maskWidth)
        if endDragPosition.x < self.beginDragPosition.x then --鼠标向左拉动
            page = page + 1
        end
    else
        page = _math_ceil(endDragPosition.y / self.maskHeight)
        if endDragPosition.y > self.beginDragPosition.y then --鼠标向上拉动
            page = page + 1
        end
    end
    page = math.clamp(page, 1, self.totalPage)
    self.currentPage = page
    self:_TweenMove(page)
end

-- public function
--设置格子与格子之间的间距
function LScrollPage:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    self:_CalcMaskSize()
end

--设置每一页边界与格子的偏移值
function LScrollPage:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self:_CalcMaskSize()
end

--设置初始化时显示第几页（为了性能优化）
function LScrollPage:SetInitPage(page)
    self.initPage = page
end

--跳转到指定页数
--page      指定页数
--tweenMode 是否缓动
function LScrollPage:SetCurrentPage(page, tween)
    local page = math.clamp(page, 1, self.totalPage)
    self.currentPage = page
    if tween then
        self:_TweenMove(page)
    else
        self:_SetPagePosition(page)
        self:_Update()
    end
end

function LScrollPage:GetCurrentPage()
    return self.currentPage
end

function LScrollPage:GetTotalPage()
    return self.totalPage
end

function LScrollPage:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData

    if dataList then
        self.totalPage = _math_ceil(#dataList / self.perPageCount)
    else
        self.totalPage = 0
    end
    self:_CalculateSize()
    self:_SetInitPosition()
    self:_Update(true)
end

--获取下标对应的Item，如果不在显示范围内会返回空，注意判空
function LScrollPage:GetItem(index)
    return self.itemDict and self.itemDict[index]
end

-- override function

function LScrollPage:_OrderIndexToIndex(orderIndex)
    if self:_VerticalScroll() then
        --垂直滚动
        if self:_ItemHorizontalLayout() then
            return orderIndex
        else
            local pageIndex, row, column = self:_TransformIndex(orderIndex)
            return pageIndex * self.perPageCount + (row - 1) * self.column + column
        end
    else
        --水平滚动
        if self:_ItemHorizontalLayout() then
            local pageIndex, row, column = self:_TransformIndex(orderIndex)
            return pageIndex * self.perPageCount + (column - 1) * self.row + row
        else
            return orderIndex
        end
    end
end

-- private function

function LScrollPage:_AddDragEvent(transform)
    local dragEvent = transform.gameObject:AddComponent(DragEvent)
    dragEvent.onBeginDrag:AddListener(function(value) self:_OnBeginDragEvent() end)
    dragEvent.onEndDrag:AddListener(function(value) self:_OnEndDragEvent() end)
end

function LScrollPage:_CalcMaskSize()
    local maskWidth = self.paddingLeft + self.paddingRight + self.column * self.itemWidth + (self.column - 1) * self.gapHorizontal
    local maskHeight = self.paddingTop + self.paddingBottom + self.row * self.itemHeight + (self.row - 1) * self.gapVertical
    self.maskWidth = maskWidth
    self.maskHeight = maskHeight
    self.maskTrans.sizeDelta = Vector2(maskWidth, maskHeight)
    self.scrollRectTrans.sizeDelta = Vector2(maskWidth, maskHeight)
end

function LScrollPage:_SetInitPosition()
    if self.initPage then
        local initPage = math.clamp(self.initPage, 1, self.totalPage)
        self.initPage = nil
        self:_SetPagePosition(initPage)
    else
        --对之前坐标越界的情况进行处理，防止出现滚动
        if self:_HorizontalScroll() then
            if self.contentTrans.localPosition.x < self:_GetPagePosition(self.totalPage) then
                UtilsUI.SetAnchoredX(self.contentTrans, self:_GetPagePosition(self.totalPage))
            end
        else
            if self.contentTrans.localPosition.y > self:_GetPagePosition(self.totalPage) then
                UtilsUI.SetAnchoredY(self.contentTrans, self:_GetPagePosition(self.totalPage))
            end
        end
    end
end

function LScrollPage:_SetPagePosition(page)
    if self:_HorizontalScroll() then
        UtilsUI.SetAnchoredX(self.contentTrans, self:_GetPagePosition(page))
    else
        UtilsUI.SetAnchoredY(self.contentTrans, self:_GetPagePosition(page))
    end
end

function LScrollPage:_TweenMove(page)
    UtilsBase.CancelTween(self, "tweenId")
    if self:_HorizontalScroll() then
        self.tweenId = Tween.Instance:MoveLocalX(self.contentTrans.gameObject, self:_GetPagePosition(page), LScrollPage.TweenTime).id
    else
        self.tweenId = Tween.Instance:MoveLocalY(self.contentTrans.gameObject, self:_GetPagePosition(page), LScrollPage.TweenTime).id
    end
end

function LScrollPage:_CalculateSize()
    if self:_HorizontalScroll() then
        self.contentTrans.sizeDelta = Vector2(self.totalPage * self.maskWidth, self.maskHeight)
    else
        self.contentTrans.sizeDelta = Vector2(self.maskWidth, self.totalPage * self.maskHeight)
    end
end


function LScrollPage:_ItemHorizontalLayout()
    return self.itemLayoutDirection == LDefine.Direction.horizontal
end

function LScrollPage:_GetPagePosition(page)
    if self:_HorizontalScroll() then
        return -(page - 1) * self.maskWidth
    else
        return (page - 1) * self.maskHeight
    end
end

--把下标转换为 pageIndex, row, column
function LScrollPage:_TransformIndex(index)
    local indexInPage = (index - 1) % self.perPageCount + 1
    local row, column
    if self:_ItemHorizontalLayout() then
        column = (indexInPage - 1) % self.column + 1
        row = _math_floor((indexInPage - 1) / self.column) + 1
    else
        row = (indexInPage - 1) % self.row + 1
        column = _math_floor((indexInPage - 1) / self.row) + 1
    end
    local pageIndex = _math_floor((index - 1) / self.perPageCount)
    return pageIndex, row, column
end

function LScrollPage:_GetPosition(index)
    local pageIndex, row, column = self:_TransformIndex(index)
    local x = self.paddingLeft + (column - 1) * (self.itemWidth + self.gapHorizontal)
    local y = self.paddingTop + (row - 1) * (self.itemHeight + self.gapVertical)
    if self:_HorizontalScroll() then
        return Vector2(x + pageIndex * self.maskWidth, -y)
    else
        return Vector2(x, -y + -pageIndex * self.maskHeight)
    end
end

function LScrollPage:_GetOrderStartIndex()
    if self:_HorizontalScroll() then
        local startColumn = self:_GetStartColumn()
        return (startColumn - 1) * self.row + 1
    else
        local startRow = self:_GetStartRow()
        return (startRow - 1) * self.column + 1
    end
end

function LScrollPage:_GetOrderEndIndex()
    local result
    if self:_HorizontalScroll() then
        local endColumn = self:_GetEndColumn()
        result = endColumn * self.row
    else
        local endRow = self:_GetEndRow()
        result = endRow * self.column
    end
    local dataLength = self:_GetDataLength()
    return result <= dataLength and result or dataLength
end


--越大越好
function LScrollPage:_GetStartRow()
    local y = self:_GetMaskTop() - 0.1  -- 0.1的偏移是为了解决边界点的归属问题
    local pageIndex = math.floor(-y / self.maskHeight)
    local pageY = y + pageIndex * self.maskHeight
    local result = pageIndex * self.row
    if -pageY < (self.paddingTop + self.itemHeight) then
        result = result + 1
    elseif (self.maskHeight + pageY) < self.paddingBottom then
        result = result + self.row + 1
    else
        result = result + 1 + _math_ceil((-pageY - self.paddingTop - self.itemHeight) / (self.itemHeight + self.gapVertical))
    end
    return result < 1 and 1 or result
end

--越小越好
function LScrollPage:_GetEndRow()
    local y = self:_GetMaskBottom() + 0.1  -- 0.1的偏移是为了解决边界点的归属问题
    local pageIndex = math.floor(-y / self.maskHeight)
    local pageY = y + pageIndex * self.maskHeight
    local result = pageIndex * self.row
    if -pageY < self.paddingTop then
    elseif (self.maskHeight + pageY) < self.paddingBottom then
        result = result + self.row
    else
        result = result + _math_ceil((-pageY - self.paddingTop) / (self.itemHeight + self.gapVertical))
    end
    return result
end

--越大越好
function LScrollPage:_GetStartColumn()
    local x = self:_GetMaskLeft() + 0.1  -- 0.1的偏移是为了解决边界点的归属问题
    local pageIndex = math.floor(x / self.maskWidth)
    local pageX = x - pageIndex * self.maskWidth
    local result = pageIndex * self.column
    if pageX < (self.paddingLeft + self.itemWidth) then
        result = result + 1
    elseif (self.maskWidth - pageX) < self.paddingRight then
        result = result + self.column + 1
    else
        result = result + 1 + _math_ceil((pageX - self.paddingLeft - self.itemWidth) / (self.itemWidth + self.gapHorizontal))
    end
    return result < 1 and 1 or result
end

--越小越好
function LScrollPage:_GetEndColumn()
    local x = self:_GetMaskRight() - 0.1  -- 0.1的偏移是为了解决边界点的归属问题
    local pageIndex = math.floor(x / self.maskWidth)
    local pageX = x - pageIndex * self.maskWidth
    local result = pageIndex * self.column
    if pageX < self.paddingLeft then
    elseif (self.maskWidth - pageX) < self.paddingBottom then
        result = result + self.column
    else
        result = result + _math_ceil((pageX - self.paddingLeft) / (self.itemWidth + self.gapHorizontal))
    end
    return result
end
