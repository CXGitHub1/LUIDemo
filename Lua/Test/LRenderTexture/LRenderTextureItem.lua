LRenderTextureItem = LRenderTextureItem or BaseClass(LItem)

function LRenderTextureItem:__init()
    local transform = self.transform
    self.modelTrans = transform:Find("ModelBg")
    self.text = UtilsUI.GetText(transform, "Text")
end

function LRenderTextureItem:__release()
end

function LRenderTextureItem:SetData(data, commonData)
    
end
