--camera参数设置
--fieldOfView有所改动 因为scale为1，而不是游戏中的配置 z轴也因此有所调整
--rotate参考游戏
--model放在root节点，不放在camera节点是为了让camera rotation生效
-- 模型的大小通过读取配置获取 可以设置offsetPosition 和 scale

--StaticInit 就是c#的静态构造函数
--SetData只会重新加载模型 摄像机 RenderTexture都在初始化构造
--RenderTexture用 缓存池机制

--RenderTexture占用的内存貌似过高，高如果只属于UI，其实可以接受，因为好处挺明显
--localRotation 是slua暴露的接口吧，用的参数是Quaternion

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
    UtilsBase.SetParent(rawImageTrans, transform)
    self.rawImage = rawImageGo:AddComponent(RawImage)
    self.width = transform.sizeDelta.x
    self.height = transform.sizeDelta.y
    rawImageTrans.sizeDelta = Vector2(self.width, self.height)
end

function LUIModel:__release()
    if self.renderTexture then
        RenderTexture.ReleaseTemporary(self.renderTexture)
        self.renderTexture = nil
    end
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
    cameraTrans.localEulerAngles = Vector3(5, 0, 0)
    cameraTrans.localScale = Vector3One
    cameraTrans.localPosition = Vector3(LUIModel.X, 0, 0)
    LUIModel.X = LUIModel.X + 20
end

function LUIModel:InitRenderTexture()
    if self.renderTexture then
        return
    end
    local camera = self.cameraGo:GetComponent(Camera)
    self.renderTexture = RenderTexture.GetTemporary(self.width, self.height, 24)
    self.rawImage.texture = self.renderTexture
    camera.targetTexture = self.renderTexture
end

function LUIModel:SetData(loaderData, offsetPosition, scale)
    self.loaderData = loaderData
    self:InitCamera()
    self:InitRenderTexture()
    if self.modelGo then
        GameObject.Destroy(self.modelGo)
        self.modelGo = nil
    end
    local modelGo = ModelLoader.Instance:Load(loaderData)
    self.modelGo = modelGo
    local modelTrans = modelGo.transform
    UtilsBase.SetLayer(modelTrans, "UIModel")
    modelTrans:SetParent(LUIModel.rootTrans)
    modelTrans.localScale = scale or Vector3One
    modelTrans.localEulerAngles = Vector3(0, 180, 0)
    local position = offsetPosition or Vector3Zero
    modelTrans.localPosition = position + self.cameraTrans.localPosition + Vector3(0, 0, 10)
end
