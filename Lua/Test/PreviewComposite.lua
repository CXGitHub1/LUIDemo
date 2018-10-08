-- 模型预览组合件
PreviewComposite = PreviewComposite or BaseClass()

function PreviewComposite:__init(callback, setting, modelData)
    self.callback = callback
    self.setting = setting
    self.modelData = modelData

    self.name = setting.name or "Unknown"
    self.width = setting.width or 256
    self.height= setting.height or 256
    self.offsetX = setting.offsetX or 0
    self.offsetY = setting.offsetY or 0
    self.offsetZ = setting.offsetZ or 0
    self.noDrag = setting.noDrag or false
    self.noMaterial = setting.noMaterial or false
    self.loadType = AssetLoadType.BothSync
    if setting.loadType ~= nil then
        self.loadType = setting.loadType
    end
    self.rotate = setting.localRot or Vector3(0, 180, 0)

    self.fadeTime = 0.1
    self.tpose = nil
    self.animationData = nil
    self.headAnimationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.animator = nil
    self.cachemotion = nil --缓存动作，等待加载完播放

    self.loader = nil

    self.nextX = PreviewManager.Instance:NextX()
    self.lastPostion = Vector3(0, 0, 0)
    -- print("__init")
    self:BuildTpose(false)
end

function PreviewComposite:__delete()
    if self.render ~= nil then
        self.render:Release()
        RenderTexture.Destroy (self.render)
        self.render = nil
    end
    if self.rawImage ~= nil then
        GameObject.Destroy(self.rawImage)
        self.rawImage = nil
    end
    if self.cameraObj ~= nil then
        GameObject.Destroy(self.cameraObj)
        self.cameraObj = nil
    end

    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end

    self.callback = nil
    self.setting = nil
    self.modelData = nil
    self.animationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.lastPostion = nil
end

function PreviewComposite:BuildTpose(IsReLoad)
    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end
    self.tpose = nil
    self.animator = nil
    if self.modelData.type == PreViewType.Npc then
        local callback = function(result)
            self:OnNpcLoaded(result, IsReLoad)
        end
        self.loader = NpcTposeLoader.New({skinId = self.modelData.skinId, modelId = self.modelData.modelId, animationId = self.modelData.animationId, scale = self.modelData.scale, fullanimation = true}, callback)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Role then
        local transform_data = nil
        if self.modelData.isTransform then -- 是否显示变身效果
            -- for k,v in pairs(self.modelData.looks) do
                -- if v.looks_type == SceneConstData.looktype_transform then -- 变身
                --     print("SceneConstData.looktype_transform")
                --     transform_data = DataTransform.data_transform[v.looks_val]
                --     if transform_data == nil then
                --         print(string.format("不存在的变身id %s", v.looks_val))
                --         return
                --     end
                -- end
            -- end
        end

        if transform_data ~= nil then -- 有变身效果
            local callback = function(newTpose, animationData)
                self:OnNpcLoaded(newTpose, animationData, IsReLoad)
            end
            self.loader = NpcTposeLoader.New({skinId = transform_data.skin, modelId = transform_data.res, animationId = transform_data.animation_id, scale = self.modelData.scale, fullanimation = true}, callback)
            self.loader:Load()
        else -- 无变身效果
            local callback = function(data)
                self:OnRoleLoaded(data.tpose, data.animation, data.animationData, data.headTpose, data.animationHead, data.animationDataHead, IsReLoad)
            end
            local callback1 = function()
                Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
            end
            local setting = {classes = self.modelData.classes, sex = self.modelData.sex, looks = self.modelData.looks, loadType = self.loadType, forceHeight = true}
            self.loader = MixRoleTposeLoader.New(setting, callback, callback1)
            self.loader:Load()
        end
    elseif self.modelData.type == PreViewType.Pet then
        local callback = function(newTpose, animationData, headTpose, headAnimationData)
            self.headAnimationData = headAnimationData
            self:OnNpcLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = NpcTposeLoader.New({skinId = self.modelData.skinId, modelId = self.modelData.modelId, animationId = self.modelData.animationId, scale = self.modelData.scale, fullanimation = true}, callback)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Wings then
        local callback = function (newTpose, animationData)
            self:OnWingsLoaded(newTpose, animationData, IsReLoad)
        end
        -- 翅膀加载 先采用特效加载

        if WingConfigHelper.IsEffect(self.modelData.looks:WingVal()) then
            self.loader = WingEffectLoader.New(self.modelData.looks, callback, "UI")
        else
            self.loader = WingTposeLoader.New(self.modelData.looks, callback, "ModelPreview")
        end
        -- self.loader = WingEffectLoader.New(self.modelData.looks, callback, "UI")
    elseif self.modelData.type == PreViewType.Ride then
        local callback = function(newTpose, animationData)
            self:OnRideLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = RideTposeLoader.New(self.modelData.classes, self.modelData.sex, self.modelData.looks, callback)
    elseif self.modelData.type == PreViewType.Weapon then
        local callback = function (newTpose, animationData)
            self:OnWeaponLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = WeaponTposeLoader.New(self.modelData.classes, self.modelData.sex,self.modelData.looks, callback)
    end
