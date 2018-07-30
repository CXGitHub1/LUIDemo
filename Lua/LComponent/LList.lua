LList = LList or BaseClass()

LList.ITEM_NAME = "Item"

print(11111)

LList.Direction = {
    horizontal = 1,
    vertical = 2,
}

function LList:__init(transform, itemType, row, column, direction)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.itemType = itemType
    self.row = row or UtilsBase.INT32_MAX
    self.column = column or UtilsBase.INT32_MAX
    self.layoutDirection = direction
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0

    self:InitItem(transform:Find(LList.ITEM_NAME))

    self.cacheList = {}
    self.itemList = {}
    self.ItemSelectEvent = EventLib.New()
end

function LList:InitItem(transform)
    self.template = transform.gameObject
    self.template:SetActive(false)
    self.itemWidth = transform.sizeDelta.x
    self.itemHeight = transform.sizeDelta.y
end

function LList:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
end

function LList:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
end

function LList:SetStaticData(data)
    self.staticData = data
end

function LList:__release()
    UtilsBase.FieldRelease(self, "ItemSelectEvent")
    UtilsBase.TableRelease(self, "cacheList")
end

function LList:SetData(dataList, commonData)
    if dataList then
        self.itemList = {}
        for index, data in ipairs(dataList) do
            local item = self:getItem(index)
            item:SetActive(true)
            item:SetData(data, commonData)
            table.insert(self.itemList, item)
        end
    else
        self.itemList = nil
    end
    self:HideCacheList()
    self:Layout()
end

function LList:CalcPageInfo(totalLength, index)
    if self:IsHorizontalLayout() then
        local pageLength = (#self.itemList - index + 1)
        local pageColumnMax = pageLength > self.column and self.column or pageLength
        local pageRowMax = math.floor((pageLength - 1) / self.column) + 1
        if pageRowMax > self.row then
            pageRowMax = self.row
        end
        return pageColumnMax, pageRowMax
    else
        local pageLength = (#self.itemList - index + 1)
        local pageRowMax = pageLength > self.row and self.row or pageLength
        local pageColumnMax = math.floor((pageLength - 1) / self.row) + 1
        if pageColumnMax > self.column then
            pageColumnMax = self.column
        end
        return pageColumnMax, pageRowMax
    end
end

function LList:CalcBorder(index, xMax, yMin)
    if self:GetPageColumn(index) == pageColumnMax then
        if x + size.x + self.paddingRight > xMax then
            xMax = x + size.x + self.paddingRight
        end
    end
    if self:GetPageRow(index) == pageRowMax then
        if y - size.y - self.paddingBottom < yMin then
            yMin = y - size.y - self.paddingBottom
        end
    end
    return xMax, yMin
end

function LList:Layout()
    if self.itemList == nil then
        self.transform.sizeDelta = Vector2(0, 0)
        return
    end
    local x = self.paddingLeft
    local y = -self.paddingTop
    local pageXMin = self.paddingLeft
    local pageXMax = self.paddingLeft
    local pageYMax = -self.paddingTop
    local xMax = x
    local yMin = y
    local pageColumnMax
    local pageRowMax
    --超过一页之后是从左往右排序
    for index, item in ipairs(self.itemList) do
        local size = item:GetSize()
        if self:IsHorizontalLayout() then
            item:SetPosition(Vector2(x, y))
            if self:GetPageIndex(index) == 1 then
                pageColumnMax, pageRowMax = self:CalcPageInfo(#self.itemList, index)
            end
            --先算边界值
            local borderX = x + size.x
            local borderY = y - size.y
            if borderX > pageXMax then pageXMax = borderX end
            --再与最大边界值比较
            if self:GetPageColumn(index) == pageColumnMax then
                if borderX + self.paddingRight > xMax then
                    xMax = borderX + self.paddingRight
                end
            end
            if self:GetPageRow(index) == pageRowMax then
                if borderY - self.paddingBottom < yMin then
                    yMin = borderY - self.paddingBottom
                end
            end
            --再算下一步的值
            if self:GetPageRow(index) == pageRowMax and self:GetPageColumn(index) == pageColumnMax then
                x = pageXMax + self.gapHorizontal
                y = pageYMax
                pageXMin = x
            elseif self:GetPageColumn(index) == pageColumnMax then
                y = y - size.y - self.gapVertical
                x = pageXMin
            else
                x = x + size.x + self.gapHorizontal
            end
        else
            item:SetPosition(Vector2(x, y))
            if self:GetPageIndex(index) == 1 then
                pageColumnMax, pageRowMax = self:CalcPageInfo(#self.itemList, index)
            end
            --先算边界值
            local borderX = x + size.x
            local borderY = y - size.y
            if borderX > pageXMax then pageXMax = borderX end
            --再与最大边界值比较
            if self:GetPageColumn(index) == pageColumnMax then
                if borderX + self.paddingRight > xMax then
                    xMax = borderX + self.paddingRight
                end
            end
            if self:GetPageRow(index) == pageRowMax then
                if borderY - self.paddingBottom < yMin then
                    yMin = borderY - self.paddingBottom
                end
            end
            --再算下一步的值
            if self:GetPageRow(index) == pageRowMax and self:GetPageColumn(index) == pageColumnMax then
                x = pageXMax + self.gapHorizontal
                y = pageYMax
                pageXMin = x
            elseif self:GetPageRow(index) == pageRowMax then
                y = pageYMax
                x = x + size.x + self.gapHorizontal
            else
                y = y - size.y - self.gapVertical
            end
        end
    end
    self.transform.sizeDelta = Vector2(xMax, -yMin)
end

function LList:GetSize()
    return self.transform.sizeDelta
end

function LList:GetItemCount()
    return #self.itemList
end

function LList:SetActive(active)
    self.gameObject:SetActive(active)
end

function LList:getItem(index)
    local item = self.cacheList[index]
    if item == nil then
        local go = GameObject.Instantiate(self.template)
        go.name = LList.ITEM_NAME .. tostring(index)
        go.transform:SetParent(self.transform, false)
        item = self.itemType.New(go)
        item:SetIndex(index)
        if self.staticData ~= nil then
            item:InitStaticData(self.staticData)
        end
        self.cacheList[index] = item
        item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
    end
    return item
end

function LList:GetItem(itemIndex)
    return self.itemList[itemIndex]
end

function LList:GetItemList()
    return self.itemList
end

function LList:GetSetting()
    return self.setting
end

function LList:HideCacheList()
    local startIndex = self.itemList and #self.itemList + 1 or 1
    for i = startIndex, #self.cacheList do
        self.cacheList[i]:SetActive(false)
    end
end

function LList:IsHorizontalLayout()
    return self.layoutDirection == LList.Direction.horizontal
end

function LList:GetPageRow(index)
    local index = self:GetPageIndex(index)
    if self:IsHorizontalLayout() then
        return math.floor((index - 1) / self.column) + 1
    else
        return (index - 1) % self.row + 1
    end
end

function LList:GetPageColumn(index)
    local index = self:GetPageIndex(index)
    if self:IsHorizontalLayout() then
        return (index - 1) % self.column + 1
    else
        return math.floor((index - 1) / self.row) + 1
    end
end

function LList:GetPageIndex(index)
    return (index - 1) % (self.row * self.column) + 1
end
