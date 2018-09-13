LMIScrollViewTest = LMIScrollViewTest or BaseClass(BaseTest)

LMIScrollViewTest.Config = {
    -- 简单例子 单Item 测主体功能
    {itemTypeList = {LMIScrollViewTestItem}, dataLength = 5, {sizeType = TestDefine.SizeType.fix}},
    -- 带gap 大量数据 测复用
    {itemTypeList = {LMIScrollViewTestItem}, gapVertical = 10, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- 多Item 测多Item 以及复用
    {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 10, dataLength = 100, {sizeType = TestDefine.SizeType.fix}},
    {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem1, LMIScrollViewTestItem2}, gapVertical = 10, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- 测ResetPosition 和 Focus接口
    {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem1, LMIScrollViewTestItem2}, gapVertical = 10, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- 频繁SetData 用gm测Release
    {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem1, LMIScrollViewTestItem2}, gapVertical = 5, dataLength = 100, {sizeType = TestDefine.SizeType.fix}},
    -- --SetCommonData 测选中状态
    {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 5, dataLength = 20, {sizeType = TestDefine.SizeType.fix}},
}

function LMIScrollViewTest:__init(gameObject)
    local transform = gameObject.transform
    local scrollView = LMIScrollView.New(transform:Find("Test0"), {LMIScrollViewTestItem})
    scrollView:SetData()
    local scrollView = LMIScrollView.New(transform:Find("Test01"), {LMIScrollViewTestItem})
    scrollView:SetData({})
    for i = 1, #LMIScrollViewTest.Config do
        local config = LMIScrollViewTest.Config[i]
        local scrollView = LMIScrollView.New(transform:Find("Test" .. i), config.itemTypeList)
        -- local scrollView = LMIScrollView.New(transform:Find("Test7"), config.itemTypeList)
        self.scrollView = scrollView
        if config.gapVertical then
            scrollView:SetGap(config.gapVertical)
        end
        scrollView:SetData(self:CreateDataList(config.dataLength, #config.itemTypeList), {sizeType = config.sizeType})

        if i == 7 then
            scrollView.ItemSelectEvent:AddListener(function(index, item)
                scrollView:SetCommonData(index)
            end)
        elseif i == 6 then
            transform:Find("Button6").gameObject:SetActive(true)
            UtilsUI.AddButtonListener(transform, "Button6", function()
                local length = math.random(0, config.dataLength)
                UtilsUI.GetText(transform, "Button6/Text").text = string.format("SetData(%s)", length)
                scrollView:SetData(self:CreateDataList(length, #config.itemTypeList), {sizeType = config.sizeType})
            end)
        elseif i == 5 then
            transform:Find("Button5_1").gameObject:SetActive(true)
            transform:Find("Button5_2").gameObject:SetActive(true)
            UtilsUI.AddButtonListener(transform, "Button5_1", function()
                scrollView:ResetPosition()
            end)
            UtilsUI.AddButtonListener(transform, "Button5_2", function()
                local value = math.random(1, config.dataLength)
                UtilsUI.GetText(transform, "Button5_2/Text").text = string.format("Focus(%s)", value)
                scrollView:Focus(value, value % 2 == 1)
            end)
        end
    end
end

function LMIScrollViewTest:CreateDataList(dataLength, itemTypeLength)
    local dataList = {}
    math.randomseed(os.time())
    for i = 1, dataLength do
        table.insert(dataList, {type = math.random(1, itemTypeLength), data = i})
    end
    return dataList
end
