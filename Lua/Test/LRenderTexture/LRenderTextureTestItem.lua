LRenderTextureTestItem = LRenderTextureTestItem or BaseClass(LItem)

function LRenderTextureTestItem:__init()
    local transform = self.transform
    self.uiModel = LRTModel.New(transform:Find("ModelBg"))
    self.modelTrans = transform:Find("ModelBg")
    self.text = UtilsUI.GetText(transform, "Text")
end

function LRenderTextureTestItem:__release()
end

function LRenderTextureTestItem:SetData(data, commonData)
    self.text.text = data.modelId
    local offsetY = -6
    if data.modelId == 80004 then
        offsetY = -8
    end
    self.uiModel:SetData(data, offsetY, 1, Vector3(0, 135, 0))
end
