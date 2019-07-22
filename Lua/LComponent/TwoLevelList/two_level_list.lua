--chen quan
--二级列表

--参考用例
--RankLeftBlock

--预设结构
--TwoLevelList(带ScrollRect组件 pivot和Anchors都为左上角)
--  Mask(带Mask组件 pivot和Anchors都为左上角)
--    Content(pivot和Anchors都为左上角)
--      Item1(一级Item Anchors为左上角, pivot随意)
--      Item2(二级Item Anchors为左上角, pivot随意)

--注意
--初始化时会对预设做一些初始化设置，详见_InitFormatPrefab

--关键接口
--__init(transform, firstItemType, secondItemType)        初始化函数
--firstItemType和secondItemType需要实现选中效果
--参考:RankLeftExpandableItem的SetData() SetCommonData()
--参考:RankLeftItem的SetData() SetCommonData()
--SetGap(firstGap, secondGap)                             设置格子与格子之间的间隔
--SetData(dataList, firstSelectIndex, secondSelectIndex)  通过传入的数据创建二级列表并自动布局
--Select(firstIndex, secondIndex, needCallback)           选中二级列表的Item(只有在Mask范围内的Item才能被选中)
--Focus(firstIndex, secondIndex)                          跳转到指定位置
--GetSelectIndex()                                        获取选中的下标
--ItemSelectEvent                                         格子点击事件（包含一二级列表的点击事件）

--其它常用接口
--AddItemEvent  扩展监听格子的派发事件
--SetPadding    设置边界与格子的偏移值

TwoLevelList = TwoLevelList or BaseClass()

TwoLevelList.FIRST_LEVEL_OFFSET = 10000

local _table_insert = table.insert
local _table_remove = table.remove
local _math_floor = math.floor
local _pairs = pairs

--静态方法
function TwoLevelList.GenKey(firstIndex, secondIndex)
    if secondIndex then
        return firstIndex * TwoLevelList.FIRST_LEVEL_OFFSET + secondIndex
    end
    return firstIndex * TwoLevelList.FIRST_LEVEL_OFFSET
end

--初始化函数
--transform TwoLevelList对应的节点
--firstItemType   一级格子对应的类（需要继承TwoLevelListItem）
--secondItemType  二级格子对应的类（需要继承TwoLevelListItem）
function TwoLevelList:__init(transform, firstItemType, secondItemType)
    self.transform = transform
    self.firstItemType = firstItemType
    self.secondItemType = secondItemType
    self.firstGap = 0
    self.secondGap = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.itemDict = {}
    self:_InitComponent(transform)
    self:_InitTemplate()
    self:_InitFormatPrefab()
    self.ItemSelectEvent = EventLib.New()
end

function TwoLevelList:_InitComponent(transform)
    local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRectTrans = transform
    self.scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    local maskTrans = transform:Find(LayoutDefine.MASK_NAME)
    self.maskTrans = maskTrans
    local mask = maskTrans:GetComponent(Mask)
    self.maskWidth = mask.transform.sizeDelta.x
    self.maskHeight = mask.transform.sizeDelta.y
    self.contentTrans = maskTrans:Find(LayoutDefine.CONTENT_NAME)
    self.width = self.contentTrans.sizeDelta.x
    self.contentSize = Vector2(0, 0)
end

function TwoLevelList:_InitTemplate()
    local itemTrans = self.contentTrans:Find(LayoutDefine.FIRST_LEVEL_ITEM_NAME)
    self.firstTemplateTrans = itemTrans
    self.firstTemplate = itemTrans.gameObject
    self.firstItemHeight = itemTrans.sizeDelta.y
    local itemTrans = self.contentTrans:Find(LayoutDefine.SECOND_LEVEL_ITEM_NAME)
    self.secondTemplateTrans = itemTrans
    self.secondTemplate =  itemTrans.gameObject
    self.secondItemHeight = itemTrans.sizeDelta.y
end

--对预设的格式进行设置
function TwoLevelList:_InitFormatPrefab()
    self:_FormatPrefab(self.scrollRectTrans, false)
    self.scrollRectTrans.sizeDelta = Vector2(self.maskWidth, self.maskHeight)
    self:_FormatPrefab(self.maskTrans, false)
    self:_FormatPrefab(self.contentTrans, true)
    self.firstTemplate:SetActive(true)
    self.firstTemplateTrans.anchorMin = Vector2(0, 1)
    self.firstTemplateTrans.anchorMax = Vector2(0, 1)
    SetLocalScaleZero(self.firstTemplateTrans)
    self.secondTemplate:SetActive(true)
    self.secondTemplateTrans.anchorMin = Vector2(0, 1)
    self.secondTemplateTrans.anchorMax = Vector2(0, 1)
    SetLocalScaleZero(self.secondTemplateTrans)
