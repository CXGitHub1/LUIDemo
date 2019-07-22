--chen quan
TwoLevelListItem = TwoLevelListItem or BaseClass(FSItem)

local _math_floor = math.floor

function TwoLevelListItem:__init()
end

function TwoLevelListItem:__delete()
end

function TwoLevelListItem:SetIndex(key, firstIndex, secondIndex)
    self.key = key
    self.firstIndex = firstIndex
    self.secondIndex = secondIndex
    if self:IsFirstLevel() then
        self.index = self.firstIndex
    else
        self.index = self.secondIndex
    end
    if IS_DEBUG then
        self.gameObject.name = "Item" .. key
    end
end

function TwoLevelListItem:IsFirstLevel()
    return self.secondIndex == nil
end

function TwoLevelListItem:GetLevel()
    return self:IsFirstLevel() and 1 or 2
end

function TwoLevelListItem:InitFromCache(key, firstIndex, secondIndex)
    self:SetIndex(key, firstIndex, secondIndex)
end

function TwoLevelListItem:SetData(data, selectIndex, commonData)
end

function TwoLevelListItem:SetCommonData(selectIndex, commonData)
    LogError("在SetData中调用SetCommonData\n在SetCommonData中实现选中效果")
end

function TwoLevelListItem:OnClick()
    self.ItemSelectEvent:Fire(self.firstIndex, self.secondIndex, self)
end
