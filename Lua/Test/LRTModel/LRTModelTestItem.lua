LRTModelTestItem = LRTModelTestItem or BaseClass(LItem)

function LRTModelTestItem:__init()
    local transform = self.transform
    self.rtModel = LRTModel.New(transform:Find("ModelBg"))
    self.modelTrans = transform:Find("ModelBg")
    self.text = UtilsUI.GetText(transform, "Text")
end

function LRTModelTestItem:__release()
end

function LRTModelTestItem:SetData(data, commonData)
    self.text.text = data.modelId
    local offsetY = -6
    if data.modelId == 80004 then
        offsetY = -8
    end
    self.rtModel:SetData(data, offsetY, 1, Vector3(0, 135, 0))
end
