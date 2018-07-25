--chen quan
LScrollViewDemo = LScrollViewDemo or BaseClass(BaseDemo)

LScrollViewDemo.Config = {
    {column = 2, dataLength = 20, sizeType = TestDefine.SizeType.specified1},
    {row = 3, dataLength = 10000, startIndex = 1000, gapVertical = 10, gapHorizontal = 10, sizeType = TestDefine.SizeType.specified3},
    -- {column = 3, dataLength = 20, startIndex = 2, gapVertical = 10, gapHorizontal = 10,
    --     paddingLeft = 5, paddingRight = 20, paddingTop = 40, paddingBottom = 50,
    --     sizeType = TestDefine.SizeType.specified2},
    -- {column = 2, dataLength = 20, sizeType = TestDefine.SizeType.specified2}, --sendCallback
    --普通应用
    --游戏应用
    --成就界面
    --无限滑动？
}

function LScrollViewDemo:__init(transform)
    self.transform = transform
    self.list = {}
    for i = 1, #LScrollViewDemo.Config do
        local config = LScrollViewDemo.Config[i]
        local listView = LScrollView.New(transform:Find("Test" .. i), LDemoItem, config.row, config.column)
        table.insert(self.list, listView)
    end
end

function LScrollViewDemo:SetData()
    local transform = self.transform
    for i = 1, #self.list do
        local config = LScrollViewDemo.Config[i]
        local listView = self.list[i]
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
        -- if i == 1 then
        --     local button = transform:Find("Button12"):GetComponent(Button).onClick:AddListener(function()
        --         local randomValue = math.random(0, 100)
        --         local dataList = {}
        --         for j = 1, randomValue do
        --             table.insert(dataList, j)
        --         end
        --         listView:SetData(dataList, {sizeType = config.sizeType})
        --     end)
        -- end
    end 
end
