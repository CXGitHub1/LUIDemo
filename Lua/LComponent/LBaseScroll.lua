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
    self.itemDict = nil
    self.eventNameList = nil
    self:_InitScrollRect(transform)
    self:_InitMask(transform:Find(LDefine.MASK_NAME))
    self:_InitContent(self.maskTrans:Find(LDefine.CONTENT_NAME))
    self:_InitTemplate()
    self:_InitExtend()

    self.itemPoolList = nil
    self.ItemSelectEvent = EventLib.New()
end

function LBaseScroll:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            UtilsBase.FieldDeleteMe(self, eventName)
        end
    end
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
    self.templateTrans = self.template.transform
    self.templateTrans.localScale = Vector3Zero
end

function LBaseScroll:_InitExtend()
    self.extendTrans = self.contentTrans:Find(LDefine.EXTEND_NAME)
end

-- public function start
function LBaseScroll:SetData()
    pError("重写SetData方法")
end

function LBaseScroll:AddItemEvent(...)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    local tb = {...}
    for i = 1, #tb do
        local eventName = tb[i]
        _table_insert(self.eventNameList, eventName)
        self[eventName] = EventLib.New()
    end
end

function LBaseScroll:GetHorizontalNormalizedPosition(x)
    local result = 0
    if self.width > self.maskWidth then
        result = x / (self.width - self.maskWidth)
    end
    return result
end

function LBaseScroll:GetVerticalNormalizedPosition(y)
    local result = 0
    if self.height > self.maskHeight then
        result = y / (self.height - self.maskHeight)
    end
    return 1 - result
end
-- public function end

function LBaseScroll:_GetOrderStartIndex()
    pError("需要重写_GetOrderStartIndex方法")
end

function LBaseScroll:_GetOrderEndIndex()
    pError("需要重写_GetOrderEndIndex方法")
end

function LBaseScroll:_GetPosition()
    pError("需要重写_GetPosition方法")
end

function LBaseScroll:_Update(force)
    self.orderStartIndex = self:_GetOrderStartIndex()
    self.orderEndIndex = self:_GetOrderEndIndex()
    self:_PushUnUsedItem()
    for orderIndex = self.orderStartIndex, self.orderEndIndex do
        local index = self:_OrderIndexToIndex(orderIndex)
        --因为翻页组件的存在，index所对应的orderIndex并不连续，会出现部分冗余的orderIndex
        --例子是 水平滚动，水平布局的翻页组件，每页3*3，当数据长度为3，就会出现不连续的orderIndex
        if self.dataList[index] then
            local item, getWay = self:_GetItem(index)
            item:SetActive(true)
            if force or getWay ~= LDefine.GetItemWay.exist then
                item:SetPosition(self:_GetPosition(orderIndex))
                item:SetData(self.dataList[index], self.commonData)
                if self.orderDict == nil then self.orderDict = {} end
                if self.itemDict == nil then self.itemDict = {} end
                self.orderDict[orderIndex] = item
                self.itemDict[index] = item
            end
        end
    end
end

--根据排序下标转换为实际下标
function LBaseScroll:_OrderIndexToIndex(orderIndex)
    return orderIndex
end

function LBaseScroll:_GetItem(index)
    if self.itemDict and self.itemDict[index] then
        local item = self.itemDict[index]
        return item, LDefine.GetItemWay.exist
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        local item = _table_remove(self.itemPoolList)
        item:InitFromCache(index) 
        return item, LDefine.GetItemWay.cache
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = self.itemType.New(go)
    item:SetIndex(index)
    if self.extendTrans then
        item:SetExtendTrans(self.extendTrans)
    end
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

function LBaseScroll:_PushPool(item, orderIndex)
    item:SetActive(false)
    local index = item.index
    self.itemDict[index] = nil
    self.orderDict[orderIndex] = nil
    if self.itemPoolList == nil then
        self.itemPoolList = {}
    end
    table.insert(self.itemPoolList, item)
end

function LBaseScroll:_PushUnUsedItem()
    if self.orderDict then
        for orderIndex, item in pairs(self.orderDict) do
            if orderIndex < self.orderStartIndex or orderIndex > self.orderEndIndex then
                self:_PushPool(item, orderIndex)
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

function LBaseScroll:_FormatPrefab(rect, setPosition)
    rect.pivot = Vector2Up
    rect.anchorMin = Vector2Up
    rect.anchorMax = Vector2Up
    if setPosition then
        rect.anchoredPosition3D = Vector3Zero
    end
end
