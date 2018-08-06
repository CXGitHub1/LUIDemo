--无限滚动列表？
LScrollPageDemo = LScrollPageDemo or BaseClass(BaseDemo)

LScrollPageDemo.Config = {
	--正常滚动 水平
	{row = 1, column = 2, direction = LScrollPage.Direction.horizontal, dataLength = 20, sizeType = TestDefine.SizeType.fix},
	--加各种参数的滚动 垂直滚动 initPage
	{row = 2, column = 2, direction = LScrollPage.Direction.vertical,
        gapVertical = 10, gapHorizontal = 10,
        paddingLeft = 50, paddingRight = 50, paddingTop = 50, paddingBottom = 50,
        initPage = 5,
		dataLength = 100, sizeType = TestDefine.SizeType.fix},
	--SetCurrentPage 频繁
	{row = 2, column = 2, direction = LScrollPage.Direction.horizontal,
		initPage = 40,
		dataLength = 10000, sizeType = TestDefine.SizeType.fix},
	--频繁SetData
	{row = 2, column = 2, direction = LScrollPage.Direction.vertical,
		dataLength = 10, sizeType = TestDefine.SizeType.fix},
}

function LScrollPageDemo:__init(transform)
    self.list = {}
    for i = 1, #LScrollPageDemo.Config do
        local config = LScrollPageDemo.Config[i]
        local scrollPage = LScrollPage.New(transform:Find("Test" .. i), LDemoItem, config.row, config.column, config.direction)
        scrollPage:SetGap(config.gapHorizontal, config.gapVertical)
        scrollPage:SetPadding(config.paddingLeft, config.paddingRight, config.paddingTop, config.paddingBottom)
        if config.initPage then
            scrollPage:InitCurrentPage(config.initPage)
        end
        scrollPage.ItemSelectEvent:AddListener(function(index, item)
            Debug.Log("ItemSelectEvent:" .. index)
        end)
        if i == 3 then
	        local button = transform:Find("Button3"):GetComponent(Button)
	        local text = UtilsUI.GetText(transform, "Button3/Text")
            button.gameObject:SetActive(true)
            button.onClick:AddListener(function()
                local randomValue= math.random(20, 30)
                text.text = "SetCurrentPage(" .. randomValue .. ")"
            	scrollPage:SetCurrentPage(randomValue, true)
            end)
        end
        if i == 4 then
	        local button = transform:Find("Button4"):GetComponent(Button)
	        local text = UtilsUI.GetText(transform, "Button4/Text")
            button.gameObject:SetActive(true)
            button.onClick:AddListener(function()
                local randomValue= math.random(2, 20)
                text.text = "SetData(" .. randomValue .. ")"
                scrollPage:SetData(self:CreateDataList(randomValue), {sizeType = config.sizeType})
            end)
        end
        table.insert(self.list, scrollPage)
    end
end

function LScrollPageDemo:__release()
	UtilsBase.ReleaseTable(self, "list")
end

function LScrollPageDemo:SetData()
    for i = 1, #self.list do
        local config = LScrollPageDemo.Config[i]
        self.list[i]:SetData(self:CreateDataList(config.dataLength), {sizeType = config.sizeType})
    end 
end

