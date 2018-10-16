LUIModel = LUIModel or BaseClass()

function LUIModel:__init(transform)
    if LUIModel.staticInit == nil then
        LUIModel.staticInit = true
        self:StaticInit()
    end
    self.transform = transform
    local rawImageGo = GameObject("RawImage")
    rawImageGo:AddComponent(RectTransform)
    local rawImageTrans = rawImageGo.transform
    self.rawImageTrans = rawImageTrans
    UtilsBase.UISetParent(rawImageTrans, transform)
    self.rawImage = rawImageGo:AddComponent(RawImage)
    self.width = transform.sizeDelta.x
    self.height = transform.sizeDelta.y
    rawImageTrans.sizeDelta = Vector2(self.width, self.height)
end

function LUIModel:__release()
end

function LUIModel:StaticInit()
    local rootTrans = GameObject.Find("Preview").transform
    LUIModel.rootTrans = rootTrans
    LUIModel.X = 0
    LUIModel.cameraTemplate = AssetLoader.Instance:Load(string.format(AssetDefine.UI_PREFAB_PATH, "PreviewCamera"))
end

function LUIModel:InitCamera()
    if self.cameraGo then
        return
    end
    local cameraGo = GameObject.Instantiate(LUIModel.cameraTemplate)
    self.cameraGo = cameraGo
    self.cameraTrans = cameraGo.transform
    cameraGo.name = "PreviewCamera"
    local cameraTrans = cameraGo.transform
    cameraTrans:SetParent(LUIModel.rootTrans)
    cameraTrans.localEulerAngles = Vector3One
    cameraTrans.localScale = Vector3One
    cameraTrans.localPosition = Vector3(LUIModel.X, 0, 0)
    LUIModel.X = LUIModel.X + 20
end

function LUIModel:SetData(loaderData, offsetY, scale, rotation)
    self.loaderData = loaderData
    self:InitCamera()
    if self.modelGo then
        -- 如果卡顿的原因是TempAlloc.Overflow，试试开启下面这句
        -- self.modelGo:GetComponent(Animation).enabled = false
        GameObject.Destroy(self.modelGo)
        self.modelGo = nil
    end
    local modelGo = ModelLoader.Instance:Load(loaderData)
    self.modelGo = modelGo
    local modelTrans = modelGo.transform
    UtilsBase.SetLayer(modelTrans, "UIModel")
    modelTrans:SetParent(LUIModel.rootTrans)
    local config = ModelConfigHelper.GetConfig(loaderData.modelId)
    modelTrans.localScale = Vector3One * scale / config.uiScale
    modelTrans.localEulerAngles = rotation or Vector3(0, 180, 0)
    modelTrans.localPosition = self.cameraTrans.localPosition + Vector3(0, offsetY, LUIModel.MODEL_Z)
end
