LScrollViewDemo = LScrollViewDemo or BaseClass(BaseDemo)

LScrollViewDemo.Config = {
    --动态大小，垂直滚动
    {column = 2, dataLength = 20, sizeType = TestDefine.SizeType.specified1},
    --动态大小，水平滚动，初始化开始下标
    {row = 3, dataLength = 10000, startIndex = 1000, gapVertical = 10, gapHorizontal = 10, sizeType = TestDefine.SizeType.specified3},
    --动态大小，垂直滚动，初始化开始下标,包括gap和padding
    {column = 3, dataLength = 200, startIndex = 2, gapVertical = 10, gapHorizontal = 10,
        paddingLeft = 10, paddingRight = 20, paddingTop = 40, paddingBottom = 50,
        sizeType = TestDefine.SizeType.specified4},
    --滚动到底部动态添加数据
    {column = 2, gapVertical = 5, dataLength = 20, bottomData = 40, sizeType = TestDefine.SizeType.specified1},
    --多次SetData效果
    {column = 2, gapVertical = 5, dataLength = 20, sizeType = TestDefine.SizeType.specified1},
    --多事件交互
    {column = 2, gapVertical = 5, dataLength = 20, eventName = "IconClickEvent", sizeType = TestDefine.SizeType.fix},
}

function LScrollViewDemo:__init(transform)
    self.list = {}
    for i = 1, #LScrollViewDemo.Config do
        local config = LScrollViewDemo.Config[i]
        local listView = LScrollView.New(transform:Find("Test" .. i), LDemoItem, config.row, config.column)
        listView:SetGap(config.gapHorizontal, config.gapVertical)
        listView:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        listView.ItemSelectEvent:AddListener(function(index, item)
            Debug.Log("ItemSelectEvent:" .. index)
        end)
        if config.startIndex then
            listView:SetStartIndex(config.startIndex)
        end
        if config.eventName then
            listView:AddItemEvent(config.eventName)
            listView[config.eventName]:AddListener(function(index)
                Debug.Log(config.eventName .. ":" .. index)
            end)
        end
        if config.bottomData then
            local once = true
            listView.ReachBottomEvent:AddListener(function()
                if once then
                    once = false
                    local dataList = self:CreateDataList(config.bottomData)
                    listView:SetData(dataList, {sizeType = config.sizeType})
                end
            end)
        end
        if i == 5 then
            local button = transform:Find("Button5"):GetComponent(Button)
            button.gameObject:SetActive(true)
            button.onClick:AddListener(function()
                local randomValue= math.random(0, 100)
                local dataList = self:CreateDataList(randomValue)
                listView:SetData(dataList, {sizeType = config.sizeType})
            end)
        end
        table.insert(self.list, listView)
    end
end

function LScrollViewDemo:SetData()
    for i = 1, #self.list do
        local config = LScrollViewDemo.Config[i]
        local listView = self.list[i]
        local dataList = self:CreateDataList(config.dataLength)
        listView:SetData(dataList, {sizeType = config.sizeType})

    end 
end