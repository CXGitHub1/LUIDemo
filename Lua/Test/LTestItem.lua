LTestItem = LTestItem or BaseClass(LItem)

function LTestItem:__init()
    local transform = self.transform
    self.transform = transform
    self.text = transform:Find("Text"):GetComponent(Text)
    if transform:Find("Select") then
        self.selectGo = transform:Find("Select").gameObject
    end
end

function LTestItem:__release()
    GameObject.Destroy(self.transform.gameObject)
end

function LTestItem:SetData(data, commonData)
    self.text.text = self.index
    local sizeType = commonData.sizeType
    if sizeType == TestDefine.SizeType.fix then
    elseif sizeType == TestDefine.SizeType.increase then
        local offset = math.floor((self.index - 1) / 2) * 2
        self.transform.sizeDelta = Vector2(50 + offset, 50 + offset)
    elseif sizeType == TestDefine.SizeType.decrease then
        local offset = math.floor((self.index - 1) / 2) * 2
        self.transform.sizeDelta = Vector2(50 - offset, 50 - offset)
    elseif sizeType == TestDefine.SizeType.specified then
        if self.index % 2 == 1 then
            self.transform.sizeDelta = Vector2(40, 50)
        else
            self.transform.sizeDelta = Vector2(40, 20)
        end
    elseif sizeType == TestDefine.SizeType.specified1 then
        local offset = 0
        if math.floor((self.index - 1) / 2) % 2 == 1 then
            offset = 20
        else
            offset = 30
        end
        self.transform.sizeDelta = Vector2(50, 50 - offset)
    elseif sizeType == TestDefine.SizeType.specified2 then
        if self.index % 2 == 1 then
            self.transform.sizeDelta = Vector2(20, 30)
        else
            self.transform.sizeDelta = Vector2(40, 30)
        end
    elseif sizeType == TestDefine.SizeType.specified3 then
        local column = math.floor((self.index - 1) / 3)
        if self.index % 3 == 1 then
            self.transform.sizeDelta = Vector2(20, 50)
        else
            self.transform.sizeDelta = Vector2(40, 20)
        end
    end
    self:SetSelectActive(commonData.selectIndex == self.index)
end

function LTestItem:SetSelectActive(active)
    if self.selectGo then
        self.selectGo:SetActive(active)
    end
end

function LTestItem:SetCommonData(commonData)
    self:SetSelectActive(commonData.selectIndex == self.index)
end
