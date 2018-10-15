--camera参数设置
--fieldOfView有所改动 因为scale为1，而不是游戏中的配置 z轴也因此有所调整
--透视效果不好处理，模型以脚为锚点，透视还要计算模型的偏移，让摄像机对准模型中点
--否则效果不好，我决定类型改为正交

--rotate参考游戏
--model放在root节点，不放在camera节点是为了让camera rotation生效 不然模型跟着camera一起旋转，始终只能看到模型正面
--模型默认播放的动作是stand动作，因为模型坐标固定在脚底，所以为了让摄像机能正面对准模型中心，而不是对准脚底
--所以需要一个stand动作的高度，让模型根据standHeigt向下偏移，摄像机能对准模型中间

--模型大小 参数配置个展示模型大小


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
    self.rawImageTrans = rawImageTrans
    UtilsBase.UISetParent(rawImageTrans, transform)
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
    cameraTrans.localEulerAngles = Vector3One
    cameraTrans.localScale = Vector3One
    cameraTrans.localPosition = Vector3(LUIModel.X, 0, 0)
    LUIModel.X = LUIModel.X + 20
end

function LUIModel:InitRenderTexture()
    if self.renderTexture then
        return
    end
    local camera = self.cameraGo:GetComponent(Camera)
    self.renderTexture = RenderTexture.GetTemporary(self.width * 1.5, self.height * 1.5, 24)
    self.rawImage.texture = self.renderTexture
    camera.targetTexture = self.renderTexture
end

function LUIModel:SetData(loaderData, anchoredPosition, scale, rotation)
    self.loaderData = loaderData
    self:InitCamera()
    self:InitRenderTexture()
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
    -- print(tostring(scale))
    -- print(config.uiScale)
    modelTrans.localScale = Vector3One -- * scale / config.uiScale
    modelTrans.localEulerAngles = rotation or Vector3(0, 180, 0)
    local offsetY = 0 --  -config.standHeight / 2
    modelTrans.localPosition = self.cameraTrans.localPosition + Vector3(0, offsetY, 10)
    if anchoredPosition then
        self.rawImageTrans.anchoredPosition3D = Vector3(0, -self.height / 2, 0)
    end
end
