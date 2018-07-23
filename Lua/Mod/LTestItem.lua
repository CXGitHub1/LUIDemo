LTestItem = LTestItem or BaseClass(LItem)

function LTestItem:__init()
    local transform = self.transform
    self.image = transform:GetComponent(Image)
end

function LTestItem:SetData()
    local path = "Texture/Icon/" .. tonumber(self.index + 17600)
    self.image.sprite = Resources.Load(path, Sprite)
    local offset = math.floor((self.index - 1) / 2) * 2
    self.transform.sizeDelta = Vector2(50 - offset, 50 - offset)
    -- self.transform.sizeDelta = Vector2(100, 4)
end
