LRenderTextureTest = LRenderTextureTest or BaseClass(BaseTest)

function LRenderTextureTest:__init(gameObject)
    local transform = gameObject.transform
    local rootTrans = GameObject.Find("Preview").transform
    local cameraGo = GameObject.Instantiate(AssetLoader.Instance:Load(string.format(AssetDefine.UI_PREFAB_PATH, "PreviewCamera")))
    UtilsBase.SetParent(cameraGo.transform, rootTrans)
    cameraGo.name = "PreviewCamera"
    local modelGo = ModelLoader.Instance:Load(80002, 80002, 80002)
    modelGo.name = "80002"
    local modelTrans = modelGo.transform
    local childTransList = modelTrans:GetComponentsInChildren(Transform)
    for i = 1, #childTransList do
        childTransList[i].gameObject.layer = LayerMask.NameToLayer("UIModel")
    end
    modelTrans:SetParent(cameraGo.transform)
    modelTrans.localScale = Vector3.one
    modelTrans.localPosition = Vector3(0, 0, 20)
    modelTrans.localRotation = Vector3(0, 180, 0)
end

-- function CacheNpcTpose:GetMeshNode()
--     return self.meshNodecsdn 没落
-- end

-- function CacheNpcTpose:GetAutoReleaser()
--     return self.autoReleaser
-- end

-- function CacheNpcTpose:GetAnimation()
--     if not self.animation then
--         self.animation = self.obj:GetComponent(Animation)
--     end
--     return self.animation
-- end

-- function CacheNpcTpose:SetNewSkin(resData, assetLoader)
--     self.obj.name = "tpose"
--     self.resData = resData

--     self.autoReleaser = self.obj:GetComponent(AssetAutoReleaser)
--     local skinPath = resData.skinPath
--     local skin = assetLoader:Pop(skinPath)
--     self.meshNode = self:GetTransform():Find("Mesh_body")
--     self.renderer = self.meshNode:GetComponent(Renderer)
--     self.texture_id = Shader.PropertyToID("_MainTex")
--     self.material_block = MaterialPropertyBlock()
--     self.renderer:GetPropertyBlock(self.material_block)
--     self.material_block:SetTexture(self.texture_id,skin)
--     self.renderer:SetPropertyBlock(self.material_block)

--     self.autoReleaser:Add(resData.skinPath)
--     AssetMgrProxy.Instance:IncreaseReferenceCount(resData.skinPath)
-- end

-- function CacheNpcTpose:SetNewSkinAndDelOldSkin(resData, assetLoader)
--     local skin = assetLoader:Pop(resData.skinPath)
--     local lastSkinPath = self.resData.skinPath
--     local setSkinPath = resData.skinPath

--     if lastSkinPath ~= setSkinPath then
--         self.autoReleaser:RemovePath(lastSkinPath)
--         AssetMgrProxy.Instance:DecreaseReferenceCount(lastSkinPath)
--         AssetMgrProxy.Instance:IncreaseReferenceCount(setSkinPath)
--         self.autoReleaser:Add(setSkinPath)
--         if UtilsBase.IsNull(self.material_block) then
--             self.texture_id = Shader.PropertyToID("_MainTex")
--             self.material_block = MaterialPropertyBlock()
--         end
--         self.material_block:SetTexture(self.texture_id, skin)
--         self.renderer:SetPropertyBlock(self.material_block)
--     end
--     self.resData = resData
-- end

-- function CacheNpcTpose:_getTextureMaterial()

--     if not self.renderer then
--         return
--     end

--     if not self.material then
--         self.material = self.renderer.material
--     end
--     return self.material
-- end


-- -- Npc Loader
-- -- 所有NPC的创建都通过这个方法
-- -- @huangyq
-- NpcTposeLoader = NpcTposeLoader or BaseClass()

-- local _string_format = string.format

-- function NpcTposeLoader:__init(setting, callback)
--     self.setting = setting
--     self.fullanimation = setting.fullanimation == true
--     self.animationWhiteList = setting.animationWhiteList
--     self.callback = callback
--     self.assetLoader = nil
--     -- 是否中途取消
--     self.cancel = false
--     self.tpose = nil
--     self.cacheTpose = nil

--     -- 这个结构跟以后的分包时取代替资源有关系
--     self.resData = {
--         skinId = setting.skinId
--         ,modelId = setting.modelId
--         ,motionId = setting.animationId
--         ,animationData = nil
--         ,fullanimation = self.fullanimation

--         ,skinPath = ""
--         ,modelPath = ""
--         ,animPathList = {}
--         ,defaultclips = {}
--         ,animationWhiteList = self.animationWhiteList
--     }

--     local baseData = Config.DataAnimation.data_npc[self.resData.motionId]
--     self.resData.animationData = baseData
--     if baseData == nil then
--         LogError("缺少AnimationData信息(animation_data表)[motionId:" .. self.resData.motionId .. ", skinId:" .. self.resData.skinId .. " , modelId:" .. self.resData.modelId .. "]\n"..debug.force_traceback())
--         return
--     end
--     local list
--     if self.fullanimation then
--         list = AnimationManager.Instance:FormatList(baseData)
--     else
--         if self.animationWhiteList then
--             list = self.animationWhiteList
--         else
--             list = AnimationManager.Instance:GetNecessaryList(baseData)
--         end
--     end
--     self.resData.skinPath = _string_format("Unit/Npc/Skin/%s.TGA", self.resData.skinId)
--     self.resData.modelPath = UnitModelQuality.GetNpcPath(self.resData.modelId)
--     for _, animationId in ipairs(list) do
--         self.resData.defaultclips[animationId] = animationId
--         table.insert(self.resData.animPathList, _string_format("Unit/Npc/Animation/%s/%s.anim", baseData.controller_id, animationId))
--     end
-- end

