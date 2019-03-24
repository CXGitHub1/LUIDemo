--滚动复用的基类

--把复用过程定义为生成一个有序列表，判断遮罩的前后下标是否一致，如果不一致则更新
LBaseScroll = LBaseScroll or BaseClass()

local _table_remove = table.remove
local _table_insert = table.insert
local _math_ceil = math.ceil
local _math_floor = math.floor

function LBaseScroll:__init(transform)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.orderDict = nil
    self.eventNameList = nil
    self:_InitScrollRect(transform)
    self:_InitMask(transform:Find(LDefine.MASK_NAME))
    self:_InitContent(self.maskTrans:Find(LDefine.CONTENT_NAME))
    self:_InitTemplate()

    self.itemPoolList = nil
    self.ItemSelectEvent = EventLib.New()
end

function LBaseScroll:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseTable(self, "eventNameList")
    UtilsBase.ReleaseTable(self, "itemPoolList")
    UtilsBase.ReleaseTable(self, "orderDict")
end

function LBaseScroll:_InitScrollRect(transform)
    local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRectTrans = transform
    scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    if scrollRect.vertical then
        self.scrollDirection = LDefine.Direction.vertical
    else
        self.scrollDirection = LDefine.Direction.horizontal
    end
end

function LBaseScroll:_InitMask(transform)
    local maskTrans = transform
    self.maskTrans = maskTrans
    local mask = maskTrans:GetComponent(Mask)
    self.mask = mask
    self.maskImage = UtilsUI.GetImage(transform)
    self.maskWidth = maskTrans.sizeDelta.x
    self.maskHeight = maskTrans.sizeDelta.y
    self.contentTrans = maskTrans:Find(LDefine.CONTENT_NAME)
end

function LBaseScroll:_InitContent(transform)
    self.contentTrans = transform
    self.contentGo = transform.gameObject
end

function LBaseScroll:_InitTemplate(transform)
    local itemTrans = self.contentTrans:Find(LDefine.ITEM_NAME)
    self.itemWidth = itemTrans.sizeDelta.x
    self.itemHeight = itemTrans.sizeDelta.y
    self.template = itemTrans.gameObject
    self.template:SetActive(true)
    self.template.transform.localScale = Vector3Zero
end

-- public function start
function LBaseScroll:SetData()
    pError("重写SetData方法")
end

function LBaseScroll:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    table.insert(self.eventNameList, eventName)
    self[eventName] = EventLib.New()
end
-- public function end


function LBaseScroll:_GetOrderStartIndex()
    pError("重写_GetOrderStartIndex方法")
end

function LBaseScroll:_GetOrderEndIndex()
    pError("重写_GetOrderEndIndex方法")
end

function LBaseScroll:_Update(force)
    self.orderStartIndex = self:_GetOrderStartIndex()
    self.orderEndIndex = self:_GetOrderEndIndex()
    self:_PushUnUsedItem()
    for orderIndex = self.orderStartIndex, self.orderEndIndex do
        local item, getWay = self:_GetItem(orderIndex)
        item:SetActive(true)
        if force or getWay ~= LDefine.GetItemWay.exist then
            local index = self:_OrderIndexToIndex(orderIndex)
            item:SetData(self.dataList[index], self.commonData)
            item:SetPosition(self:_GetPosition(index))
            if self.orderDict == nil then self.orderDict = {} end
            self.orderDict[orderIndex] = item
        end
    end
end

--根据需求重写有序下标转换为实际下标
function LBaseScroll:_OrderIndexToIndex(orderIndex)
    return orderIndex
end

function LBaseScroll:_GetItem(orderIndex)
    if self.orderDict and self.orderDict[orderIndex] then
        local item = self.orderDict[orderIndex]
        return item, LDefine.GetItemWay.exist
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        local index = self:_OrderIndexToIndex(orderIndex)
        local item = _table_remove(self.itemPoolList)
        item:InitFromCache(index) 
        return item, LDefine.GetItemWay.cache
    end
    local index = self:_OrderIndexToIndex(orderIndex)
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

function LBaseScroll:_OnValueChanged(value)
    if self:_DataIsEmpty() then
        return
    end
    if self.orderStartIndex ~= self:_GetOrderStartIndex() or
        self.orderEndIndex ~= self:_GetOrderEndIndex() then
        self:_Update()
    end
end

function LBaseScroll:_PushPool(item)
    item:SetActive(false)
    local orderIndex = self:_OrderIndexToIndex(item.index)
    self.orderDict[orderIndex] = nil
    if self.itemPoolList == nil then
        self.itemPoolList = {}
    end
    table.insert(self.itemPoolList, item)
end

function LBaseScroll:_PushUnUsedItem()
    if self.orderDict then
        for index, item in pairs(self.orderDict) do
            if index < self.orderStartIndex or index > self.orderEndIndex then
                self:_PushPool(item)
            end
        end
    end
end

function LBaseScroll:_DataIsEmpty()
    return self.dataList == nil or next(self.dataList) == nil
end

function LBaseScroll:_GetMaskLeft()
    return -self.contentTrans.anchoredPosition.x
end

function LBaseScroll:_GetMaskRight()
    return -self.contentTrans.anchoredPosition.x + self.maskWidth
end

function LBaseScroll:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LBaseScroll:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function LBaseScroll:_VerticalScroll()
    return self.scrollDirection == LDefine.Direction.vertical
end

function LBaseScroll:_HorizontalScroll()
    return self.scrollDirection == LDefine.Direction.horizontal
end

function LBaseScroll:_GetDataLength()
    return self.dataList and #self.dataList or 0
end