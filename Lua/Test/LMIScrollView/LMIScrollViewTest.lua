LMIScrollViewTest = LMIScrollViewTest or BaseClass(BaseTest)

LMIScrollViewTest.Config = {
    -- {itemTypeList = {LMIScrollViewTestItem}, dataLength = 5, {sizeType = TestDefine.SizeType.fix}},
    -- {itemTypeList = {LMIScrollViewTestItem}, gapVertical = 10, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- --加点前置偏移
    -- {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 10, dataLength = 100, {sizeType = TestDefine.SizeType.fix}},
    {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 10, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- --ResetPosition
    -- {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 10, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- --Focus
    -- {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 5, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- --SetData
    -- {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 5, dataLength = 1000, {sizeType = TestDefine.SizeType.fix}},
    -- --SetCommonData 选中状态
    -- {itemTypeList = {LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem, LMIScrollViewTestItem}, gapVertical = 5, dataLength = 20, {sizeType = TestDefine.SizeType.fix}},
}

function LMIScrollViewTest:__init(gameObject)
    local transform = gameObject.transform
    -- local scrollView = LMIScrollView.New(transform:Find("Test0"), {LMIScrollViewTestItem})
    -- scrollView:SetData()
    -- local scrollView = LMIScrollView.New(transform:Find("Test01"),  {LMIScrollViewTestItem})
    -- scrollView:SetData({})
    for i = 1, #LMIScrollViewTest.Config do
        local config = LMIScrollViewTest.Config[i]
        -- local scrollView = LMIScrollView.New(transform:Find("Test" .. i), config.itemTypeList)
        local scrollView = LMIScrollView.New(transform:Find("Test4"), config.itemTypeList)
        scrollView:SetGap(config.gapHorizontal, config.gapVertical)
        scrollView:SetData(self:CreateDataList(config.dataLength, #config.itemTypeList), {sizeType = config.sizeType})
    end
end

function LMIScrollViewTest:CreateDataList(dataLength, itemTypeLength)
    local dataList = {}
    for i = 1, dataLength do
        table.insert(dataList, {type = math.random(1, itemTypeLength), data = i})
    end
    return dataList
end
