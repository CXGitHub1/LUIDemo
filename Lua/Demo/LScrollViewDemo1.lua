-- 点击下滑效果
LScrollViewDemo1 = LScrollViewDemo1 or BaseClass(BaseDemo)

function LScrollViewDemo1:__init(transform)
    self.transform = transform
    self.scrollView = LScrollView.New(transform:Find("Test"), LScrollViewDemoItem1, nil, 1)
    self.scrollView:SetGap(10, 10)
    self.selectIndex = nil
    self.scrollView.ItemSelectEvent:AddListener(function(index, item)
        self.selectIndex = index
        self:PullDown()
        item:PullDown()
    end)
end

function LScrollViewDemo1:SetData()
    self.dataList = self:CreateDataList(30)
	self.scrollView:SetData(self.dataList, self.selectIndex)
end

function LScrollViewDemo1:PullDown()
    self.scrollView:SetData(self.dataList, self.selectIndex)
end
