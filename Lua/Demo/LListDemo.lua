LListDemo = LListDemo or BaseClass(BaseDemo)

LListDemo.Config = {
    {row = 1, direction = LList.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    {column = 3, direction = LList.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.fix},
    {column = 2, direction = LList.Direction.horizontal, dataLength = 5, sizeType = TestDefine.SizeType.increase},
    {column = 2, row = 3, gapVertical = 5, gapHorizontal = 10, direction = LList.Direction.horizontal, dataLength = 11, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 3, gapVertical = 5, gapHorizontal = 10,
        paddingLeft = 20, paddingRight = -20, paddingTop = 10, paddingBottom = 40,
        direction = LList.Direction.horizontal, dataLength = 14, sizeType = TestDefine.SizeType.specified1},
    {column = 1, row = 4, gapVertical = 5, gapHorizontal = 10, 
        direction = LList.Direction.vertical, dataLength = 10, sizeType = TestDefine.SizeType.fix},
    {column = 2, row = 5, gapVertical = 5, gapHorizontal = 5, 
        paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
        direction = LList.Direction.vertical, dataLength = 15, sizeType = TestDefine.SizeType.fix},
    {column = 1, row = 1, gapVertical = 5, gapHorizontal = 5, 
        paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
        direction = LList.Direction.vertical, dataLength = 5, sizeType = TestDefine.SizeType.increase},
}

function LListDemo:__init(gameObject)
    local transform = gameObject.transform
    self.list = {}
    for i = 1, #LListDemo.Config do
        local config = LListDemo.Config[i]
        local list = LList.New(transform:Find("Test" .. i), LTestItem, config.row, config.column, config.direction)
        table.insert(self.list, list)
        list:SetGap(config.gapHorizontal, config.gapVertical)
        list:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
    end
end

function LListDemo:SetData()
    for i = 1, #self.list do
        local config = LListDemo.Config[i]
        local list = self.list[i]
        local dataList = self:CreateDataList(config.dataLength)
        list:SetData(dataList, {sizeType = config.sizeType})
    end
end
