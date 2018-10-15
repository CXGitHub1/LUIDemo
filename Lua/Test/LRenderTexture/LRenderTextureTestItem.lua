LRenderTextureTestItem = LRenderTextureTestItem or BaseClass(LItem)

function LRenderTextureTestItem:__init()
    local transform = self.transform
    self.uiModel = LUIModel.New(transform:Find("ModelBg"))
    self.modelTrans = transform:Find("ModelBg")
    self.text = UtilsUI.GetText(transform, "Text")
end

function LRenderTextureTestItem:__release()
end

function LRenderTextureTestItem:SetData(data, commonData)
    self.text.text = data.modelId
    self.uiModel:SetData(data, Vector3(0, -80, 0), 3, Vector3(0, 135, 0))
end
