-- chen quan
-- 二级列表
NExpandableListViewSettting = NExpandableListViewSettting or BaseClass()

function NExpandableListViewSettting:__init(itemType, gapVertical, paddingLeft, paddingRight, paddingTop, paddingBottom, listViewSetting)
    self.itemType = itemType
    self.gapVertical = gapVertical
    self.paddingLeft = paddingLeft
    self.paddingRight = paddingRight
    self.paddingTop = paddingTop
    self.paddingBottom = paddingBottom
    self.listViewSetting = listViewSetting
    self.eventNameList = {}
end

function NExpandableListViewSettting:AddEventName(eventName)
    table.insert(self.eventNameList, eventName)
end

NExpandableListView = NExpandableListView or BaseClass()

NExpandableListView.ITEM_NAME = "Item"

NExpandableListView.STATUS = {
    collapse = 1,
    expand = 2,
}

function NExpandableListView:__init(transform, setting)
    self.gameObject = transform.gameObject
    self.transform = transform
    self.setting = setting

    self.template = transform:Find(NExpandableListView.ITEM_NAME).gameObject
    self.template:SetActive(false)
    self:InitEvent()

    self.cacheList = {}
    self.itemList = {}
    self.groupIndex = 1
    self.itemIndex = 1
end

function NExpandableListView:InitEvent()
    local setting = self.setting
    for i = 1, #setting.eventNameList do
        local eventName = setting.eventNameList[i]
        self[eventName] = EventLib.New()
    end

    self.ItemSelectEvent = EventLib.New()
    self.OnExpandableClickEvent = EventLib.New()
end

function NExpandableListView:__delete()
    for i = 1, #self.setting.eventNameList do
        local eventName = self.setting.eventNameList[i]
        UtilsBase.FieldDeleteMe(self, eventName)
    end
    UtilsBase.TableDeleteMe(self, "cacheList")
end

function NExpandableListView:SetData(dataList)
    self.dataList = dataList
    self.itemList = {}
    for index, data in ipairs(dataList) do
        local item = self:getItem(index)
        item:Show()
        item:SetData(data)
        item:RefreshSelect()
        table.insert(self.itemList, item)
    end
    self:hideCacheList()
    self:Layout()
end

function NExpandableListView:Refresh()
    for index, item in ipairs(self.itemList) do
        item:RefreshSelect()
    end
    self:Layout()
end

function NExpandableListView:Select(groupIndex, itemIndex, sendCallback)
    self.groupIndex = groupIndex
    self.itemIndex = itemIndex
    local groupItem = self.itemList[groupIndex]
    for index, v in ipairs(self.itemList) do
        if index ~= groupIndex then
            v:SetStatus(NExpandableListView.STATUS.collapse)
        else
            v:SetStatus(NExpandableListView.STATUS.expand)
        end
    end
    self:Refresh()
    if sendCallback then
        self.OnExpandableClickEvent:Fire(groupIndex)
        self.ItemSelectEvent:Fire(groupIndex, itemIndex, self:GetItem(groupIndex, itemIndex))
    end
end

function NExpandableListView:Layout()
    local width = 0
    local height = 0
    local setting = self.setting
    local y = setting.paddingTop
    for index, item in ipairs(self.itemList) do
        local x = setting.paddingLeft
        item:SetPosition(x, -y)
        local size = item:GetSize()
        y = y + size.y + setting.gapVertical
        local borderX = x + size.x + setting.paddingRight
        local borderY = y + setting.paddingBottom
        if borderX > width then width = borderX end
        if borderY > height then height = borderY end
    end
    self.transform.sizeDelta = Vector2(width, height)
end

function NExpandableListView:GetSize()
    return self.transform.sizeDelta
end

function NExpandableListView:SetY(y)
    UtilsUI.SetAnchoredY(self.transform, y)
end

function NExpandableListView:OnHide()
    for i = 1, #self.itemList do
        self.itemList[i]:OnHide()
    end
