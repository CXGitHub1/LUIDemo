LScrollViewTest = LScrollViewTest or BaseClass()

LScrollViewTest.Config = {
    {column = 1, dataLength = 10, sizeType = TestDefine.SizeType.fix},
    {column = 1, dataLength = 20, gapVertical = 4, sizeType = TestDefine.SizeType.fix},
    {column = 1, dataLength = 20, paddingTop = 10, sizeType = TestDefine.SizeType.specified},
    {column = 2, dataLength = 19, sizeType = TestDefine.SizeType.fix},
    {column = 2, dataLength = 40, startIndex = 3, gapVertical = 10, gapHorizontal = 10, sizeType = TestDefine.SizeType.decrease},
    {column = 4, dataLength = 10000, startIndex = 1000, gapVertical = 10, gapHorizontal = 10, paddingLeft = 5, paddingRight = 20, paddingTop = 40, paddingBottom = 50, sizeType = TestDefine.SizeType.fix},
    {column = 2, dataLength = 19, startIndex = 11, gapVertical = 30, gapHorizontal = 20, paddingLeft = 40, paddingRight = 40, paddingTop = 40, paddingBottom = 40, sizeType = TestDefine.SizeType.specified1},
    {row = 1, dataLength = 28, gapHorizontal = 10, paddingTop = 20, sizeType = TestDefine.SizeType.specified2},
    {row = 2, dataLength = 20, startIndex = 4, gapHorizontal = 10, paddingLeft = 40, paddingRight = 40, paddingTop = 40, paddingBottom = 40, sizeType = TestDefine.SizeType.decrease},
    {row = 2, dataLength = 20, startIndex = 4, gapHorizontal = 10, paddingLeft = 40, paddingRight = 40, paddingTop = 40, paddingBottom = 40, sizeType = TestDefine.SizeType.fix},
    {column = 2, dataLength = 20, bottomData = 40, sizeType = TestDefine.SizeType.fix},
    {column = 2, dataLength = 20, sizeType = TestDefine.SizeType.fix},
}

function LScrollViewTest:__init(gameObject)
    local transform = gameObject.transform
    local listView = LScrollView.New(transform:Find("Test0"), LTestItem, 1, 2)
    listView:SetData()
    local listView = LScrollView.New(transform:Find("Test01"), LTestItem, 3, 4)
    listView:SetData({})
    for i = 1, #LScrollViewTest.Config do
        local config = LScrollViewTest.Config[i]
        local listView = LScrollView.New(transform:Find("Test" .. i), LTestItem, config.row, config.column)
        -- local listView = LScrollView.New(transform:Find("Test12"), LTestItem, config.row, config.column)
        listView:SetGap(config.gapHorizontal, config.gapVertical)
        listView:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        if config.startIndex then
            listView:SetStartIndex(config.startIndex)
        end
        if config.bottomData then
            local once = true
            listView.ReachBottomEvent:AddListener(function()
                if once then
                    once = false
                    local dataList = {}
                    for i = 1, config.bottomData do
                        table.insert(dataList, i)
                    end
                    listView:SetData(dataList, {sizeType = config.sizeType})
                end
            end)
        end
        local dataList = {}
        for i = 1, config.dataLength do
            table.insert(dataList, i)
        end
        listView:SetData(dataList, {sizeType = config.sizeType})
        if i == 12 then
            local button = transform:Find("Button12"):GetComponent(Button).onClick:AddListener(function()
                local randomValue = math.random(0, 100)
                local dataList = {}
                for j = 1, randomValue do
                    table.insert(dataList, j)
                end
                listView:SetData(dataList, {sizeType = config.sizeType})
            end)
        end
    end
end
