MenuItem = MenuItem or BaseClass(LItem)

function MenuItem:__init()
    local transform = self.transform
    self.transform = transform
    self.text = transform:Find("Text"):GetComponent(Text)
end

function MenuItem:SetData(data, commonData)
    self.text.text = data.name
end