end

function TwoLevelList:__delete()
    UtilsBase.TableDeleteMe(self, "itemDict")
    UtilsBase.TableDeleteMe(self, "firstLevelPoolList")
    UtilsBase.TableDeleteMe(self, "secondLevelPoolList")
    UtilsBase.FieldDeleteMe(self, "ItemSelectEvent")
    UtilsBase.TweenIdListDelete(self, "_tweenIdList")
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            UtilsBase.FieldDeleteMe(self, eventName)
        end
    end
end

function TwoLevelList:_GenOrderDataList(dataList, firstSelectIndex)
    local y = -self.paddingTop
    self.orderDataList = {}
    self.orderIndexToKey = {}
    for firstIndex = 1, #dataList do
        local data = dataList[firstIndex]
        local key = TwoLevelList.GenKey(firstIndex)
        local haveSecond = firstIndex == firstSelectIndex and data.dataList and #data.dataList > 0
        local height = self.firstItemHeight
        if haveSecond then
            height = height + self.secondGap
        else
            if firstIndex == #dataList then
            else
                height = height + self.firstGap
            end
        end
        _table_insert(self.orderDataList, TwoLevelListVo.New(data, y, height, firstIndex))
        self.orderIndexToKey[#self.orderDataList] = key
        y = y - height
        if haveSecond then
            for secondIndex = 1, #data.dataList do
                local key = TwoLevelList.GenKey(firstIndex, secondIndex)
                local height = self.secondItemHeight + self.secondGap
                _table_insert(self.orderDataList, TwoLevelListVo.New(data.dataList[secondIndex], y, height, firstIndex, secondIndex))
                self.orderIndexToKey[#self.orderDataList] = key
                y = y - height
            end
        end
    end
    self.height = -y + self.paddingBottom
end

--通过传入的数据创建二级列表并自动布局
--dataList          二级列表所有数据
--dataList = {
--     {key1 = value1, key2 = value2, ..., dataList = {key1 = value1, key2 = value2, ...}}
--     {key1 = value1, key2 = value2, ..., dataList = {key1 = value1, key2 = value2, ...}}
--     {key1 = value1, key2 = value2, ..., dataList = {key1 = value1, key2 = value2, ...}}
--     {key1 = value1, key2 = value2, ..., dataList = {key1 = value1, key2 = value2, ...}}
-- }
--firstSelectIndex  一级选中下标
--secondSelectIndex 二级选中下标
function TwoLevelList:SetData(dataList, firstSelectIndex, secondSelectIndex)
    self.dataList = dataList
    self.firstSelectIndex = firstSelectIndex
    self.secondSelectIndex = secondSelectIndex
    if dataList == nil or next(dataList) == nil then
        self:_PushAllToPool()
        self:_SetContentSize(0, 0)
        return
    end

    self:_PushAllToPool()
    self:_GenOrderDataList(dataList, firstSelectIndex)
    self:_SetContentSize(self.width, self.height)
    self:_Update(true)
end

--跳转到指定位置
--firstIndex      一级列表的位置
--secondIndex     二级列表的位置（可为nil）
function TwoLevelList:Focus(firstIndex, secondIndex)
    local key = TwoLevelList.GenKey(firstIndex, secondIndex)
    local y
    for i = 1, #self.orderDataList do
        local vo = self.orderDataList[i]
        if vo.key == key then
            y = vo.y
            break
        end
    end
    if y then
        self.scrollRect.verticalNormalizedPosition = self:_GetVerticalNormalizedPosition(-y)
    end
end

--选中二级列表的Item(只有在Mask范围内的Item才能被选中)
function TwoLevelList:Select(firstIndex, secondIndex, needCallback)
    local item = self:GetItem(firstIndex, secondIndex)
    if item == nil then
        return
    end
    if needCallback == nil then
        needCallback = true
    end
    self.firstSelectIndex = firstIndex
    self.secondSelectIndex = secondIndex
    self:_Select()
    if needCallback then
        self.ItemSelectEvent:Fire(self.firstIndex, self.secondIndex, item)
    end
end

function TwoLevelList:OnItemSelect(firstIndex, secondIndex, item)
    if secondIndex == nil then  --选中第一层
        local active
        if self.firstSelectIndex == firstIndex then
            self.firstSelectIndex = nil
            self.secondSelectIndex = nil
            active = false
        else
            self.firstSelectIndex = firstIndex
            if self:_HaveSecond(firstIndex) then
                self.secondSelectIndex = 1
            else
                self.secondSelectIndex = nil
            end
            active = true
        end

        local originY, positionDict = self:_GenPositionInfo(firstIndex, secondIndex)
        self:_Select()
        if self.firstSelectIndex then   --展开缓动
            self:_DoExpandTween(originY, positionDict)
        end
        -- if self.firstSelectIndex == #self.dataList then
        --     self:Focus(self.firstSelectIndex)
        -- end
    else
        self.firstSelectIndex = firstIndex
        self.secondSelectIndex = secondIndex
        self:_UpdateSelect()
    end

    self.ItemSelectEvent:Fire(firstIndex, secondIndex, item)
end

--设置格子与格子之间的间隔
function TwoLevelList:SetGap(firstGap, secondGap)
    self.firstGap = firstGap or 0
    self.secondGap = secondGap or 0
end

--设置边界间距
function TwoLevelList:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self.width = self.contentTrans.sizeDelta.x + self.paddingLeft + self.paddingRight
end

function TwoLevelList:GetFirstSelectIndex()
    return self.firstSelectIndex
end

function TwoLevelList:GetSecondSelectIndex()
    return self.secondSelectIndex
end

function TwoLevelList:GetSelectIndex()
    return self.firstSelectIndex, self.secondSelectIndex
end

function TwoLevelList:AddItemEvent(...)
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

function TwoLevelList:GetItem(firstIndex, secondIndex)
    return self.itemDict[TwoLevelList.GenKey(firstIndex, secondIndex)]
end

function TwoLevelList:_SetContentSize(width, height)
    self.contentSize:Set(width, height)
    self.contentTrans.sizeDelta = self.contentSize
end

function TwoLevelList:_OnValueChanged()
    if self:_GetOrderStartIndex() ~= self.orderStartIndex or
        self:_GetOrderEndIndex() ~= self.orderEndIndex then
        self:_Update()
    end
end

function TwoLevelList:_Update(force)
    self.orderStartIndex = self:_GetOrderStartIndex()
    self.orderEndIndex = self:_GetOrderEndIndex()
    self:_PushUnUsedItem()
    for orderIndex = self.orderStartIndex, self.orderEndIndex do
        local data = self.orderDataList[orderIndex]
        local item, getWay = self:_GetItem(data)
        item:SetActive(true)
        item:SetPosition(Vector2(self.paddingLeft, data.y))
        if force or getWay ~= LayoutDefine.GetItemWay.exist then
            local selectIndex
            if item:IsFirstLevel() then
                selectIndex = self.firstSelectIndex
            else
                selectIndex = self.secondSelectIndex
            end
            item:SetData(data.data, selectIndex)
            self.itemDict[data.key] = item
        end
    end
end

function TwoLevelList:_Select()
    self:_GenOrderDataList(self.dataList, self.firstSelectIndex)
    self:_SetContentSize(self.width, self.height)
    if self.scrollRect.verticalNormalizedPosition <= 0 then
        self.scrollRect.verticalNormalizedPosition = 0
    end
    self:_Update(true)
    -- if self.firstIndex == #self.dataList then
    --     self:Focus(self.firstIndex)
    -- end
end

function TwoLevelList:_UpdateSelect()
    for _, item in _pairs(self.itemDict) do
        local selectIndex
        if item:IsFirstLevel() then
            selectIndex = self.firstSelectIndex
        else
            selectIndex = self.secondSelectIndex
        end
        item:SetCommonData(selectIndex)
    end
end

function TwoLevelList:_GetItem(data)
    local key = data.key
    local firstIndex = data.firstIndex
    local secondIndex = data.secondIndex
    if self.itemDict and self.itemDict[key] then
        local item = self.itemDict[key]
        return item, LayoutDefine.GetItemWay.exist
    else
        local poolList
        if data.level == 1 then
            poolList = self.firstLevelPoolList
        else
            poolList = self.secondLevelPoolList
        end
        if poolList and #poolList > 0 then
            local item = _table_remove(poolList)
            item:InitFromCache(key, firstIndex, secondIndex)
            return item, LayoutDefine.GetItemWay.cache
        end
    end
    local template, itemType
    if data.level == 1 then
        template = self.firstTemplate
        itemType = self.firstItemType
    else
        template = self.secondTemplate
        itemType = self.secondItemType
    end
    local go = GameObject.Instantiate(template)
    go.transform:SetParent(self.contentTrans, false)
    local item = itemType.New(go)
    item:SetIndex(key, firstIndex, secondIndex)
    item:SetStaticData(self.staticData)
    item.ItemSelectEvent:AddListener(function(firstIndex, secondIndex, item) self:OnItemSelect(firstIndex, secondIndex, item) end)
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            item[eventName]:AddListener(function(...) self[eventName]:Fire(...) end)
        end
    end
    return item, LayoutDefine.GetItemWay.new
end

function TwoLevelList:_GetOrderStartIndex()
    return self:_GetIndexByY(self:_GetMaskTop())
end

function TwoLevelList:_GetOrderEndIndex()
    return self:_GetIndexByY(self:_GetMaskBottom())
end

function TwoLevelList:_GetIndexByY(y)
    local startIndex = 1
    local endIndex = #self.orderDataList
    if endIndex <= startIndex then
        return startIndex
    end
    local result
    while true do
        local mid = _math_floor((startIndex + endIndex) / 2)
        local data = self.orderDataList[mid]
        if (data.y - data.height) <= y and y < data.y then
            result = mid
            break
        end
        if y >= data.y then
            endIndex = mid - 1
        else
            startIndex = mid + 1
        end
        if endIndex - startIndex <= 0 then
            result = startIndex
            break
        end
    end
    return result
end

function TwoLevelList:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function TwoLevelList:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function TwoLevelList:_HaveSecond(firstIndex)
    if self.dataList and self.dataList[firstIndex] then
        local data = self.dataList[firstIndex]
        return data.dataList and next(data.dataList)
    end
end

function TwoLevelList:_GetVerticalNormalizedPosition(y)
    local result = 0
    if self.height > self.maskHeight then
        result = y / (self.height - self.maskHeight)
        if result > 1 then
            result = 1
        end
    end
    return 1 - result
end

function TwoLevelList:_PushAllToPool()
    for key, item in _pairs(self.itemDict) do
        self:_PushPool(item)
        self.itemDict[key] = nil
    end
end

function TwoLevelList:_PushUnUsedItem()
    local keyDict = {}
    for index = self.orderStartIndex, self.orderEndIndex do
        local key = self.orderIndexToKey[index]
        keyDict[key] = true
    end
    for key, item in _pairs(self.itemDict) do
        if not keyDict[key] then
            self:_PushPool(item)
            self.itemDict[key] = nil
        end
    end
end

function TwoLevelList:_PushPool(item)
    item:SetActive(false)
    if item:IsFirstLevel() then
        if self.firstLevelPoolList == nil then
            self.firstLevelPoolList = {}
        end
        _table_insert(self.firstLevelPoolList, item)
    else
        if self.secondLevelPoolList == nil then
            self.secondLevelPoolList = {}
        end
        _table_insert(self.secondLevelPoolList, item)
    end
end

function TwoLevelList:_GenPositionInfo(firstIndex, secondIndex)
    local selectKey = TwoLevelList.GenKey(firstIndex, secondIndex)
    local positionDict = {}
    local originY = 0
    for key, item in _pairs(self.itemDict) do
        local y = item:GetPosition().y
        if key == selectKey then
            originY = y
        end
        positionDict[key] = y
    end
    return originY, positionDict
end

function TwoLevelList:_DoExpandTween(originY, positionDict)
    UtilsBase.TweenIdListDelete(self, "_tweenIdList")
    for key, item in _pairs(self.itemDict) do
        if item:IsFirstLevel() then
            local y = item.transform.localPosition.y
            if positionDict[key] then
                UtilsUI.SetY(item.transform, positionDict[key])
            else
                UtilsUI.SetY(item.transform, self:_GetMaskBottom())
            end
            local tweenId = Tween.Instance:MoveLocalY(item.gameObject, y, 0.1, nil, LeanTweenType.linear).id
            self:_InsertTweenId(tweenId)
        else
            local y = item.transform.localPosition.y
            UtilsUI.SetY(item.transform, originY)
            local tweenId = Tween.Instance:MoveLocalY(item.gameObject, y, 0.1, nil, LeanTweenType.linear).id
            self:_InsertTweenId(tweenId)
            tweenId = UtilsTween.CanvasFadeIn(item.gameObject, 0.1, LeanTweenType.linear, 0)
            self:_InsertTweenId(tweenId)
        end
    end
end

function TwoLevelList:_InsertTweenId(tweenId)
    if self._tweenIdList == nil then
        self._tweenIdList = {}
    end
    _table_insert(self._tweenIdList, tweenId)
end

function TwoLevelList:_FormatPrefab(rect, setPosition)
    rect.pivot = Vector2(0, 1)
    rect.anchorMin = Vector2(0, 1)
    rect.anchorMax = Vector2(0, 1)
    if setPosition then
        rect.anchoredPosition3D = Vector3.zero
    end
end