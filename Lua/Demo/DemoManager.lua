DemoManager = DemoManager or BaseClass()

DemoManager.Config = {
    {name = "LScrollViewDemo"},
}

function DemoManager:__init(transform)
    if DemoManager.Instance then
        return 
    end
    DemoManager.Instance = self

    self.transform = transform
    self.mainGo = transform.gameObject

    self.demoList = {}
    for i = 1, #DemoManager.Config do
        local config = DemoManager.Config[i]
        local demoTrans = transform:Find(config.name)
        local demo = _G[config.name].New(transform)
        demoTrans.gameObject:SetActive(false)
        table.insert(self.demoList, demo)
    end

    self.returnGo = transform:Find("Return").gameObject
    transform:Find("Return"):GetComponent(Button).onClick:AddListener(function() self:OnReturnClick() end)
    local scrollView = LScrollView.New(transform, DemoScrollViewItem, nil, 5)
    scrollView:SetGap(10, 10)
    scrollView.ItemSelectEvent:AddListener(function(index, item) self:OnItemClick() end)
    scrollView:SetData(DemoManager.Config)
end

function DemoManager:OnItemClick(index, item)
    local config = DemoManager.Config[index]
    local transform = self.transform:Find(config.name)
    _G[config.name].New(transform)
end

function DemoManager:OnReturnClick()
    self.mainGo:SetActive(true)
    --TODO
    for i = 1, #self.demoList do
    end
    self.returnButton.onClick:AddListener(function() self:OnReturnClick() end)
end


