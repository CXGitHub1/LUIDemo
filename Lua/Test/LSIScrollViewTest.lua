LSIScrollViewTest = LSIScrollViewTest or BaseClass(BaseTest)

LSIScrollViewTest.Config = {
    --一列 簡單例子
    {column = 1, dataLength = 10, bottomData = 100, sizeType = TestDefine.SizeType.fix},
    --兩列 帶gap 帶Focus 和 ResetPosition
    {column = 2, dataLength = 10000, gapVertical = 4, sizeType = TestDefine.SizeType.fix},
    --一行 帶padding 測SetCommon 选中
    {row = 1, dataLength = 30, sizeType = TestDefine.SizeType.fix, gapHorizontal = 10, paddingLeft = 40, paddingRight = 40, paddingTop = 40, paddingBottom = 40},
    --三行 帶gap padding 測SetData 測空 測Release  Focus  bottomData
    {row = 3, dataLength = 21, bottomData = 30, paddingRight = 40, sizeType = TestDefine.SizeType.fix},
}

function LSIScrollViewTest:__init(gameObject)
    local transform = gameObject.transform
    local scrollView = LSIScrollView.New(transform:Find("Test0"), LTestItem, 1, 2)
    scrollView:SetData()
    local scrollView = LSIScrollView.New(transform:Find("Test01"), LTestItem, 3, 4)
    scrollView:SetData({})
    for i = 1, #LSIScrollViewTest.Config do
        local config = LSIScrollViewTest.Config[i]
        local scrollView = LSIScrollView.New(transform:Find("Test" .. i), LTestItem, config.row, config.column)
        -- local scrollView = LSIScrollView.New(transform:Find("Test4"), LTestItem, config.row, config.column)
        scrollView:SetGap(config.gapHorizontal, config.gapVertical)
        scrollView:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        if config.bottomData then
            local once = true
            scrollView.ReachBottomEvent:AddListener(function()
                if once then
                    once = false
                    scrollView:SetData(self:CreateDataList(config.bottomData), {sizeType = config.sizeType})
                end
            end)
        end
        scrollView:SetData(self:CreateDataList(config.dataLength), {sizeType = config.sizeType})
        if i == 4 then
            transform:Find("Button4_1").gameObject:SetActive(true)
            transform:Find("Button4_2").gameObject:SetActive(true)
            transform:Find("Button4_3").gameObject:SetActive(true)
            local text = UtilsUI.GetText(transform, "Button4_1/Text")
            UtilsUI.AddButtonListener(transform, "Button4_1", function()
                local rv = self:RandomValue(100)
                text.text = string.format("SetData(%s)", rv)
                scrollView:SetData(self:CreateDataList(rv), {sizeType = config.sizeType})
            end)
            local text = UtilsUI.GetText(transform, "Button4_2/Text")
            UtilsUI.AddButtonListener(transform, "Button4_2", function()
                local value = self:RandomValue(config.dataLength)
                text.text = string.format("Focus(%s)", value)
                scrollView:Focus(value, true)
            end)
            UtilsUI.AddButtonListener(transform, "Button4_3", function()
                scrollView:Release()
            end)

        elseif i == 3 then
            scrollView.ItemSelectEvent:AddListener(function(index)
                scrollView:SetCommonData({sizeType = config.sizeType, selectIndex = index})
            end)
        elseif i == 2 then
            transform:Find("Button2_1").gameObject:SetActive(true)
            local text = UtilsUI.GetText(transform, "Button2_1/Text")
            UtilsUI.AddButtonListener(transform, "Button2_1", function()
                local value = self:RandomValue(config.dataLength)
                text.text = string.format("Focus(%s)", value)
                scrollView:Focus(value, true)
            end)
            UtilsUI.AddButtonListener(transform, "Button2_2", function()
                scrollView:ResetPosition()
            end)
        end
    end
end

function LSIScrollViewTest:RandomValue(length)
    math.randomseed(os.time())
    return math.random(1, length)
end