end

function PreviewComposite:OnNpcLoaded(result, IsReLoad)
    self.tpose = result.tpose
    self.animation = result.animation
    self.animationData = result.animationData
    self.animation.cullingType = AnimationCullingType.AlwaysAnimate
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    self.tpose.transform.localRotation = self.rotate
    self:BuildCamera()

    if self.modelData ~= nil and self.modelData.effects ~= nil then
        local callback = function() Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview") end
    end

    if self.callback ~= nil then
        self.callback(self)
    end
    if self.cachemotion ~= nil then
        self:PlayAnimation(self.cachemotion)
        self.cachemotion = nil
    end
end

-- 回调函数可能还有其它字段，用到就加上去
function PreviewComposite:OnRoleLoaded(newTpose, animation, animationData, headTpose, animationHead, animationDataHead, IsReLoad)
    self.tpose = newTpose
    self.animation = animation
    self.animation.cullingType = AnimationCullingType.AlwaysAnimate
    self.animationData = animationData

    self.headTpose = headTpose
    self.animationHead = animationHead
    self.animationHead.cullingType = AnimationCullingType.AlwaysAnimate
    self.animationDataHead = animationDataHead

    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    -- self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, self.offsetZ)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(Vector3(0, 180, 0))

    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    end
    -- if not IsReLoad then
        self:BuildCamera()
    -- end
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:OnWingsLoaded(newTpose, animationData, IsReLoad)
    self.tpose = newTpose
    self.animationData = animationData
    -- self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    -- if not IsReLoad then
        self:BuildCamera()
    -- end
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:OnWeaponLoaded(newTpose1, newTpose2)
    self.tpose = newTpose1
    -- self.tpose.name = "PreviewTpose1_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)

    self:BuildCamera()
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")

    if self.modelData.classes == RoleEumn.Classes.Sword then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX - 0.15, self.offsetY - 0.1, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(310, 90, 90))

        if newTpose2 ~= nil then
            self.tpose_2 = newTpose2
            -- self.tpose_2.name = "PreviewTpose2_" .. self.name
            self.tpose_2.transform:SetParent(PreviewManager.Instance.container.transform)
            self.tpose_2.transform.position = Vector3(self.nextX + self.offsetX + 0.15, self.offsetY - 0.1, 0)

            Utils.ChangeLayersRecursively(self.tpose_2.transform, "ModelPreview")

            self.tpose_2.transform.localRotation = Quaternion.identity
            self.tpose_2.transform:Rotate(Vector3(310, -90, 90))
        end
    elseif self.modelData.classes == RoleEumn.Classes.Mage then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX - 0.1, self.offsetY, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(300, 90, 0))
    elseif self.modelData.classes == RoleEumn.Classes.Holy then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY + 0.1, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(0, 0, 90))
    elseif self.modelData.classes == RoleEumn.Classes.Gunner then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX - 0.1, self.offsetY, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(0, 0, 90))
    elseif self.modelData.classes == RoleEumn.Classes.Piano then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY + 0.1, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(0, 200, 0))
    elseif self.modelData.classes == RoleEumn.Classes.Knight then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY + 0.1, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3.zero)
    end

    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:OnRideLoaded(newTpose, animationData, IsReLoad)
    self.tpose = newTpose
    self.animationData = animationData
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    if not IsReLoad then
        self:BuildCamera()
    end

    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    end

    if self.modelData ~= nil and self.modelData.effects ~= nil then
        local callback = function() Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview") end
    end

    if self.callback ~= nil then
        self.callback(self)
    end

    if self.cachemotion ~= nil then
        self:PlayAnimation(self.cachemotion)
        self.cachemotion = nil
    end
