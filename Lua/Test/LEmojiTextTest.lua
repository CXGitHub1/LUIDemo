LEmojiTextTest = LEmojiTextTest or BaseClass()

function LEmojiTextTest:__init(gameObject)
    local transform = gameObject.transform
    local scrollView = LSIScrollView.New(transform:Find("Test"), LEmojiTextItem, UtilsBase.INT32_MAX, 1)
    local dataList = {}
    local colorMax = 256 * 256 * 256
    for i = 1, 100 do
        local iconId = math.random(90000, 90007)
        local faceId = i % 2 + 1--math.random(1, 2)
        local buttonId = math.random(1, 7)
        local color = string.format("%02X", math.random(0, colorMax))
        -- table.insert(dataList, string.format("图标：<t=1,%s> 表情：<t=2,%s> 按钮：<t=3,%s> <t=4,超链接,%s>",
        --     iconId, faceId, buttonId, color))
        table.insert(dataList, string.format("<t=2,%s>", faceId))
    end
    scrollView:SetData(dataList)
end