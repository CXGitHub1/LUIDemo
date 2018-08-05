--chen quan
LTree = LTree or BaseClass()

LTree.ITEM_NAME = "Item"
LTree.MASK_NAME = "Mask"
LTree.CONTENT_NAME = "Content"

function LTree:__init(transform, itemType, itemTypeDict)
    self.defaultItemType = itemType
    self.itemDict = {}
    -- self.rootNode = LTreeNode.New()

    self:_InitComponent(transform)
    -- self.nodeDataList 
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

function LTree:SetGapDict()
end

function LTree:SetOffsetDict()
end

function LTree:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    self:TreeToList(dataList)
    local key = string.Empty
    local x = 0
    local y = 0
    local depth = 1
    self:Treasure(dataList, key, depth, x, y)
end

function LTree:_OnValueChanged(value)
end

function LTree:Treasure(dataList, key, depth, x, y)
end

function LTree:Treasure(dataList, key, depth, x, y)
    for i = 1, #dataList do
        local data = dataList[i]
        local key = string.format("%s_%s", key, i)
        local node = self:_GetNode(key, depth)
        pError(data.name)
        node:SetData(data.name)
        node:SetActive(true)
        node:SetPosition(Vector2(x, y))
        y = y - node:GetSize().y
        if data.dataList then
            x, y = self:Treasure(data.dataList, key, depth, x, y)
        end
    end
    return x, y
end

function LTree:_GetNode(key, depth)
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local node = LTreeNode.New(go)
    node:SetActive(true)
    node.ItemSelectEvent:AddListener(function(index, node)
        self.ItemSelectEvent:Fire(index, node)
    end)
    node:SetKey(key, depth)
    return node
end
