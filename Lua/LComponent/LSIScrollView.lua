--LSIScrollView Is Short For Single Item Scroll View
--单元素滚动布局组件

--预设结构要求
--  LSIScrollView(带ScrollRect组件)
--      Mask(带Mask组件)
--          Content
--              Item(Anchors要求为左上角，方便计算，Pivot无要求)

--关键接口
--__init(transform, itemType, column, row)  初始化接口
--SetGap(gapHorizontal, gapVertical)        设置格子与格子之间的间隔
--SetData(dataList, commonData)             通过传入的数据创建格子并自动布局
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


LSIScrollView = LSIScrollView or BaseClass(LBaseScroll)

local _math_ceil = math.ceil
local _math_floor = math.floor
local _math_max = math.floor

function LSIScrollView:__init(transform, itemType, row, column)
    self.itemType = itemType
    self.row = row or UtilsBase.INT32_MAX
    self.column = column or UtilsBase.INT32_MAX
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0

    local maskSize = self.maskTrans.sizeDelta
    local scrollSize = self.scrollRectTrans.sizeDelta
    local maxSize = Vector2(_math_max(maxSize.x, scrollSize.x), _math_max(maxSize.y, scrollSize.y))
    self.maskTrans.sizeDelta = maxSize
    self.scrollRectTrans.sizeDelta = maxSize
    self.ReachBottomEvent = EventLib.New()
end

function LSIScrollView:__release()
    UtilsBase.CancelTween(self, "focusTweenId")
    UtilsBase.ReleaseField(self, "ReachBottomEvent")
end

-- public function --
function LSIScrollView:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
end

function LSIScrollView:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
end

--设置初始化时显示下标（为了性能优化）
function LSIScrollView:SetInitIndex(index)
    self.initIndex = index
end

function LSIScrollView:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData

    self:_CalculateSize()
    self:_SetInitPosition()
    self:_Update(true)
end

function LSIScrollView:SetCommonData(commonData)
    self.commonData = commonData
    for _, item in pairs(self.orderDict) do
        item:SetCommonData(commonData)
    end
end

function LSIScrollView:ResetPosition()
    self.contentTrans.anchoredPosition = Vector2.zero
    self.scrollRect:StopMovement()
end

function LSIScrollView:Focus(index, tweenMove)
    if self:_DataIsEmpty() then
        return
    end
    if self.dataList[index] == nil then
        return
    end
    UtilsBase.CancelTween(self, "focusTweenId")
    self.scrollRect:StopMovement()
    local position = self:_GetPosition(index)
    if self:_VerticalScroll() then
        local targetY = self:_LimitY(-position.y)
        if tweenMove then
            self.focusTweenId = Tween.Instance:MoveLocalY(self.contentTrans.gameObject, targetY, 0.3).id
        else
            UtilsUI.SetAnchoredY(self.contentTrans, targetY)
            self:_Update()
        end
    else
        local targetX = self:_LimitX(-position.x)
        if tweenMove then
            self.focusTweenId = Tween.Instance:MoveLocalX(self.contentTrans.gameObject, targetX, 0.3).id
        else
            UtilsUI.SetAnchoredX(self.contentTrans, targetX)
            self:_Update()
        end
    end
end

--获取下标对应的Item，如果不在显示范围内会返回空，注意判空
function LSIScrollView:GetItem(index)
    return self.itemDict and self.itemDict[index]
end
-- public function end --

function LSIScrollView:_OnValueChanged(value)
    LBaseScroll._OnValueChanged(self, value)
    self:_FireReachBottomEvent(value)
end

function LSIScrollView:_FireReachBottomEvent(value)
    if self:_DataIsEmpty() then
        return
    end
    if self.endIndex == #self.dataList then
        if self:_VerticalScroll() then
            if self.height > self.maskHeight then
                if value.y * (self.height - self.maskHeight) < -5 then
                    if not self.reachBottomFire then
                        self.ReachBottomEvent:Fire()
                        self.reachBottomFire = true
                    end
                else
                    self.reachBottomFire = false
                end
            end
        else
            if self.width > self.maskWidth then
                if (value.x - 1) * (self.width - self.maskWidth) > (-self.paddingRight + 5) then
                    if not self.reachBottomFire then
                        self.ReachBottomEvent:Fire()
                        self.reachBottomFire = true
                    end
                else
                    self.reachBottomFire = false
                end
            end
        end
    end
end