end

function NExpandableListView:OnItemClick(groupIndex, itemIndex, item)
    self.itemIndex = itemIndex
    self:Refresh()
    self.ItemSelectEvent:Fire(groupIndex, itemIndex, item)
end

function NExpandableListView:OnExpandableClick(item)
    local status = item:GetStatus()
    local expandableItemIndex = item.index
    for i = expandableItemIndex, #self.itemList do
        self.itemList[i]:SavePosition()
    end
    for _, v in ipairs(self.itemList) do
        v:SetStatus(NExpandableListView.STATUS.collapse)
    end
    if status == NExpandableListView.STATUS.collapse then
        item:SetStatus(NExpandableListView.STATUS.expand)
    else
        item:SetStatus(NExpandableListView.STATUS.collapse)
    end
    self.itemIndex = 1
    self:Refresh()
    self.OnExpandableClickEvent:Fire(item.index)
    if status == NExpandableListView.STATUS.collapse then
        for i = expandableItemIndex, #self.itemList do
            self.itemList[i]:PlayExpandableTween()
        end
    end
end

function NExpandableListView:GetCurrentItem()
    local groupItem = self:getItem(self.groupIndex)
    return groupItem:GetItem(self.itemIndex)
end

function NExpandableListView:BottomToTopTween()
    local itemList = self.itemList
    local delayTime = 0
    for i = 1, #itemList do
        local item = itemList[i]
        delayTime = item:BottomToTopTween(delayTime)
    end
end

function NExpandableListView:RefreshSelect(groupIndex, itemIndex)
    local itemList = self.itemList
    for i = 1, #itemList do
        local item = itemList[i]
        item:RefreshSelect(groupIndex, itemIndex)
    end
end

function NExpandableListView:GetItem(groupIndex, itemIndex)
    local groupItem = self.itemList[groupIndex]
    if groupItem ~= nil then
        return groupItem:GetItem(itemIndex)
    end
    return nil
end

-- tool function
function NExpandableListView:hideCacheList()
    for i = #self.itemList + 1, #self.cacheList do
        self.cacheList[i]:Hiden()
    end
end

function NExpandableListView:getItem(index)
    local setting = self.setting
    local itemType = setting.itemType
    local item = self.cacheList[index]
    if item == nil then
        local go = GameObject.Instantiate(self.template)
        go.name = NExpandableListView.ITEM_NAME .. tostring(index)
        go.transform:SetParent(self.transform, false)
        item = itemType.New(go, index, setting.listViewSetting, self)
        if index == 1 then
            item:SetStatus(NExpandableListView.STATUS.expand)
        else
            item:SetStatus(NExpandableListView.STATUS.collapse)
        end
        item.ItemSelectEvent:AddListener(function(groupIndex, itemIndex, item) self:OnItemClick(groupIndex, itemIndex, item)  end)
        item.OnClickEvent:AddListener(function(item) self:OnExpandableClick(item) end)
        for i = 1, #setting.eventNameList do
            local eventName = setting.eventNameList[i]
            item[eventName]:AddListener(function(...) self[eventName]:Fire(...) end)
        end
        self.cacheList[index] = item
    end
    return item
end

--跳转 groupIndex, itemIndex时调整位置
--deltaY 为二级标签的高度 height*(1-pivot.y) 
function NExpandableListView:SetPositionYByIndex( groupIndex, itemIndex, deltaY )
    self:Layout()--先校正位置再计算
    local y = 0
    local groupItem = self.itemList[groupIndex]
    if groupItem ~= nil then
        local outx,outy,outz = groupItem:GetAPosition()        
        y = y - outy
        if itemIndex then
            local contx,conty,contz = groupItem:GetContentAPosition()
            local posx,posy,posz = groupItem:GetItemAPositionByIndex(itemIndex)
            y = y - conty
            y = y - posy
        else
            return
        end
    end
    self:SetY(y+deltaY)
end
