LItem = LItem or BaseClass()

function LItem:__init(gameObject)
    self.gameObject = gameObject
    local transform = gameObject.transform
    self.transform = transform
    self.pivot = transform.pivot
    self.sizeDelta = transform.sizeDelta

    self.ItemSelectEvent = EventLib.New()
    local button = transform:GetComponent(Button)
    if button then
        button.onClick:AddListener(function() self:OnClick() end)
    end
end

function LItem:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
end

function LItem:InitFromCache(index)
    self:SetIndex(index)
end

--出于性能的考虑 SetActive调用的是transform的localScale接口
--如果Item带有特效，而且特效无法用缩放隐藏，就重写SetActive接口
--改为调用gameObject:SetAcitve(value)
function LItem:SetActive(active)
    if active then
        self.transform.localScale = Vector3One
    else
        self.transform.localScale = Vector3Zero
    end
end

function LItem:SetExtendTrans(extraTrans)
    self.extraTrans = extraTrans
end

function LItem:CloneExtendPart(name)
    local srcTrans = self.extraTrans:Find(name)
    local anchoredPosition3D = srcTrans.anchoredPosition3D
    local tarTrans = GameObject.Instantiate(srcTrans.gameObject).transform
    UtilsUI.SetParent(tarTrans, self.transform)
    return tarTrans
end

--MultiVericalScrollView 所使用的类型
function LItem:SetItemType(type)
    self._itemType = type
end

function LItem:GetItemType(type)
    return self._itemType
end

function LItem:SetIndex(index)
    self.index = index
    if DEBUG then
        self.gameObject.name = "Item" .. index
    end
end

function LItem:GetIndex()
    return self.index
end

function LItem:GetSize()
    return self.transform.sizeDelta
end

function LItem:GetPosition()
    return self.transform.anchoredPosition3D - Vector3(self.pivot.x * self.sizeDelta.x, (self.pivot.y - 1) * self.sizeDelta.y, 0)
end

function LItem:SetPosition(position)
    self.transform.anchoredPosition3D = Vector3(position.x + self.pivot.x * self.sizeDelta.x, position.y + (self.pivot.y - 1) * self.sizeDelta.y, 0)
end

function LItem:SetData(data, commonData)
    pError("需要重写SetData方法")
end

function LItem:SetCommonData(commonData)
    pError("需要重写SetCommonData方法")
end

function LItem:OnClick()
    self.ItemSelectEvent:Fire(self.index, self)
end
