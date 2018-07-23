LScrollPageTest = LScrollPageTest or BaseClass()

LScrollPageTest.Config = {
    -- {column = 1, row = 1, direction = LScrollPage.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    -- {column = 2, row = 1, direction = LScrollPage.Direction.horizontal, dataLength = 7, sizeType = TestDefine.SizeType.fix},
    -- {column = 2, row = 1, initPage = 2, direction = LScrollPage.Direction.horizontal, dataLength = 7, sizeType = TestDefine.SizeType.fix},
    -- {column = 2, row = 2, direction = LScrollPage.Direction.horizontal, dataLength = 9, sizeType = TestDefine.SizeType.fix},
    -- {column = 2, row = 2, direction = LScrollPage.Direction.horizontal,
    --     gapVertical = 5, gapHorizontal = 5,
    --     paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
    --     dataLength = 9, sizeType = TestDefine.SizeType.fix},
    -- {column = 3, direction = LScrollPage.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    -- {column = 1, row = 1, direction = LScrollPage.Direction.vertical, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    -- {column = 2, row = 2, direction = LScrollPage.Direction.vertical, dataLength = 10, initPage = 2, sizeType = TestDefine.SizeType.fix},
    -- {column = 2, row = 2, direction = LScrollPage.Direction.vertical, dataLength = 10, initPage = 2, sizeType = TestDefine.SizeType.fix},
    -- {column = 3, row = 3, direction = LScrollPage.Direction.vertical, dataLength = 5, initPage = 1, sizeType = TestDefine.SizeType.fix},
    -- {column = 3, row = 3, direction = LScrollPage.Direction.vertical, dataLength = 55,
    --     gapVertical = 5, gapHorizontal = 5,
    --     paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
    --     initPage = 2, sizeType = TestDefine.SizeType.fix},
}

function LScrollPageTest:__init(gameObject)
    local transform = gameObject.transform
    local scrollPage = LScrollPage.New(transform:Find("Test0"), LTestItem)
    scrollPage:SetData()
    -- local scrollPage = LScrollPage.New(transform:Find("Test01"), LTestItem)
    -- scrollPage:SetData({})
    for i = 1, #LScrollPageTest.Config do
        local config = LScrollPageTest.Config[i]
        -- local scrollPage = LScrollPage.New(transform:Find("Test" .. i), LTestItem, config.row, config.column, config.direction)
        local scrollPage = LScrollPage.New(transform:Find("Test10"), LTestItem, config.row, config.column, config.direction)
        scrollPage:SetGap(config.gapHorizontal, config.gapVertical)
        scrollPage:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        if config.initPage then
            scrollPage:InitCurrentPage(config.initPage)
        end
        local dataList = {}
        for i = 1, config.dataLength do
            table.insert(dataList, i)
        end
        scrollPage:SetData(dataList, {sizeType = config.sizeType})
        if config.initPage then
            scrollPage:SetCurrentPage(config.initPage)
        end
    end
end
