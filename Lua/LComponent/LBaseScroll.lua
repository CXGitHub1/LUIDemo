--把滚动复用抽象成
--维护一个有序列表，判断mask遮罩的前后下标是否一致，如果不一致则更新
LBaseScroll = LBaseScroll or BaseClass()

function LBaseScroll:__init(transform)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.orderDict = nil
    self.eventNameList = nil
    self:_InitScrollRect(transform)
    self:_InitMask(transform:Find(LDefine.MASK_NAME))
    self:_InitContent(self.maskTrans:Find(LDefine.CONTENT_NAME))
    self:_InitTemplate()

    self.ItemSelectEvent = EventLib.New()
end

function LBaseScroll:__release()
    UtilsBase.ReleaseTable(self, "eventNameList")
end

function LBaseScroll:_InitScrollRect(transform)
    local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
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
function LBaseScroll:_Update()
    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    for index = self.startIndex, self.endIndex do
        local item, getWay = self:_GetItem(index)
        item:SetActive(true)
        if getWay ~= LDefine.GetItemWay.exist then
            item:SetData(self.dataList[index], self.commonData)
            item:SetPosition(self:_GetPosition(index))
            self.orderDict[index] = item
        end
    end
end

function LBaseScroll:_GetItem(index)
    if self.orderDict and self.orderDict[index] then
        local item = self.orderDict[index]
        return item, LDefine.GetItemWay.exist
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        local item = table.remove(self.itemPoolList)
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

function LBaseScroll:_OnValueChanged(value)
    if self:_IsDataListEmpty() then
        return
    end
    if self.startIndex ~= self:_GetStartIndex() or
        self.endIndex ~= self:_GetEndIndex() then
        self:_Update()
    end
end

function LBaseScroll:_GetStartIndex()
    pError("重写_GetStartIndex方法")
end

function LBaseScroll:_GetEndIndex()
    pError("重写_GetEndIndex方法")
end

function LBaseScroll:_PushPool(item)
    item:SetActive(false)
    local orderIndex = self:_GetOrderIndex(item.index)
    self.orderDict[orderIndex] = nil
    if self.itemPoolList == nil then
        self.itemPoolList = {}
    end
    table.insert(self.itemPoolList, item)
end

function LBaseScroll:_PushUnUsedItem()
    if self.orderDict then
        for index, item in pairs(self.orderDict) do
            if index < self.startIndex or index > self.endIndex then
                self:_PushPool(item)
            end
        end
    end
end

function LBaseScroll:_IsDataListEmpty()
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