-- function NpcTposeLoader:__delete()
--     self:ChangeRoleTposeShaderByName("Xcqy/UnlitTexture")
--     self:ReturnLoadAsset()
--     self:DeleteAssetLoader()
-- end

-- function NpcTposeLoader:Load()
--     self.cancel = false
--     local subResources = SubpackageManager.Instance:NpcResources(self.resData)
--     self.cacheTpose = GoPoolManager.Instance:BorrowCache(self.resData.modelPath, GoPoolType.Npc)
--     if self.cacheTpose ~= nil then
--         SubpackageManager.Instance:RemoveByFile(subResources, self.resData.modelPath)
--     end

--     local callback = function()
--         if self.cancel then
--             self:DeleteAssetLoader()
--         else
--             self:BuildTpose()
--         end
--     end
--     self.assetLoader = AssetBatchLoader.New("NpcTposeLoader[" .. self.resData.modelId .. "]");
--     self.assetLoader:AddListener(callback)
--     -- UtilsBase.dump(subResources, "===============subResources")
--     self.assetLoader:LoadAll(subResources)
-- end

-- function NpcTposeLoader:Cancel()
--     self.cancel = true
--     self:ReturnLoadAsset()
-- end

-- function NpcTposeLoader:BuildTpose()
--     if self.assetLoader == nil then
--         return
--     end
--     if self.cacheTpose == nil then
--         self.tpose = self.assetLoader:Pop(self.resData.modelPath)
--         self.cacheTpose = GoPoolManager.Instance:CreateCache(self.tpose, self.resData.modelPath, GoPoolType.Npc)
--         self.cacheTpose:SetNewSkin(self.resData, self.assetLoader)
--     else
--         self.tpose = self.cacheTpose:GetObj()
--         self.cacheTpose:SetNewSkinAndDelOldSkin(self.resData, self.assetLoader)
--     end
--     self.tpose:SetActive(true)

--     local animation = self.cacheTpose:GetAnimation()
--     local autoReleaser = self.cacheTpose:GetAutoReleaser()
--     local clip = nil
--     local defaultClip = self.resData.animationData.stand_id
--     if defaultClip == "" then
--         defaultClip = self.resData.animationData.idle_id
--     end
--     for _, path in ipairs(self.resData.animPathList) do
--         clip = self.assetLoader:Pop(path)
--         if clip ~= nil then
--             local clipname = clip.name
--             if animation:getItem(clipname) == nil then
--                 animation:AddClip(clip, clipname)
--                 autoReleaser:Add(path)
--                 AssetMgrProxy.Instance:IncreaseReferenceCount(path)
--             end
--         else
--             LogError(string.format("动作资源不存在%s",path))
--         end
--     end
--     animation:Play(defaultClip)
--     local meshNode = self.cacheTpose:GetMeshNode()
--     if self.callback ~= nil then
--         self.callback({tpose = self.tpose, animation = animation, animationData = self.resData.animationData, meshNode = meshNode, modelPath = self.resData.modelPath, defaultclips = self.resData.defaultclips})
--     end
--     self:DeleteAssetLoader()
-- end

-- function NpcTposeLoader:ChangeAlphaShader()
--     if self.cacheTpose then
--         self.cacheTpose:ChangeAlphaShader()
--     end
-- end

-- function NpcTposeLoader:ChangeNormalShader(isSelf)
--     if self.cacheTpose then
--         self.cacheTpose:ChangeNormalShader(isSelf)
--     end
-- end

-- function NpcTposeLoader:ChangeRoleTposeShaderByShader(shader)
--     if self.cacheTpose then
--         self.cacheTpose:ChangeShaderByShader(shaderName)
--     end
-- end

-- function NpcTposeLoader:ChangeRoleTposeShaderByName(shaderName)
--     if self.cacheTpose then
--         self.cacheTpose:ChangeShaderByName(shaderName)
--     end
-- end

-- function NpcTposeLoader:ChangeHeadTposeShaderByShader(shader)
-- end

-- function NpcTposeLoader:ChangeHeadTposeShaderByName(shaderName)
-- end

-- function NpcTposeLoader:ChangeRimLight(rimcolor, power, strength, alpha)
--     if self.cacheTpose then
--         self.cacheTpose:ChangeRimLight(rimcolor, power, strength, alpha)
--     end
-- end

-- function NpcTposeLoader:GetTposeCache()
--     return self.cacheTpose
-- end

-- function NpcTposeLoader:DeleteAssetLoader()
--     if self.assetLoader ~= nil then
--         self.assetLoader:DeleteMe()
--         self.assetLoader = nil
--     end
-- end

-- function NpcTposeLoader:ReturnLoadAsset()
--     if self.cacheTpose ~= nil then
--         GoPoolManager.Instance:ReturnCache(self.cacheTpose, self.resData.modelPath, GoPoolType.Npc)
--         self.cacheTpose = nil
--     end
-- end