function LSIScrollView:_CalculateSize()
    local maxColumn, maxRow
    local dataLength = self:_GetDataLength()
    if self:_VerticalScroll() then
        maxRow = math.ceil(dataLength / self.column)
        maxColumn = dataLength > self.column and self.column or dataLength
    else
        maxColumn = math.ceil(dataLength / self.row)
        maxRow = dataLength > self.row and self.row or dataLength
    end
    local width = self.paddingLeft + (self.itemWidth + self.gapHorizontal) * maxColumn + self.paddingRight
    local height = self.paddingTop + (self.itemHeight + self.gapVertical) * maxRow + self.paddingBottom
    self.width = width
    self.height = height
    self.contentTrans.sizeDelta = Vector2(width, height)
end

function LSIScrollView:_GetPosition(index)
    local columnIndex, rowIndex
    if self:_VerticalScroll() then
        columnIndex = (index - 1) % self.column
        rowIndex = math.floor((index - 1) / self.column)
    else
        columnIndex = math.floor((index - 1) / self.row)
        rowIndex = (index - 1) % self.row
    end
    local x = self.paddingLeft + columnIndex * (self.itemWidth + self.gapHorizontal)
    local y = self.paddingTop + rowIndex * (self.itemHeight + self.gapVertical)
    return Vector2(x, -y)
end

function LSIScrollView:_SetInitPosition()
    if self.initIndex then
        local index = self.initIndex
        self.initIndex = nil
        if index < 1 or index > self:_GetDataLength() then
            return
        end
        local position = self:_GetPosition(index)
        if self:_VerticalScroll() then
            UtilsUI.SetAnchoredY(self.contentTrans, self:_LimitY(-position.y))
        else
            UtilsUI.SetAnchoredX(self.contentTrans, self:_LimitX(-position.x))
        end
    else
        if self:_VerticalScroll() then
            if self.contentTrans.anchoredPosition.y > self:_GetContentMaxY() then
                UtilsUI.SetAnchoredY(self.contentTrans, self:_GetContentMaxY())
            end
        else
            if self.contentTrans.anchoredPosition.x < self:_GetContentMinX() then
                UtilsUI.SetAnchoredX(self.contentTrans, self:_GetContentMinX())
            end
        end
    end
end

function LSIScrollView:_GetContentMinX()
    local minX = self.maskWidth - self.width
    return minX > 0 and 0 or minX
end

function LSIScrollView:_LimitX(x)
    local minX = self:_GetContentMinX()
    return math.max(x, minX)
end

function LSIScrollView:_GetContentMaxY()
    local maxY = self.height - self.maskHeight
    return maxY < 0 and 0 or maxY
end

function LSIScrollView:_LimitY(y)
    local maxY = self:_GetContentMaxY()
    return y <= maxY and y or maxY
end

function LSIScrollView:_GetOrderStartIndex()
    if self:_VerticalScroll() then
        local rowIndex = self:_GetStartRowIndex()
        return (rowIndex - 1) * self.column + 1
    else
        local columnIndex = self:_GetStartColumnIndex()
        return (columnIndex - 1) * self.row + 1
    end
end

function LSIScrollView:_GetOrderEndIndex()
    local result
    if self:_VerticalScroll() then
        local rowIndex = self:_GetEndRowIndex()
        result = rowIndex * self.column
    else
        local columnIndex = self:_GetEndColumnIndex()
        result = columnIndex * self.row
    end
    local dataLength = self:_GetDataLength()
    return result <= dataLength and result or dataLength
end

function LSIScrollView:_GetDataLength()
    return self.dataList and #self.dataList or 0
end

function LSIScrollView:_GetStartRowIndex()
    return self:_GetRowIndex(self:_GetMaskTop() - 0.1)
end

function LSIScrollView:_GetEndRowIndex()
    return self:_GetRowIndex(self:_GetMaskBottom() + 0.1) 
end

function LSIScrollView:_GetStartColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskLeft() + 0.1)
end

function LSIScrollView:_GetEndColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskRight() - 0.1)
end

function LSIScrollView:_GetRowIndex(y)
    local result = math.ceil((-y - self.paddingTop) / (self.itemHeight + self.gapVertical))
    return result < 1 and 1 or result
end

function LSIScrollView:_GetColumnIndex(x)
    local result = math.ceil((x - self.paddingLeft) / (self.itemWidth + self.gapHorizontal))
    return result < 1 and 1 or result
end
