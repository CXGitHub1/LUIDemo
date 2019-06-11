LScrollPageTest = LScrollPageTest or BaseClass(BaseTest)

LScrollPageTest.Config = {
    --测空数据
    {column = 1, row = 1, direction = LDefine.Direction.horizontal},
    --单个水平滚动
    {column = 1, row = 1, direction = LDefine.Direction.horizontal, dataLength = 5},
    --多个垂直滚动 带gap
    {column = 2, row = 2, gapVertical = 15, gapHorizontal = 15, 
        paddingLeft = 15, paddingRight = 15, paddingTop = 15, paddingBottom = 15, direction = LDefine.Direction.horizontal, dataLength = 21},
    --多个水平滚动 元素水平布局 带padding 带gap 测initPage
    {column = 3, row = 3, direction = LDefine.Direction.horizontal,
        gapVertical = 5, gapHorizontal = 5,
        paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5,
        dataLength = 20},
    --多个垂直滚动 元素垂直布局 带padding 带gap 测initPage
    {column = 2, row = 2, direction = LDefine.Direction.vertical,
        gapVertical = 1, gapHorizontal = 3,
        paddingLeft = 5, paddingRight = 7, paddingTop = 9, paddingBottom = 0,
        initPage = 30,
        dataLength = 200},
    --多个水平滚动 元素垂直布局 测频繁SetData 带initPage SetData把数据清空 测释放
    {column = 3, row = 3, initPage = 2, direction = LDefine.Direction.vertical, dataLength = 20},
    --多个垂直滚动 元素水平布局 测频繁SetCurrentPage
    {column = 3, row = 3, direction = LDefine.Direction.horizontal, dataLength = 100},
    --水平滚动 水平翻页 测不超过一页的布局
    {column = 2, row = 3, direction = LDefine.Direction.horizontal, dataLength = 3},
    --垂直滚动 垂直翻页 测不超过一页的布局
    {column = 3, row = 3, direction = LDefine.Direction.vertical, dataLength = 7},
}

function LScrollPageTest:__init(gameObject)
    local transform = gameObject.transform
    local singleTest = false
    for i = 1, #LScrollPageTest.Config do
        local config
        local scrollPage
        if singleTest then
            i = 4
        end
        config = LScrollPageTest.Config[i]
        scrollPage = LScrollPage.New(transform:Find("Test" .. i), LTestItem, config.row, config.column, config.direction)
        scrollPage:SetGap(config.gapHorizontal, config.gapVertical)
        scrollPage:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        if config.initPage then
            scrollPage:SetInitPage(config.initPage)
        end
        if singleTest then
            scrollPage:SetData(self:CreateDataList(config.dataLength))
            break
        else
            if i == 1 then
                scrollPage:SetData()
            else
                scrollPage:SetData(self:CreateDataList(config.dataLength))
            end
        end
        if i == 6 then
            transform:Find("Test6/SetData"):GetComponent(Button).onClick:AddListener(function()
                local randomValue = math.random(0, 20)
                scrollPage:SetData(self:CreateDataList(randomValue))
            end)
            transform:Find("Test6/Release"):GetComponent(Button).onClick:AddListener(function()
                scrollPage:Release()
            end)
        end
        if i == 7 then
            transform:Find("Test7/SetCurrentPage"):GetComponent(Button).onClick:AddListener(function()
                local randomValue = math.random(1, 10)
                scrollPage:SetCurrentPage(randomValue, true)
            end)
        end
        if i == 8 then
            transform:Find("Test8/SetData"):GetComponent(Button).onClick:AddListener(function()
                local randomValue = math.random(0, 6)
                scrollPage:SetData(self:CreateDataList(randomValue))
            end)
        end
        if i == 9 then
            transform:Find("Test9/SetData"):GetComponent(Button).onClick:AddListener(function()
                local randomValue = math.random(0, 20)
                scrollPage:SetData(self:CreateDataList(randomValue))
            end)
        end
    end
end
