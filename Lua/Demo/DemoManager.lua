DemoManager = DemoManager or BaseClass()

DemoManager.Config = {
    {name = "LScrollViewDemo"},
    {name = "LScrollViewDemo1"},
    -- {name = "LListDemo"},
}

function DemoManager:__init(rootTrans)
    if DemoManager.Instance then
        return 
    end
    DemoManager.Instance = self

    self.currentIndex = nil

    local transform = rootTrans
    self.returnGo = transform:Find("ReturnButton").gameObject
    self.returnGo:SetActive(false)
    transform:Find("ReturnButton"):GetComponent(Button).onClick:AddListener(function() self:OnReturnClick() end)
    self.menuGo = rootTrans:Find("Menu").gameObject
    local scrollView = LScrollView.New(transform:Find("Menu"), MenuItem, nil, 4)
    scrollView:SetGap(20, 100)
    scrollView.ItemSelectEvent:AddListener(function(index, item) self:OnItemClick(index, item) end)
    scrollView:SetData(DemoManager.Config)

    self.demoList = {}
    for i = 1, #DemoManager.Config do
        local config = DemoManager.Config[i]
        local demoTrans = transform:Find(config.name)
        local demo = _G[config.name].New(demoTrans)
        demoTrans.gameObject:SetActive(false)
        table.insert(self.demoList, demo)
    end
end

function DemoManager:OnItemClick(index, item)
    self.currentIndex = index
    self.returnGo:SetActive(true)
    local demo = self.demoList[index]
    demo:SetActive(true)
    demo:SetData()
    self.menuGo:SetActive(false)
end

function DemoManager:OnReturnClick()
    self.returnGo:SetActive(false)
    self.menuGo:SetActive(true)
    self.demoList[self.currentIndex]:SetActive(false)
end