end

function PreviewComposite:BuildCamera(doCheck)
    if (not doCheck and UtilsBase.IsNull(self.tpose)) or not UtilsBase.IsNull(self.cameraObj) then
        return
    end

    self.cameraObj = GameObject("PreviewCamera_" .. self.name)
    local camera = self.cameraObj:AddComponent(Camera)
    camera.orthographic = false
    camera.backgroundColor = Color(0,0,0,0)
    camera.clearFlags = CameraClearFlags.Color;
    camera.fieldOfView = 45
    camera.depth = 1;
    camera.nearClipPlane = 0.01;
    camera.farClipPlane = 10
    camera.cullingMask = SettingManager.GetLayerMaskVal("ModelPreview")
    self.cameraObj.transform:SetParent(PreviewManager.Instance.container.transform)
    self.cameraObj.transform.position = Vector3(self.nextX, 0, -5)
    self.cameraObj.transform:Rotate(Vector3(5, 0, 0))

    self.rawImage = GameObject("PreviewRawImage_" .. self.name)
    self.rawImage:AddComponent(RectTransform).sizeDelta = Vector2(self.width, self.height)
    local raw = self.rawImage:AddComponent(RawImage)
    -- self.render = RenderTexture.GetTemporary(self.width, self.height, 24)
    self.render = RenderTexture.GetTemporary(self.width * 1.5, self.height * 1.5, 24)
    raw.texture = self.render
    if not self.noMaterial then
        local shader = ShaderManager.Instance:GetShader( "Xcqy/ParticlesAlphaBlended")
        raw.material = Material(shader)
    end
    camera.targetTexture = self.render

    -- 不需要拖动
    if self.setting ~= nil and not self.setting.noDrag then
        local dragBehaviour = self.rawImage:AddComponent(UIDragBehaviour)
        local onBeginDrag = function(data)
            self.lastPostion = data.position
        end
        dragBehaviour.onBeginDrag= {"+=", onBeginDrag}
        local cbOnDrag = function(data)
            self:OnTposeDrag(data)
        end
        dragBehaviour.onDrag = {"+=", cbOnDrag}
    end
end

-- 界面隐藏的时候在隐藏预览内容
function PreviewComposite:Hide()
    if not UtilsBase.IsNull(self.tpose) then
        self.tpose:SetActive(false)
    end
    if not UtilsBase.IsNull(self.tpose_2) then
        self.tpose_2:SetActive(false)
    end
    if not UtilsBase.IsNull(self.cameraObj) then
        self.cameraObj:SetActive(false)
    end
    -- if self.tpose ~= nil then
    --     self.tpose:SetActive(false)
    -- end
    -- if self.cameraObj ~= nil then
    --     self.cameraObj:SetActive(false)
    -- end
end

function PreviewComposite:HideCameraOnly()
    if not UtilsBase.IsNull(self.cameraObj) then
        self.cameraObj:SetActive(false)
    end
end

function PreviewComposite:Show()
    if not UtilsBase.IsNull(self.tpose) then
        self.tpose:SetActive(true)
    end
    if not UtilsBase.IsNull(self.tpose_2) then
        self.tpose_2:SetActive(true)
    end
    if not UtilsBase.IsNull(self.cameraObj) then
        self.cameraObj:SetActive(true)
    end
    -- if self.tpose ~= nil then
    --     self.tpose:SetActive(true)
    -- end
    -- if self.cameraObj ~= nil then
    --     self.cameraObj:SetActive(true)
    -- end
