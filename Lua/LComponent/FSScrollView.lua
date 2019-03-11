--chen quan
--滚动表格组件

--预设结构要求
--  FSScrollView(带ScrollRect组件)
--      Mask(带Mask组件)
--          Content
--              Item(Anchors要求为左上角，方便计算，Pivot无要求)

--关键接口
--__init(transform, itemType, column, row)  初始化接口
--SetGap(gapHorizontal, gapVertical)        设置格子与格子之间的间隔
--SetData(dataList, commonData)             通过传入的数据创建格子并自动布局
--SetMaskMat()                              限制特效不超过Mask范围，记得在Item中修改特效的Shader
--Focus(index, tweenMove)                   跳转到指定下标的格子
--ResetPosition()                           重置展示内容
--ItemSelectEvent                           格子点击事件
--ReachBottomEvent                          拖动到结尾事件

--其它常用接口
--SetCommonData 重新设置公共数据
--SetStaticData 设置格子静态数据
--AddItemEvent  扩展监听格子的派发事件
--SetPadding    设置边界与格子的偏移值

FSScrollView = FSScrollView or BaseClass()

local _table_insert = table.insert
local _table_remove = table.remove
local _next = next
local _math_floor = math.floor
local _math_ceil = math.ceil
local _pairs = pairs

--初始化函数
--transform FSScrollView对应的节点
--itemType  每个格子对应的类（需要继承FSItem）
--column    表格的最大列数（默认UtilsBase.INT32_MAX）
--row       表格的最大行数（默认UtilsBase.INT32_MAX）
function FSScrollView:__init(transform, itemType, column, row)
    self.gameObject = transform.gameObject
    self.itemType = itemType
    self.column = column or UtilsBase.INT32_MAX
    self.row = row or UtilsBase.INT32_MAX
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.ItemSelectEvent = EventLib.New()
    self.ReachBottomEvent = EventLib.New()
    self.eventNameList = nil
    self.changeMaskShader = false

    self.itemDict = nil
    self.itemPoolList = nil

    self:_InitComponent(transform)
    self:_InitTemplate()
end

function FSScrollView:_InitComponent(transform)
     local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    if scrollRect.vertical then
        self.scrollDirection = LayoutDefine.Direction.vertical
    else
        self.scrollDirection = LayoutDefine.Direction.horizontal
    end
    local maskTrans = transform:Find(LayoutDefine.MASK_NAME)
    local mask = maskTrans:GetComponent(Mask)
    self.maskTrans = maskTrans
    self.mask = mask
    self.maskWidth = maskTrans.sizeDelta.x
    self.maskHeight = maskTrans.sizeDelta.y
    self.contentTrans = maskTrans:Find(LayoutDefine.CONTENT_NAME)
end

function FSScrollView:_InitTemplate()
    local itemTrans = self.contentTrans:Find(LayoutDefine.ITEM_NAME)
    self.template = itemTrans.gameObject
    self.template:SetActive(true)
    itemTrans.localScale = Vector3.zero
    self.itemWidth = itemTrans.sizeDelta.x
    self.itemHeight = itemTrans.sizeDelta.y
end

function FSScrollView:__delete()
    UtilsBase.TweenDelete(self, "focusTweenId")
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.FieldDeleteMe(self, "ReachBottomEvent")
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            UtilsBase.FieldDeleteMe(self, eventName)
        end
    end
    UtilsBase.TableDeleteMe(self, "itemDict")
    UtilsBase.TableDeleteMe(self, "itemPoolList")
end

-- public function --
--设置格子与格子之间的间距
function FSScrollView:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
end

--设置边界与格子的偏移值
function FSScrollView:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
end

--扩展监听格子的派发事件
function FSScrollView:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    _table_insert(self.eventNameList, eventName)
    self[eventName] = EventLib.New()
end

function FSScrollView:SetMaskMat()
    UtilsBase.SetMaskMat(UtilsUI.GetImage(self.maskTrans))
end

--设置格子静态数据
function FSScrollView:SetStaticData(data)
    self.staticData = data
end

--通过传入的数据创建格子并自动布局
--dataList      数据列表，与每个Item的数据一一对应
--commonData    共用数据，每个Item都需要用到的数据
function FSScrollView:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    if not self:_IsDataListEmpty() then
        if self.itemDict == nil then self.itemDict = {} end
        for index = self.startIndex, self.endIndex do
            local item = self:_GetItem(index)
            item:SetActive(true)
            item:SetData(self.dataList[index], commonData)
            item:SetPosition(self:_GetPosition(index))
            self.itemDict[index] = item
        end 
    end
    self:_CalcSizeDelta()
    self:_AdjustContentPosition()
end

--重新设置公共数据
--commonData    共用数据，每个Item都需要用到的数据
function FSScrollView:SetCommonData(commonData)
    self.commonData = commonData
    for _, item in _pairs(self.itemDict) do
        item:SetCommonData(commonData)
    end
end

--重置展示内容
function FSScrollView:ResetPosition()
    self.contentTrans.anchoredPosition = Vector2.zero
    self.scrollRect:StopMovement()
end

--跳转到指定下标的格子
--index     格子下标
--tweenMode 是否缓动
function FSScrollView:Focus(index, tweenMove)
    if self.dataList == nil and self.dataList[index] == nil then
        return
    end
    UtilsBase.TweenDelete(self, "focusTweenId")
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

