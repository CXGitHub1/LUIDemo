--chen quan
LTree = LTree or BaseClass()

LTree.ITEM_NAME = "Item"
LTree.MASK_NAME = "Mask"
LTree.CONTENT_NAME = "Content"

function LTree:__init(transform, itemType)
    self.defaultItemType = itemType

    --缓存
    self.nodeDict = {}
    self.nodePoolList = {}
    self.nodeDataDict = {}
    self.orderList = nil
    self.rootData = LTreeNodeData.New(nil, 0)

    self:_InitComponent(transform)
end

function LTree:_InitComponent(transform)
     local scrollRect = transform:GetComponent(LScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    local maskTrans = transform:Find(LTree.MASK_NAME)
    local mask = maskTrans:GetComponent(Mask)
    self.mask = mask
    self.maskWidth = mask.transform.sizeDelta.x
    self.maskHeight = mask.transform.sizeDelta.y
    self.contentTrans = maskTrans:Find(LTree.CONTENT_NAME)
    local template = self.contentTrans:Find(LTree.ITEM_NAME).gameObject
    self.template = template
end

function LTree:InitTree(dataList, parent, depth, key)
    for i = 1, #dataList do
        local data = dataList[i]
        local childKey = key .. depth
        local nodeData = LTreeNodeData.New(data, depth, childKey)
        nodeData:SetParent(parent)
        parent:AddChild(nodeData)
        self.nodeDataDict[childKey] = nodeData
        if data.dataList then
            self:InitTree(data.dataList, nodeData, depth + 1, childKey)
        end
    end
end

function LTree:TreeToList(nodeData)
    if nodeData:HaveChild() then
        local childList = nodeData:GetChildList()
        for i = 1, #childList do
            local childNodeData = childList[i]
            table.insert(self.orderList, childNodeData)
            childNodeData:SetOrder(#self.orderList)
            if childNodeData.expand then
                self:TreeToList(childNodeData)
            end
        end
    end
end

function LTree:_GetNode(nodeData)
    if self.nodeDict[nodeData:GetKey()] then
        local node = self.nodeDict[nodeData.key]
        return node
    elseif self.nodePoolList and #self.nodePoolList > 0 then
        local node = table.remove(self.nodePoolList)
        node:InitFromCache(nodeData)
        self.nodeDict[nodeDict.key] = node
        return node
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local node = LTreeNode.New(go, nodeData)
    node:SetActive(true)
    node.ItemSelectEvent:AddListener(function(index, node)
        self.ItemSelectEvent:Fire(index, node)
    end)
    self.nodeDict[nodeData.key] = nodeData
    return node
end

function LTree:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    local key = string.Empty
    self:InitTree(dataList, self.rootData, 0, key)
    self.orderList = {}
    self:TreeToList(self.rootData)

    local startIndex = 1
    if self.startKey == nil then
        local nodeData = self.orderList[1]
        self.startKey = nodeData
        startIndex = 1
    else
        local nodeData = self.nodeDataDict[self.startKey]
        startIndex = nodeData.order
        --如果startKey不存在呢？
        --TODO
    end
    self.startIndex = startIndex

    local x = 0
    local y = 0
    self.endIndex = #self.orderList
    for i = self.startIndex, #self.orderList do
        local nodeData = self.orderList[i]
        local node = self:_GetNode(nodeData)
        node:SetData(nodeData.data)
        node:SetActive(true)
        node:SetPosition(Vector2(x, y))
        y = y - node:GetSize().y
        if self:_BelowMaskBottom(y) then
            self.endIndex = i
            break
        end
    end

    self:_CalcSize()
end


function LTree:_OnValueChanged(value)
    if not self:_ContentContainMask() then
        while(self:_CanAddAtStart()) do
            self:_RemoveEndOutMask()
            self:_AddAtStart()
        end
        while(self:_CanAddAtEnd()) do
            self:_RemoveStartOutMask()
            self:_AddAtEnd()
        end
    end
end

function LTree:_CanAddAtStart()
    return self.startIndex > 1 and self:_ContentStartInMask()
end

function LTree:_AddAtStart()
    local addIndex = self.startIndex - 1

    local nodeData = self.orderList[addIndex]
    local node = self:_GetNode(nodeData)
    node:SetActive(true)
    node:SetData(nodeDict, self.commonData)
    node:SetPosition(Vector2(0, 0))

    local size = node:GetSize()
    local offset = Vector2(0, -(size.y + self.gapVertical))
    for index = self.startIndex, self.endIndex do
        local node = self:_IndexToNode(index)
        node:Translate(offset)
    end
    self.scrollRect:ContentTranslate(-offset)

    self.startIndex = addIndex
    self:_CalcSize()
end

function LTree:_CanAddAtEnd()
    return self.endIndex < #self.dataList and self:_ContentEndInMask()
end

function LTree:_AddAtEnd()
    local addIndex = self.endIndex + 1
    local nodeData = self.orderList[addIndex]
    local endNode = self:_GetNode(nodeData)
    local endPosition = endNode:GetPosition()
    local size = endNode:GetSize()

    local x = endPosition.x
    local y = endPosition.y - (size.y + self.gapVertical)

    item:SetActive(true)
    item:SetData(self.dataList[index], self.commonData)
    item:SetPosition(Vector2(x, y))

    for index = addIndex, addEndIndex do
        local item = self:_GetItem(index)
    end
    self.endIndex = addEndIndex
    self:_CalcSize()
end

function LTree:_RemoveStartOutMask()
    local startIndex = self.startIndex
    local node = self:_IndexToNode(startIndex)
    if self:_IsOutOfMask(node) then
        self:_PushPool(node)

        local size = node:GetSize()
        local offset = Vector2(0, size.y + self.gapVertical)

        self.startIndex = startIndex + 1
        for index = self.startIndex, self.endIndex do
            local item = self.itemDict[index]
            item:Translate(offset)
        end
        self.scrollRect:ContentTranslate(-offset)
        self:_CalcSize()
        return true
    end
    return false
end

function LTree:_RemoveEndOutMask()
    local endIndex = self.endIndex
    local node = self:_IndexToNode(endIndex)
    if self:_IsOutOfMask(node) then
        self:_PushPool(node)
        self.endIndex = endIndex - 1
        self:_CalcSize()
        return true
    end
    return false
end

function LTree:_CalcSize()
    local right = UtilsBase.INT32_MIN
    local bottom = UtilsBase.INT32_MAX
    local startNode = self:_IndexToNode(selt.startIndex)
    local position = startNode:GetPosition()
    local left = position.x
    local top = position.y

    for index = self.startIndex, self.endIndex do
        local node = self:_IndexToNode(index)
        local position = node:GetPosition()
        local size = node:GetSize()
        if (position.x + size.x) > right then
            right = position.x + size.x
        end
        if index == self.endIndex then
            if (position.y - size.y) < bottom then
                bottom = position.y - size.y
            end
        end
    end

    self.contentTrans.sizeDelta = Vector2(right - left, top - bottom)
end

function LTree:_IndexToNode(index)
    local nodeData = self.orderList[index]
    return self.itemDict[nodeData.key]
end

function LTree:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LTree:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function LTree:_AboveMaskBottom(y)
    return y >= self:_GetMaskBottom()
end

function LTree:_BelowMaskTop(y)
    return y <= self:_GetMaskTop()
end

function LTree:_BelowMaskBottom(y)
    return y < self:_GetMaskBottom()
end

function LTree:_ContentContainMask()
    local top, bottom = self:_GetContentBound()
    return self:_AboveMaskTop(top) and self:_BelowMaskBottom(bottom)
end

function LTree:_ContentStartInMask()
    local top, bottom = self:_GetContentBound()
    return self:_BelowMaskTop(top)
end

function LTree:_ContentEndInMask()
    local top, bottom = self:_GetContentBound()
    return self:_AboveMaskBottom(bottom)
end

function LTree:_GetContentBound()
    return 0, -self.contentTrans.sizeDelta.y
end

function LTree:_AboveMaskTop(y)
    return y > self:_GetMaskTop()
end

function LTree:_GetRow(index)
    return math.floor((index - 1) / self.column) + 1
end

function LTree:_GetColumn(index)
    return 1
end

function LTree:_PushPool(node)
    local nodeData = node.nodeData
    self.nodeDict[nodeData:GetKey()] = nil
    node:SetActive(false)
    table.insert(self.nodePoolList, node)
end

function LTree:_IsOutOfMask(node)
    local position = node:GetPosition()
    local top = position.y + self.gapVertical
    local bottom = position.y - node:GetSize().y - self.gapVertical
    if self:_BelowMaskBottom(top) or self:_AboveMaskTop(bottom) then
        return true
    end
    return false
end