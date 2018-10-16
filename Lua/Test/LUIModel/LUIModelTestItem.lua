LUIModelTestItem = LUIModelTestItem or BaseClass(LItem)

function LUIModelTestItem:__init()
    local transform = self.transform
    self.uiModel = LUIModel.New(transform:Find("ModelBg"))
    self.modelTrans = transform:Find("ModelBg")
    self.text = UtilsUI.GetText(transform, "Text")
end

function LUIModelTestItem:__release()
end

function LUIModelTestItem:SetData(data, commonData)
    self.text.text = data.modelId
    local offsetY = -6
    if data.modelId == 80004 then
        offsetY = -8
    end
    self.uiModel:SetData(data, 0, 1, Vector3(0, 135, 0))
end
