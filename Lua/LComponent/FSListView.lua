--chen quan
--FSListView 表格组件

--预设结构要求
--  FSListView
--      Item(Anchors要求为左上角，方便计算，Pivot无要求)

--关键接口
--__init(transform, itemType, column, row, direction)   初始化接口
--SetGap(gapHorizontal, gapVertical)                    设置格子与格子之间的间隔
--SetData(dataList, commonData)                         通过传入的数据创建格子并自动布局
--ItemSelectEvent                                       格子点击事件

--其它常用接口
--AddItemEvent  扩展监听格子的派发事件
--SetStaticData 设置格子静态数据
--SetCommonData 重新设置公共数据
--SetPadding    设置边界与格子的偏移值

FSListView = FSListView or BaseClass()

local _table_insert = table.insert
local _next = next
local _ipairs = ipairs
local _pairs = pairs
local _math_floor = math.floor

--初始化函数
--transform FSListView对应的节点
--itemType  每个格子对应的类（需要继承FSItem）
--column    表格的最大列数（默认UtilsBase.INT32_MAX）
--row       表格的最大行数（默认UtilsBase.INT32_MAX）
--direction 表格格子的布局方向（默认从左往右）
function FSListView:__init(transform, itemType, column, row, direction)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.itemType = itemType
    self.column = column or UtilsBase.INT32_MAX
    self.row = row or UtilsBase.INT32_MAX
    self.layoutDirection = direction or LayoutDefine.Direction.horizontal
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.staticData = nil

    self:_InitItem(transform:Find(LayoutDefine.ITEM_NAME))

    self.cacheList = {}
    self.itemList = {}
    self.ItemSelectEvent = EventLib.New()
end

function FSListView:_InitItem(transform)
    self.template = transform.gameObject
    self.template:SetActive(true)
    transform.localScale = Vector3.zero
    local size = transform.sizeDelta
    self.itemWidth = size.x
    self.itemHeight = size.y
end

function FSListView:__delete()
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.TableDeleteMe(self, "cacheList")
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            UtilsBase.FieldDeleteMe(self, eventName)
        end
    end
end

--设置格子与格子之间的间距
function FSListView:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
end

--设置边界与格子的偏移值
function FSListView:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
end

--扩展监听格子的派发事件
function FSListView:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    _table_insert(self.eventNameList, eventName)
    self[eventName] = EventLib.New()
end

--设置格子静态数据
function FSListView:SetStaticData(data)
    self.staticData = data
end

--通过传入的数据创建格子并自动布局
--dataList      数据列表，与每个Item的数据一一对应
--commonData    共用数据，每个Item都需要用到的数据
function FSListView:SetData(dataList, commonData)
    if dataList then
        for index, data in _ipairs(dataList) do
            local item = self:_GetItem(index)
            item:SetActive(true)
            item:SetData(data, commonData)
            self.itemList[index] = item
        end
    end
    self:_HideCacheList(dataList)
    self:Layout()
end

