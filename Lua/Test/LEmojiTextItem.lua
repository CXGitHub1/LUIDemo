LEmojiTextItem = LEmojiTextItem or BaseClass(LItem)

function LEmojiTextItem:__init()
    local transform = self.transform
    self.emojiText = transform:Find("Text"):GetComponent(EmojiText.EmojiText)
end

function LEmojiTextItem:SetData(data)
    self.emojiText.text = data
end
