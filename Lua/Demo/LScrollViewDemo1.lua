LScrollViewDemo1 = LScrollViewDemo1 or BaseClass(BaseDemo)

function LScrollViewDemo1:__init(transform)
    self.transform = transform
    self.listView = LScrollView.New(transform, LScrollViewDemoItem1, nil, 1)
    self.listView:SetGap(10, 10)
end

function LScrollViewDemo1:SetData()
	self.listView:SetData()
end