function FSListView:Layout()
    if _next(self.itemList) == nil then
        self.transform.sizeDelta = Vector2.zero
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
        item:SetPosition(Vector2(x, y))
        if self:_GetPageIndex(index) == 1 then
            pageColumnMax, pageRowMax = self:_CalcPageInfo(#self.itemList, index)
        end

        local borderX = x + self.itemWidth
        local borderY = y - self.itemHeight
        if borderX > pageXMax then pageXMax = borderX end
        if borderX + self.paddingRight > xMax then
            xMax = borderX + self.paddingRight
        end
        if borderY - self.paddingBottom < yMin then
            yMin = borderY - self.paddingBottom
        end

        if self:_GetPageRow(index) == pageRowMax and self:_GetPageColumn(index) == pageColumnMax then --下一页第一个Item
            x = pageXMax + self.gapHorizontal
            y = pageYMax
            pageXMin = x
        else
            x, y = self:_CalcNextItemPosition(index, x, y, pageXMin, pageYMax, pageColumnMax, pageRowMax)
        end
    end
    self.transform.sizeDelta = Vector2(xMax, -yMin)
end

--重新设置公共数据
--commonData    共用数据，每个Item都需要用到的数据
function FSListView:SetCommonData(commonData)
    self.commonData = commonData
    if _next(self.itemList) == nil then
        return
    end
    for _, item in _pairs(self.itemList) do
        item:SetCommonData(commonData)
    end
end

function FSListView:GetSize()
    return self.transform.sizeDelta
end

function FSListView:SetActive(active)
    self.gameObject:SetActive(active)
end

function FSListView:GetItemCount()
    return #self.itemList
end

function FSListView:GetItem(index)
    return self.itemList[index]
end

function FSListView:GetItemList()
    return self.itemList
end

-- private function --
function FSListView:_CalcPageInfo(totalLength, pageEndIndex)
    if self:_IsHorizontalLayout() then
        local pageLength = (#self.itemList - pageEndIndex + 1)
        local pageColumnMax = pageLength > self.column and self.column or pageLength
        local pageRowMax = _math_floor((pageLength - 1) / self.column) + 1
        if pageRowMax > self.row then
            pageRowMax = self.row
        end
        return pageColumnMax, pageRowMax
    else
        local pageLength = (#self.itemList - pageEndIndex + 1)
        local pageRowMax = pageLength > self.row and self.row or pageLength
        local pageColumnMax = _math_floor((pageLength - 1) / self.row) + 1
        if pageColumnMax > self.column then
            pageColumnMax = self.column
        end
        return pageColumnMax, pageRowMax
    end
end

function FSListView:_CalcNextItemPosition(index, x, y, pageXMin, pageYMax, pageColumnMax, pageRowMax)
    if self:_IsHorizontalLayout() then
        if self:_GetPageColumn(index) == pageColumnMax then
            y = y - self.itemHeight - self.gapVertical
            x = pageXMin
        else
            x = x + self.itemWidth + self.gapHorizontal
        end
    else
        if self:_GetPageRow(index) == pageRowMax then
            y = pageYMax
            x = x + self.itemWidth + self.gapHorizontal
        else
            y = y - self.itemHeight - self.gapVertical
        end
    end
    return x, y
end

function FSListView:_GetItem(index)
    local item = self.cacheList[index]
    if item == nil then
        local go = GameObject.Instantiate(self.template)
        go.transform:SetParent(self.transform, false)
        item = self.itemType.New(go)
        item:SetIndex(index)
        if self.staticData then
            item:InitStaticData(self.staticData)
        end
        self.cacheList[index] = item
        item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
        if self.eventNameList then
            for i = 1, #self.eventNameList do
                local eventName = self.eventNameList[i]
                item[eventName]:AddListener(function(...) self[eventName]:Fire(...) end)
            end
        end
    end
    return item
end

function FSListView:_HideCacheList(dataList)
    local startIndex = dataList and (#dataList + 1) or 1
    for i = startIndex, #self.cacheList do
        self.itemList[i] = nil
        self.cacheList[i]:SetActive(false)
    end
end

function FSListView:_IsHorizontalLayout()
    return self.layoutDirection == LayoutDefine.Direction.horizontal
end

function FSListView:_GetPageRow(index)
    local index = self:_GetPageIndex(index)
    if self:_IsHorizontalLayout() then
        return _math_floor((index - 1) / self.column) + 1
    else
        return (index - 1) % self.row + 1
    end
end

function FSListView:_GetPageColumn(index)
    local index = self:_GetPageIndex(index)
    if self:_IsHorizontalLayout() then
        return (index - 1) % self.column + 1
    else
        return _math_floor((index - 1) / self.row) + 1
    end
end

function FSListView:_GetPageIndex(index)
    return (index - 1) % (self.row * self.column) + 1
end
