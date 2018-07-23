DemoScrollViewItem = DemoScrollViewItem or BaseClass(LItem)

function DemoScrollViewItem:__init()
    local transform = self.transform
    self.transform = transform
    self.text = transform:Find("Text"):GetComponent(Text)
end

function DemoScrollViewItem:SetData(data, commonData)
    self.text.text = data
end
