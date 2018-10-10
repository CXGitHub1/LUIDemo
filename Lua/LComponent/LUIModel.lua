LUIModel = LUIModel or BaseClass()

LUIModel.X = 0

function LUIModel:__init(transform)
    self.transform = transform
    local rawImageGo = GameObject("RawImage")
    rawImageGo:AddComponent(RectTransform)
    local rawImageTrans = rawImageGo.transform
    UtilsBase.SetParent(rawImageTrans, transform)
    self.rawImage = rawImageGo:AddComponent(RawImage)
    self.width = transform.sizeDelta.x
    self.height = transform.sizeDelta.y
    rawImageTrans.sizeDelta = Vector2(self.width, self.height)
    self.once = false
end

function LUIModel:__release()
end

function LUIModel:SetData(data)
    if self.once then
        return
    end
    self.once = true
    self.loaderData = data
    local rootTrans = GameObject.Find("Preview").transform
    local cameraGo = GameObject.Instantiate(AssetLoader.Instance:Load(string.format(AssetDefine.UI_PREFAB_PATH, "PreviewCamera")))
    cameraGo.name = "PreviewCamera"
    UtilsBase.SetParent(cameraGo.transform, rootTrans)
    UtilsUI.SetX(cameraGo.transform, LUIModel.X)
    LUIModel.X = LUIModel.X + 20
    local camera = cameraGo:GetComponent(Camera)
    local modelGo = ModelLoader.Instance:Load(data)
    modelGo.name = data.modelId
    local modelTrans = modelGo.transform
    UtilsBase.SetLayer(modelTrans, "UIModel")
    modelTrans:SetParent(cameraGo.transform)
    modelTrans.localScale = Vector3.one
    modelTrans.localPosition = Vector3(0, 0, 20)
    modelTrans.localRotation = Vector3(0, 180, 0)
    self.renderTexture = RenderTexture.GetTemporary(self.width, self.height, 24)
    self.rawImage.texture = self.renderTexture
    camera.targetTexture = self.renderTexture
end
