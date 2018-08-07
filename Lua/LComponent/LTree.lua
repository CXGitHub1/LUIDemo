LTree = LTree or BaseClass()

LTree.ITEM_NAME = "Item"
LTree.MASK_NAME = "Mask"
LTree.CONTENT_NAME = "Content"

function LTree:__init(transform, itemType)
    self.defaultItemType = itemType
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.ItemSelectEvent = EventLib.New()

    --缓存
    self.nodeDict = {}
    self.nodePoolList = {}
    self.nodeDataDict = {}
    self.orderList = nil
    self.rootData = LTreeNodeData.New(nil, 0)

    self:_InitComponent(transform)
end

function LTree:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
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

-- public function
function LTree.InitTree(dataList, dataType, nodeData, depth, key)
    dataType = dataType or LTreeNodeData
    nodeData = nodeData or dataType.New()
    depth = depth or 1
    key = key or string.Empty
    for i = 1, #dataList do
        local data = dataList[i]
        local childKey = key .. "_" .. i
        local childNodeData = dataType.New(data, depth, childKey)
        childNodeData:SetParent(parent)
        parent:AddChild(childNodeData)
        self.nodeDataDict[childKey] = childNodeData
        if data.dataList then
            LTree.InitTree(data.dataList, dataType, childNodeData, depth + 1, childKey)
        end
    end
    return nodeData
end


function LTree:SetData(rootNodeData, commonData)
    self.rootNodeData = rootNodeData
    self.commonData = commonData
    self.orderList = {}
    self:TreeToList(rootNodeData)

    local startIndex = 1
    if self.startKey == nil then
        local nodeData = self.orderList[1]
        self.startKey = nodeData
        startIndex = 1
    else
        --如果startKey不存在呢？
        --TODO
        local nodeData = self.nodeDataDict[self.startKey]
        startIndex = nodeData.order
    end
    self.startIndex = startIndex
    self:Refresh()
end

function LTree:Refresh()
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
    local key = nodeData:GetKey()
    if self.nodeDict[key] then
        local node = self.nodeDict[key]
        return node
    elseif self.nodePoolList and #self.nodePoolList > 0 then
        local node = table.remove(self.nodePoolList)
        node:InitFromCache(key)
        self.nodeDict[key] = node
        return node
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local node = LTreeNode.New(go, nodeData)
    node:SetActive(true)
    node.ItemSelectEvent:AddListener(function(key, node)
        self.ItemSelectEvent:Fire(key, node)
    end)
    self.nodeDict[key] = node
    return node
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
    node:SetData(nodeData.data, self.commonData)
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
    return self.endIndex < #self.orderList and self:_ContentEndInMask()
end

function LTree:_AddAtEnd()
    local endNode = self:_IndexToNode(self.endIndex)
    local endPosition = endNode:GetPosition()
    local size = endNode:GetSize()

    local addIndex = self.endIndex + 1
    local nodeData = self.orderList[addIndex]
    local addNode = self:_GetNode(nodeData)
    addNode:SetActive(true)
    addNode:SetData(nodeData.data, self.commonData)
    addNode:SetPosition(Vector2(endPosition.x, endPosition.y - (size.y + self.gapVertical)))

    self.endIndex = addIndex
    self:_CalcSize()
end

function LTree:_RemoveStartOutMask()
    local startIndex = self.startIndex
    local node = self:_IndexToNode(startIndex)
    if self:_IsOutOfMask(node) then
        self:_PushPool(node)

        local offset = Vector2(0, node:GetSize().y + self.gapVertical)
        self.startIndex = startIndex + 1
        for index = self.startIndex, self.endIndex do
            local node = self:_IndexToNode(index)
            node:Translate(offset)
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
    local startNode = self:_IndexToNode(self.startIndex)
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
    return self.nodeDict[nodeData:GetKey()]
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