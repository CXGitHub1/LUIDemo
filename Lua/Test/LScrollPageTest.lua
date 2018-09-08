LScrollPageTest = LScrollPageTest or BaseClass(BaseTest)

LScrollPageTest.Config = {
    {column = 1, row = 1, direction = LDefine.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 1, direction = LDefine.Direction.horizontal, dataLength = 7, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 1, initPage = 2, direction = LDefine.Direction.horizontal, dataLength = 7, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 2, direction = LDefine.Direction.horizontal, dataLength = 9, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 2, direction = LDefine.Direction.horizontal,
        gapVertical = 5, gapHorizontal = 5,
        paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
        dataLength = 9, sizeType = TestDefine.SizeType.fix},
    {column = 3, direction = LDefine.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    {column = 1, row = 1, direction = LDefine.Direction.vertical, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 2, direction = LDefine.Direction.vertical, dataLength = 10, initPage = 2, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 2, direction = LDefine.Direction.vertical, dataLength = 10, initPage = 2, sizeType = TestDefine.SizeType.fix},
    {column = 3, row = 3, direction = LDefine.Direction.vertical, dataLength = 9, initPage = 1, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 2, direction = LDefine.Direction.horizontal, dataLength = 100, initPage = 2, sizeType = TestDefine.SizeType.fix},
}

function LScrollPageTest:__init(gameObject)
    local transform = gameObject.transform
    local scrollPage = LScrollPage.New(transform:Find("Test0"), LTestItem)
    scrollPage:SetData()
    local scrollPage = LScrollPage.New(transform:Find("Test01"), LTestItem)
    scrollPage:SetData({})
    for i = 1, #LScrollPageTest.Config do
        local config = LScrollPageTest.Config[i]
        local scrollPage = LScrollPage.New(transform:Find("Test" .. i), LTestItem, config.row, config.column, config.direction)
        -- local scrollPage = LScrollPage.New(transform:Find("Test10"), LTestItem, config.row, config.column, config.direction)
        scrollPage:SetGap(config.gapHorizontal, config.gapVertical)
        scrollPage:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        if config.initPage then
            scrollPage:InitCurrentPage(config.initPage)
        end
        scrollPage:SetData(self:CreateDataList(config.dataLength), {sizeType = config.sizeType})
        if config.initPage then
            scrollPage:SetCurrentPage(config.initPage)
        end
        if i == 10 then
            local button = transform:Find("Button10"):GetComponent(Button).onClick:AddListener(function()
                local randomValue = math.random(0, 20)
                scrollPage:SetData(self:CreateDataList(randomValue), {sizeType = config.sizeType})
            end)
        end
        if i == 11 then
            local button = transform:Find("Button11"):GetComponent(Button).onClick:AddListener(function()
                local randomValue = math.random(1, 10)
                scrollPage:SetCurrentPage(randomValue, true)
            end)
        end
    end
end
