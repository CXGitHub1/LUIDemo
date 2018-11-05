LEmojiTextTest = LEmojiTextTest or BaseClass()

function LEmojiTextTest:__init(gameObject)
    local transform = gameObject.transform
    self.transform = transform
    self:Test()
end

function LEmojiTextTest:Test()
    local transform = self.transform
    local scrollView = LSIScrollView.New(transform:Find("Test"), LEmojiTextItem, UtilsBase.INT32_MAX, 1)
    local dataList = {}
    for i = 1, 100 do
        -- table.insert(dataList, self:GetIconStr())
        -- table.insert(dataList, "占位符")
        table.insert(dataList, self:GetIconStr() .. self:GetFaceStr() .. self:GetButtonStr() .. self:GetHyperlinkStr())
    end
    scrollView:SetData(dataList)
    self.scrollView1 = scrollView
end

function LEmojiTextTest:Test1()
    local transform = self.transform
    local scrollView = LSIScrollView.New(transform:Find("Test1"), LEmojiTextItem, UtilsBase.INT32_MAX, 1)
    local dataList = {}
    for i = 1, 100 do
        -- table.insert(dataList, self:GetIconStr())
        -- table.insert(dataList, "占位符")
        table.insert(dataList, self:GetIconStr() .. self:GetFaceStr() .. self:GetButtonStr() .. self:GetHyperlinkStr())
    end
    scrollView:SetData(dataList)
    self.scrollView2 = scrollView
end

function LEmojiTextTest:GetIconStr()
    if math.random(1, 2) % 2 == 0 then
        local iconId = math.random(90000, 90007)
        return string.format("图标：<t=1,%s>", iconId)
    end
    return ""
end

function LEmojiTextTest:GetFaceStr()
    if math.random(1, 2) % 2 == 0 then
        local faceId = math.random(1, 10)
        return string.format("表情：<t=2,%s>", faceId)
    end
    return ""
end

function LEmojiTextTest:GetButtonStr()
    if math.random(1, 2) % 2 == 0 then
        local buttonId = math.random(1, 7)
        return string.format("按钮：<t=3,%s>", buttonId)
    end
    return ""
end

function LEmojiTextTest:GetHyperlinkStr()
    local colorMax = 256 * 256 * 256
    if math.random(1, 2) % 2 == 0 then
        local color = string.format("%02X", math.random(0, colorMax))
        return string.format("<t=4,超链接,%s>", color)
    end
    return ""
end

