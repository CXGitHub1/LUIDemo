LDemoItem = LDemoItem or BaseClass(LItem)

function LDemoItem:__init()
    local transform = self.transform
    self.transform = transform
    self.fixTrans = transform:Find()
end