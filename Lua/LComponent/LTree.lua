--chen quan
LTree = LTree or BaseClass()

function LTree:__init(transform, itemType, itemTypeDict)
    self.defaultItemType = itemType
end

function LTree:SetGapDict()
end

function LTree:SetOffsetDict()
end

function LTree:SetData(dataList)
    self.dataList = dataList
    self:Treasure(dataList)
end

function LTree:Treasure(dataList)
    for i = 1, #dataList do
        local data = dataList[i]
        pError(data.name)
        if data.dataList then
            self:Treasure(data.dataList)
        end
    end
end
