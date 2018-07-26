LScrollViewDemo1 = LScrollViewDemo1 or BaseClass(BaseDemo)

function LScrollViewDemo1:__init(transform)
    self.transform = transform
    self.listView = LScrollView.New(transform)
end