function FSScrollView:_OnValueChanged(value)
    if self:_IsDataListEmpty() then
        return
    end
    if self.startIndex ~= self:_GetStartIndex() or
        self.endIndex ~= self:_GetEndIndex() then
        self:_Update()
    end
    self:_FireReachBottomEvent(value)
end

function FSScrollView:_FireReachBottomEvent(value)
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

function FSScrollView:_Update()
    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    for index = self.startIndex, self.endIndex do
        local item, getWay = self:_GetItem(index)
        item:SetActive(true)
        if getWay ~= LayoutDefine.GetItemWay.exist then
            item:SetData(self.dataList[index], self.commonData)
            item:SetPosition(self:_GetPosition(index))
            self.itemDict[index] = item
        end
    end
end

function FSScrollView:_IsDataListEmpty()
    return self.dataList == nil or _next(self.dataList) == nil
end

function FSScrollView:_GetItem(index)
    if self.itemDict and self.itemDict[index] then
        local item = self.itemDict[index]
        return item, LayoutDefine.GetItemWay.exist
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        local item = _table_remove(self.itemPoolList)
        item:InitFromCache(index) 
        return item, LayoutDefine.GetItemWay.cache
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = self.itemType.New(go)
    item:SetIndex(index)
    if self.staticData then
        item:InitStaticData(self.staticData)
    end
    item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Fire(index, item) end)
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            item[eventName]:AddListener(function(...) self[eventName]:Fire(...) end)
        end
    end
    return item, LayoutDefine.GetItemWay.new
end

function FSScrollView:_CalcSizeDelta()
    local maxColumn, maxRow
    local dataLength = self:_GetDataLength()
    if self:_IsVerticalScroll() then
        maxRow = _math_ceil(dataLength / self.column)
        maxColumn = dataLength > self.column and self.column or dataLength
    else
        maxColumn = _math_ceil(dataLength / self.row)
        maxRow = dataLength > self.row and self.row or dataLength
    end
    local width = self.paddingLeft + (self.itemWidth + self.gapHorizontal) * maxColumn + self.paddingRight
    local height = self.paddingTop + (self.itemHeight + self.gapVertical) * maxRow + self.paddingBottom
    self.width = width
    self.height = height
    self.contentTrans.sizeDelta = Vector2(width, height)
end

function FSScrollView:_GetPosition(index)
    local columnIndex, rowIndex
    if self:_IsVerticalScroll() then
        columnIndex = (index - 1) % self.column
        rowIndex = _math_floor((index - 1) / self.column)
    else
        columnIndex = _math_floor((index - 1) / self.row)
        rowIndex = (index - 1) % self.row
    end
    local x = self.paddingLeft + columnIndex * (self.itemWidth + self.gapHorizontal)
    local y = self.paddingTop + rowIndex * (self.itemHeight + self.gapVertical)
    return Vector2(x, -y)
end

function FSScrollView:_PushPool(item)
    item:SetActive(false)
    self.itemDict[item.index] = nil
    if self.itemPoolList == nil then
        self.itemPoolList = {}
    end
    _table_insert(self.itemPoolList, item)
end

function FSScrollView:_PushUnUsedItem()
    if self.itemDict then
        for index, item in _pairs(self.itemDict) do
            if index < self.startIndex or index > self.endIndex then
                self:_PushPool(item)
            end
        end
    end
end

function FSScrollView:_AdjustContentPosition()
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

function FSScrollView:_GetContentMinX()
    local minX = self.maskWidth - self.width
    return minX > 0 and 0 or minX
end

function FSScrollView:_LimitX(x)
    local minX = self:_GetContentMinX()
    return math.max(x, minX)
end

function FSScrollView:_GetContentMaxY()
    local maxY = self.height - self.maskHeight
    return maxY < 0 and 0 or maxY
end

function FSScrollView:_LimitY(y)
    local maxY = self:_GetContentMaxY()
    return y <= maxY and y or maxY
end

function FSScrollView:_IsVerticalScroll()
    return self.scrollDirection == LayoutDefine.Direction.vertical
end

function FSScrollView:_GetStartIndex()
    if self:_IsVerticalScroll() then
        local rowIndex = self:_GetStartRowIndex()
        return (rowIndex - 1) * self.column + 1
    else
        local columnIndex = self:_GetStartColumnIndex()
        return (columnIndex - 1) * self.row + 1
    end
end

function FSScrollView:_GetEndIndex()
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

function FSScrollView:_GetDataLength()
    return self.dataList and #self.dataList or 0
end

function FSScrollView:_GetStartRowIndex()
    return self:_GetRowIndex(self:_GetMaskTop())
end

function FSScrollView:_GetEndRowIndex()
    return self:_GetRowIndex(self:_GetMaskBottom()) 
end

function FSScrollView:_GetStartColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskLeft())
end

function FSScrollView:_GetEndColumnIndex()
    return self:_GetColumnIndex(self:_GetMaskRight()) 
end

function FSScrollView:_GetRowIndex(y)
    local result = _math_ceil((-y - self.paddingTop) / (self.itemHeight + self.gapVertical))
    return result < 1 and 1 or result
end

function FSScrollView:_GetColumnIndex(x)
    local result = _math_ceil((x - self.paddingLeft) / (self.itemWidth + self.gapHorizontal))
    return result < 1 and 1 or result
end

function FSScrollView:_GetMaskLeft()
    return -self.contentTrans.anchoredPosition.x
end

function FSScrollView:_GetMaskRight()
    return -self.contentTrans.anchoredPosition.x + self.maskWidth
end

function FSScrollView:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function FSScrollView:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end