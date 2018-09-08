LListTest = LListTest or BaseClass(BaseTest)

LListTest.Config = {
    {row = 1, direction = LDefine.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    {column = 3, direction = LDefine.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    {column = 2, direction = LDefine.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.increase},
    {column = 2, row = 3, gapVertical = 5, gapHorizontal = 10, direction = LDefine.Direction.horizontal, dataLength = 11, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 3, gapVertical = 5, gapHorizontal = 10,
        paddingLeft = 20, paddingRight = -20, paddingTop = 10, paddingBottom = 40,
        direction = LDefine.Direction.horizontal, dataLength = 14, sizeType = TestDefine.SizeType.specified1},
    {column = 1, row = 4, gapVertical = 5, gapHorizontal = 10, 
        direction = LDefine.Direction.vertical, dataLength = 10, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 5, gapVertical = 5, gapHorizontal = 5, 
        paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
        direction = LDefine.Direction.vertical, dataLength = 15, sizeType = TestDefine.SizeType.fix},
    {column = 1, row = 1, gapVertical = 5, gapHorizontal = 5, 
        paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
        direction = LDefine.Direction.vertical, dataLength = 5, sizeType = TestDefine.SizeType.increase},
}

function LListTest:__init(gameObject)
    local transform = gameObject.transform
    local list = LList.New(transform:Find("Test0"), LTestItem)
    list:SetData()
    local list = LList.New(transform:Find("Test01"), LTestItem)
    list:SetData({})
    for i = 1, #LListTest.Config do
        local config = LListTest.Config[i]
        local list = LList.New(transform:Find("Test" .. i), LTestItem, config.row, config.column, config.direction)
        -- local list = LList.New(transform:Find("Test2"), LTestItem, config.row, config.column, config.direction)
        list:SetGap(config.gapHorizontal, config.gapVertical)
        list:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        list:SetData(self:CreateDataList(config.dataLength), {sizeType = config.sizeType})
    end
end
