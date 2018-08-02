LListDemo = LListDemo or BaseClass(BaseDemo)

LListDemo.Config = {
    --固定大小，水平显示
    {row = 1 direction = LList.Direction.horizontal, dataLength = 6, sizeType = TestDefine.SizeType.fix},
    --垂直显示，包括gap和padding，动态大小
    {column = 2, row = 4, direction = LList.Direction.horizontal,
        gapVertical = 5, gapHorizontal = 10,
        paddingLeft = 10, paddingRight = -10, paddingTop = 10, paddingBottom = 10,
        dataLength = 7, sizeType = TestDefine.SizeType.specified1},
    --水平显示，包括gap和padding，动态大小
    {column = 2, row = 4, direction = LList.Direction.vertical,
        gapVertical = 5, gapHorizontal = 10,
        paddingLeft = 10, paddingRight = -10, paddingTop = 10, paddingBottom = 10,
        dataLength = 7, sizeType = TestDefine.SizeType.specified1},
    --翻页显示
    {column = 2, row = 3, direction = LList.Direction.horizontal,
        gapVertical = 5, gapHorizontal = 10,
        dataLength = 9, sizeType = TestDefine.SizeType.specified1},
    --多次SetData
    {column = 2, row = 3, direction = LList.Direction.vertical,
        gapVertical = 5, gapHorizontal = 10,
        dataLength = 9, sizeType = TestDefine.SizeType.specified1},
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
        if i == 5 then
            local button = transform:Find("Button5"):GetComponent(Button)
            button.gameObject:SetActive(true)
            button.onClick:AddListener(function()
                local randomValue= math.random(5, 13)
                local dataList = self:CreateDataList(randomValue)
                list:SetData(dataList, {sizeType = config.sizeType})
            end)
        end
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
