--LSIScrollView Is Short For Single Item Scroll View
--单元素滚动布局组件
LSIScrollView = LSIScrollView or BaseClass(LBaseScroll)

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
    self.ReachBottomEvent = EventLib.New()

    self.orderDict = nil
    self.itemPoolList = nil
end

function LSIScrollView:__release()
    UtilsBase.CancelTween(self, "focusTweenId")
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseField(self, "ReachBottomEvent")
    UtilsBase.ReleaseTable(self, "eventNameList")
    UtilsBase.ReleaseTable(self, "orderDict")
    UtilsBase.ReleaseTable(self, "itemPoolList")
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

function LSIScrollView:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    if not self:_IsDataListEmpty() then
        if self.orderDict == nil then self.orderDict = {} end
        for index = self.startIndex, self.endIndex do
            local item = self:_GetItem(index)
            item:SetActive(true)
            item:SetData(self.dataList[index], commonData)
            item:SetPosition(self:_GetPosition(index))
            self.orderDict[index] = item
        end 
    end
    self:_CalcSizeDelta()
    self:_AdjustContentPosition()
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
    if self.dataList == nil and self.dataList[index] == nil then
        return
    end
    UtilsBase.CancelTween(self, "focusTweenId")
    self.scrollRect:StopMovement()
    local position = self:_GetPosition(index)
    if self:_IsVerticalScroll() then
        local targetY = self:_LimitY(-position.y)
        if tweenMove then
            self.focusTweenId = Tween.Instance:MoveLocalY(self.contentTrans.gameObject, targetY, 0.3).id
        else
            UtilsUI.SetAnchoredY(self.contentTrans, targetY)
        end
    else
        local targetX = self:_LimitX(-position.x)
        if tweenMove then
            self.focusTweenId = Tween.Instance:MoveLocalX(self.contentTrans.gameObject, targetX, 0.3).id
        else
            UtilsUI.SetAnchoredX(self.contentTrans, targetX)
        end
    end
end
-- public function end --

function LSIScrollView:_OnValueChanged(value)
    LBaseScroll._OnValueChanged(self, value)
    self:_FireReachBottomEvent(value)
end

function LSIScrollView:_FireReachBottomEvent(value)
    if self:_IsDataListEmpty() then
        return
    end
    if self.endIndex == #self.dataList then
        if self:_IsVerticalScroll() then
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

function LSIScrollView:_CalcSizeDelta()
    local maxColumn, maxRow
    local dataLength = self:_GetDataLength()
    if self:_IsVerticalScroll() then
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
    if self:_IsVerticalScroll() then
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

function LSIScrollView:_AdjustContentPosition()
    if self:_IsVerticalScroll() then
        if self.contentTrans.anchoredPosition.y > self:_GetContentMaxY() then
            UtilsUI.SetAnchoredY(self.contentTrans, self:_GetContentMaxY())
        end
    else
        if self.contentTrans.anchoredPosition.x < self:_GetContentMinX() then
            UtilsUI.SetAnchoredX(self.contentTrans, self:_GetContentMinX())
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

function LSIScrollView:_IsVerticalScroll()
    return self.scrollDirection == LDefine.Direction.vertical
end

function LSIScrollView:_GetStartIndex()
    if self:_IsVerticalScroll() then
        local rowIndex = self:_GetStartRowIndex()
        return (rowIndex - 1) * self.column + 1
    else
        local columnIndex = self:_GetStartColumnIndex()
        return (columnIndex - 1) * self.row + 1
    end
end

function LSIScrollView:_GetEndIndex()
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

function LSIScrollView:_GetDataLength()
    return self.dataList and #self.dataList or 0
end

function LSIScrollView:_GetStartRowIndex()
    return self:_GetRowIndex(self:_GetMaskTop())
end

function LSIScrollView:_GetEndRowIndex()
    return self:_GetRowIndex(self:_GetMaskBottom()) 
end

function LSIScrollView:_GetStartColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskLeft())
end

function LSIScrollView:_GetEndColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskRight()) 
end

function LSIScrollView:_GetRowIndex(y)
    local result = math.ceil((-y - self.paddingTop) / (self.itemHeight + self.gapVertical))
    return result < 1 and 1 or result
end

function LSIScrollView:_GetColumnIndex(x)
    local result = math.ceil((x - self.paddingLeft) / (self.itemWidth + self.gapHorizontal))
    return result < 1 and 1 or result
end