end

function PreviewComposite:OnTposeDrag(eventData)
    local offset = self.lastPostion.x - eventData.position.x
    self.lastPostion = eventData.position
    if not UtilsBase.IsNull(self.tpose) then
        self.tpose.transform:Rotate(Vector3.up, offset / self.width * 120)
    end
    if not UtilsBase.IsNull(self.tpose_2) then
        self.tpose_2.transform:Rotate(Vector3.up, offset / self.width * 120)
    end
end

function PreviewComposite:Reload(modelData, callback)
    self.callback = callback
    self.modelData = modelData
    self:BuildTpose(true)
end

function PreviewComposite:testFun()
    -- self.headAnimator = self.loader.headTpose:GetComponent(Animator)

    -- self.headAnimator:Play(self.loader.headAnimationData.stand_id)

    -- local path = BaseUtils.GetChildPath(self.loader.roleTpose.transform, "Bip_Head")
    -- local mounter = self.loader.roleTpose.transform:Find(path)
    local headTran = self.loader.headTpose.transform
    -- headTran:SetParent(mounter)
    -- headTran.localPosition = Vector3(0, 0, 0)
    -- headTran.localScale = Vector3(1, 1, 1)
    -- headTran.localRotation = Quaternion.identity
    -- headTran:Rotate(Vector3(90, 0, 0))

    -- TimerManager.Add(1000, function()
        headTran.localPosition = Vector3(100, 100, 0)
    -- end)

    TimerManager.Add(100, function()
        headTran.localPosition = Vector3(0, 0, 0)
    end)
    -- self.loader.headTpose
end

function PreviewComposite:PlayMotion(action)
    if self.animator == nil then
        self.animator = self.tpose:GetComponent(animation)
    end
    if self.animator ~= nil then
        if self.modelData.type == PreViewType.Role then
            self:RolePlayAction(action)
        else
            self:NpcPlayAction(action)
        end
    end
end

function PreviewComposite:PlayAnimation(name)
    if UtilsBase.IsNull(self.tpose) then
        return
    end
    if self.animation == nil then
        self.animation = self.tpose:GetComponent(Animation)
    end
    if self.animation ~= nil then
        self.animation:Play(name)
    end
end

function PreviewComposite:PlayAnimations(animations)
    if UtilsBase.IsNull(self.tpose) then
        return
    end
    if self.animation == nil then
        self.animation = self.tpose:GetComponent(Animation)
    end
    if self.animation ~= nil then
        for i,name in ipairs(animations) do
            if i == 1 then
                if self.animation:getItem(name) == nil then
                    LogError("PreviewComposite播放未加载的动作，PlayAnimations1")
                end
                self.animation:CrossFadeQueued(name, self.fadeTime, QueueMode.PlayNow)
            else
                if self.animation:getItem(name) == nil then
                    LogError("PreviewComposite播放未加载的动作，PlayAnimations1")
                end
                self.animation:CrossFadeQueued(name, self.fadeTime, QueueMode.CompleteOthers)
            end
        end
    end
end

function PreviewComposite:PlayAction(action)
    if UtilsBase.IsNull(self.animation) then
        return
    end
    if action == SceneEumn.UnitAction.Stand then
        self.animation:CrossFade(self.animationData.stand_id, self.fadeTime)
        if not UtilsBase.IsNull(self.animationHead) and self.animationDataHead.stand_id ~= "" then
            self.animationHead:CrossFade(self.animationDataHead.stand_id, self.fadeTime)
        end
    elseif action == SceneEumn.UnitAction.Move then
        self.animation:CrossFade(self.animationData.move_id, self.fadeTime)
        if not UtilsBase.IsNull(self.animationHead) and self.animationDataHead.move_id ~= "" then
            self.animationHead:CrossFade(self.animationDataHead.move_id, self.fadeTime)
        end
    end
end
