-- 模型预览组合件(没有renderTexture)
PreviewmodelComposite = PreviewmodelComposite or BaseClass()

function PreviewmodelComposite:__init(callback, setting, modelData)
    self.callback = callback
    self.setting = setting
    self.modelData = modelData

    self.name = setting.name or "Unknown"
    self.fadeTime = 0.1 -- 过渡动作过渡时间
    self.sortingOrder = setting.sortingOrder ~= nil and setting.sortingOrder or nil
    self.parent = setting.parent
    if setting.usemask then
        if setting.usemask == true then
            self.usemask = 1
        else
            self.usemask = setting.usemask
        end
    end
    self.localPos = setting.localPos or Vector3(0, 0, -500)
    self.localRot = setting.localRot or Vector3(0, 180, 0)
    self.noDrag = setting.noDrag or false
    self.usePerspective = setting.usePerspective or false
    self.layer = setting.layer or "UI"
    if self.usePerspective then
        self.layer = "ModelPreview"
        PreviewManager.Instance:OpenPerspCam()
    end
    self.loadType = AssetLoadType.BothSync
    if setting.loadType ~= nil then
        self.loadType = setting.loadType
    end
    self.animationWhiteList = setting.animationWhiteList or {}

    self.tpose = nil
    self.animationData = nil
    self.headAnimationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.animator = nil
    self.cachemotion = nil --缓存动作，等待加载完播放

    self.isshow = false

    self.loader = nil

    self.nextX = PreviewManager.Instance:NextX()
    self.lastPostion = Vector3(0, 0, 0)
    self.reloadpreview = function()
        self:ReloadPreview()
    end
    -- 不需要拖动
    if self.setting ~= nil and not self.setting.noDrag then
        local parentgo = self.parent.gameObject
        local dragBehaviour = parentgo:GetComponent(UIDragBehaviour) or parentgo:AddComponent(UIDragBehaviour)
        dragBehaviour.onBeginDrag = function(data)
            self.lastPostion = data.position
        end
        dragBehaviour.onDrag = function(data)
            self:OnTposeDrag(data)
        end
    end

    if IS_DEBUG then
        PreviewManager.Instance:Add(self)
        PreviewManager.Instance:CheckRelease()
    end

    self:BuildTpose(false)
end

function PreviewmodelComposite:__delete()
    if IS_DEBUG then
        PreviewManager.Instance:Release(self)
    end
    if self.usePerspective then
        PreviewManager.Instance:ClosePerspCam()
    end
    if self.textId ~= nil then
        TimerManager.Delete(self.textId)
    end

    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
        self.tpose = nil
    end

    self.callback = nil
    self.setting = nil
    self.modelData = nil
    self.animationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.lastPostion = nil
    UtilsBase.TimerDelete(self, "repeatTimerId")
end

function PreviewmodelComposite:OpenDrag(bool)
    if bool then
    else
    end
end

function PreviewmodelComposite:BuildTpose(IsReLoad)
    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
        self.tpose = nil
    end
    if self.modelData.type == PreViewType.Npc and self.modelData.classes ~= nil and self.modelData.classes ~= 0 then
        local callback = function(data)
            self:OnRoleLoaded(data.tpose, data.animation, data.animationData, data.headTpose, data.animationHead, data.animationDataHead, IsReLoad)
        end
        local callback1 = function()
            local renders = self.tpose.transform:GetComponentsInChildren(Renderer, true)
            local maskshader = ShaderManager.Instance:GetShader("Xcqy/UnlitTextureMask")

            if self.sortingOrder ~= nil then
                for t in Slua.iter(renders) do
                    t.sortingOrder = self.sortingOrder
                end
            end
            if self.usemask then
                Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
                -- local effectmaskshader = ShaderManager.Instance:GetShader("Xcqy/ParticleMask")
                -- for t in Slua.iter(renders) do
                --     if string.find(t.material.shader.name, "Particle") then
                --         t.material.shader = effectmaskshader
                --         t.material:SetInt(SettingManager.GetShaderProID("_Stencil"), self.usemask);
                --     else
                --         t.material.shader = maskshader
                --         t.material:SetInt(SettingManager.GetShaderProID("_Stencil"), self.usemask);
                --     end
                -- end
            else
                Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
            end
            if self.setting.allCompleteCallback ~= nil then
                self.setting.allCompleteCallback()
            end
        end
        local setting = {classes = self.modelData.classes, sex = self.modelData.sex, looks = self.modelData.looks, isSelf = self.setting.isSelf}
        setting.layer = self.layer
        if self.modelData.classes ~= nil and self.modelData.classes ~= 0 then
            setting.forceHeight = true
        end
        self.loader = MixRoleTposeLoader.New(setting, callback, callback1)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Npc then
        local callback = function(result)
            self:OnNpcLoaded(result)
        end
        self.loader = NpcTposeLoader.New({skinId = self.modelData.skinId, modelId = self.modelData.modelId, animationId = self.modelData.animationId, scale = self.modelData.scale, fullanimation = #self.animationWhiteList == 0, animationWhiteList = self.animationWhiteList}, callback)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Mount then
        local callback = function(result)
            self:OnNpcLoaded(result)
        end
        local setting = MountTposeLoaderSetting.New(self.modelData.modelId, self.modelData.skinId, self.modelData.animationId, self.modelData.effectIdList, callback)
        setting.fullanimation = true
        self.loader = MountTposeLoader.New(setting)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Shouhu then
        local callback = function(result, animationData)
            self:OnNpcLoaded(result, animationData, IsReLoad)
        end
        self.loader = NpcTposeLoader.New({skinId = self.modelData.skinId, modelId = self.modelData.modelId, animationId = self.modelData.animationId, scale = self.modelData.scale, fullanimation = #self.animationWhiteList == 0, animationWhiteList = self.animationWhiteList}, callback)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Role then
        local transform_data = nil
        if transform_data ~= nil then -- 有变身效果
            local callback = function(newTpose, animationData)
                self:OnNpcLoaded(newTpose, animationData, IsReLoad)
            end
            self.loader = NpcTposeLoader.New({skinId = transform_data.skin, modelId = transform_data.res, animationId = transform_data.animation_id, scale = 1, animationWhiteList = self.animationWhiteList}, callback)
            self.loader:Load()
        else -- 无变身效果
            local callback = function(data)
                self:OnRoleLoaded(data.tpose, data.animation, data.animationData, data.headTpose, data.animationHead, data.animationDataHead, IsReLoad)
            end
            local callback1 = function()
                if self.usemask then
                    UtilsBase.ChangeEffectMaskShader(self.tpose, self.sortingOrder, "UI")
                else
                    local renders = self.tpose.transform:GetComponentsInChildren(Renderer, true)
                    if self.sortingOrder ~= nil then
                        for t in Slua.iter(renders) do
                            t.sortingOrder = self.sortingOrder
                        end
                    end
                    Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
                end
                if self.setting.allCompleteCallback ~= nil then
                    self.setting.allCompleteCallback()
                end
            end
            local setting = {classes = self.modelData.classes, sex = self.modelData.sex, looks = self.modelData.looks, noWing = self.modelData.noWing, loadType = self.loadType, fullanimation = #self.animationWhiteList == 0, animationWhiteList = self.animationWhiteList, forceHeight = true}
            setting.layer = self.layer
            setting.isSelf = self.setting.isSelf
            self.loader = MixRoleTposeLoader.New(setting, callback, callback1)
            self.loader:Load()
        end
    elseif self.modelData.type == PreViewType.Pet then
        local callback = function(newTpose, animationData, headTpose, headAnimationData)
            self.headAnimationData = headAnimationData
            self:OnNpcLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = NpcTposeLoader.New({skinId = self.modelData.skinId, modelId = self.modelData.modelId, animationId = self.modelData.animationId, scale = self.modelData.scale, fullanimation = #self.animationWhiteList == 0, animationWhiteList = self.animationWhiteList}, callback)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Wings then
        local callback = function (result)
            self:OnNpcLoaded(result, nil, IsReLoad)
        end
        if WingConfigHelper.IsEffect(self.modelData.looks:WingVal()) then
            self.loader = WingEffectLoader.New(self.modelData.looks, callback, "UI")
        else
            self.loader = WingTposeLoader.New(self.modelData.looks, callback, "UI")
        end
        self.loader:Load()
    elseif self.modelData.type == PreViewType.Weapon then
        local callback = function (newTpose, animationData)
            self:OnWeaponLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = WeaponTposeLoader.New(self.modelData, callback)
        self.loader:Load()
    elseif self.modelData.type == PreViewType.RoleOnMount then
        local callback = function(result)
            self:OnNpcLoaded(result)
        end
        self.loader = RoleOnMountTposeLoader.New(self.setting, self.modelData , callback)
        self.loader:Load()
    end
end

function PreviewmodelComposite:OnNpcLoaded(result, animationData, IsReLoad)
    self.tpose = result.tpose
    self.animationData = result.animationData
    self.animation = result.animation
    Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    -- if self.usemask then
    --  Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    -- else
    --  Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
    -- end
    -- if self.modelData ~= nil and self.modelData.scale ~= nil then
    --  self.tpose.transform.localScale = Vector3.one*self.modelData.scale
    -- end

    -- self.tpose.name = "PreviewTpose_" .. self.name
    -- self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(self.localRot)

    -- print(IsReLoad)
    -- print("是不是？？？？")
    -- if not IsReLoad then
        self:BindModel()
    -- end
    self.isshow = true
    if self.callback ~= nil then
        self.callback(self)
    end
    if self.cachemotion ~= nil then
        self:PlayAnimation(self.cachemotion)
        self.cachemotion = nil
    end
end

function PreviewmodelComposite:OnWeaponLoaded(result, animationData, IsReLoad)
    self.tpose = result.weapon
    Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    -- if self.usemask then
    --  Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    -- else
    --  Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
    -- end
    -- if self.modelData ~= nil and self.modelData.scale ~= nil then
    --  self.tpose.transform.localScale = Vector3.one*self.modelData.scale
    -- end

    -- self.tpose.name = "PreviewTpose_" .. self.name
    -- self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(self.localRot)

    -- print(IsReLoad)
    -- print("是不是？？？？")
    -- if not IsReLoad then
        self:BindModel()
    -- end
    self.isshow = true
    if self.callback ~= nil then
        self.callback(self)
    end
end

-- 回调函数可能还有其它字段，用到就加上去
function PreviewmodelComposite:OnRoleLoaded(newTpose, animation, animationData, headTpose, animationHead, animationDataHead, IsReLoad)
    self.tpose = newTpose
    self.animation = animation
    self.animation.cullingType = AnimationCullingType.AlwaysAnimate
    self.animationData = animationData

    self.headTpose = headTpose
    self.animationHead = animationHead
    if self.animationHead then
        self.animationHead.cullingType = AnimationCullingType.AlwaysAnimate
    end
    self.animationDataHead = animationDataHead

    Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    -- if self.usemask then
    --  Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    -- else
    --  Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
    -- end
    -- self.tpose.name = "PreviewTpose_" .. self.name
    -- self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(self.localRot)
    -- if self.modelData ~= nil and self.modelData.scale ~= nil then
    --  self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    -- end
    -- if not IsReLoad then
        self:BindModel()
    -- end
    if self.callback ~= nil then
        self.callback(self)
    end
end


function PreviewmodelComposite:BindModel(doCheck)
    if (not doCheck and UtilsBase.IsNull(self.tpose)) or not UtilsBase.IsNull(self.cameraObj) then
        return
    end
    local renders = self.tpose.transform:GetComponentsInChildren(Renderer, true)
    local meshrenders = self.tpose.transform:GetComponentsInChildren(MeshRenderer, true)
    if self.sortingOrder ~= nil then
        for t in Slua.iter(renders) do
            t.sortingOrder = self.sortingOrder
        end
        for t in Slua.iter(meshrenders) do
            t.sortingOrder = self.sortingOrder
        end
    end
    if self.usemask then
        -- local maskshader = ShaderManager.Instance:GetShader( "Xcqy/UnlitTransparentMask")
        local maskshader = ShaderManager.Instance:GetShader( "Xcqy/UnlitTextureMask")
        for t in Slua.iter(renders) do
            t.material.shader = maskshader
            t.material:SetInt(SettingManager.GetShaderProID("_Stencil"), self.usemask);
        end
        for t in Slua.iter(meshrenders) do
            t.material.shader = maskshader
            t.material:SetInt(SettingManager.GetShaderProID("_Stencil"), self.usemask);
        end
    end
    if self.parent ~= nil then
        self.tpose.transform:SetParent(self.parent)
        self.tpose.transform.localPosition = self.localPos
        if self.modelData ~= nil and self.modelData.scale ~= nil then
            --  202是1280标准尺寸的 场景元素放到UI的默认缩放值
            self.tpose.transform.localScale = Vector3.one * 202 * self.modelData.scale
        end
    end
end

-- 界面隐藏的时候在隐藏预览内容
function PreviewmodelComposite:Hide()
    self.isshow = false
    if not UtilsBase.IsNull(self.tpose) then
        self.tpose:SetActive(false)
    end
    if not UtilsBase.IsNull(self.tpose_2) then
        self.tpose_2:SetActive(false)
    end
    if not UtilsBase.IsNull(self.cameraObj) then
        self.cameraObj:SetActive(false)
    end
end

function PreviewmodelComposite:Show()
    self.isshow = true
    if not UtilsBase.IsNull(self.tpose) then
        self.tpose:SetActive(true)
    end
    if not UtilsBase.IsNull(self.tpose_2) then
        self.tpose_2:SetActive(true)
    end
    if not UtilsBase.IsNull(self.cameraObj) then
        self.cameraObj:SetActive(true)
    end
    if self.animation then
        self.animation.cullingType = AnimationCullingType.BasedOnRenderers
    end
    if self.animationHead then
        self.animationHead.cullingType = AnimationCullingType.BasedOnRenderers
    end
    self:PlayAction(SceneEumn.UnitAction.Stand)
    if self.animation then
        self.animation.cullingType = AnimationCullingType.AlwaysAnimate
    end
    if self.animationHead then
        self.animationHead.cullingType = AnimationCullingType.AlwaysAnimate
    end
end

function PreviewmodelComposite:OnTposeDrag(eventData)
    local offset = self.lastPostion.x - eventData.position.x
    self.lastPostion = eventData.position
    local width = 200
    if not UtilsBase.IsNull(self.tpose) then
        self.tpose.transform:Rotate(Vector3.up, offset / width * 120)
    end
    if not UtilsBase.IsNull(self.tpose_2) then
        self.tpose_2.transform:Rotate(Vector3.up, offset / width * 120)
    end
end

function PreviewmodelComposite:Reload(modelData, callback, setting)
    self.callback = callback
    if modelData.type == PreViewType.Role then
        local newlist = {}
        local parten = "(%a*)(%d)(%d)(%d+)"
        for k,v in pairs(self.animationWhiteList) do
            for name, _, __, id in string.gmatch(v, parten) do
                table.insert(newlist, string.format("%s%d%d%02d", name, modelData.classes, modelData.sex, id))
            end
        end
        self.animationWhiteList = newlist
    else
        self.animationWhiteList = {}
    end
    self.modelData = modelData
    if setting ~= nil then
        self.setting = setting

        self.name = setting.name or "Unknown"
        self.sortingOrder = setting.sortingOrder ~= nil and setting.sortingOrder or nil
        self.parent = setting.parent
        if setting.usemask then
            if setting.usemask == true then
                self.usemask = 1
            else
                self.usemask = setting.usemask
            end
        end
        self.localPos = setting.localPos or Vector3(0, 0, -500)
        self.localRot = setting.localRot or Vector3(0, 180, 0)
        self.noDrag = setting.noDrag or false
        self.usePerspective = setting.usePerspective or false
        self.layer = setting.layer or "UI"
        if self.usePerspective then
            self.layer = "ModelPreview"
            PreviewManager.Instance:OpenPerspCam()
        end
        if setting.loadType ~= nil then
            self.loadType = setting.loadType
        end
        self.animationWhiteList = setting.animationWhiteList or {}
    end
    self:BuildTpose(true)
end

function PreviewmodelComposite:PlayAction(action)
    if UtilsBase.IsNull(self.animation) then
        return
    end
    if action == SceneEumn.UnitAction.Stand then
        -- self.animation:CrossFade(self.animationData.stand_id, self.fadeTime)
        self.animation:Play(self.animationData.stand_id)
        if not UtilsBase.IsNull(self.animationHead) and self.animationDataHead.stand_id ~= "" then
            self.animationHead:CrossFade(self.animationDataHead.stand_id, self.fadeTime)
        end
    elseif action == SceneEumn.UnitAction.Move then
        self.animation:Play(self.animationData.move_id)
        -- self.animation:CrossFade(self.animationData.move_id, self.fadeTime)
        if not UtilsBase.IsNull(self.animationHead) and self.animationDataHead.move_id ~= "" then
            self.animationHead:CrossFade(self.animationDataHead.move_id, self.fadeTime)
        end
    end
end

function PreviewmodelComposite:PlayAnimation(name)
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

function PreviewmodelComposite:StopAnimation()
    if UtilsBase.IsNull(self.tpose) then
        return
    end
    if self.animation == nil then
        self.animation = self.tpose:GetComponent(Animation)
    end
    if self.animation ~= nil then
        self.animation:Stop()
    end
end

function PreviewmodelComposite:PlayAnimations(animations)
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
                    LogError("PreviewmodelComposite播放未加载的动作，PlayAnimations1")
                end
                self.animation:CrossFadeQueued(name, self.fadeTime, QueueMode.PlayNow)
            else
                if self.animation:getItem(name) == nil then
                    LogError("PreviewmodelComposite播放未加载的动作，PlayAnimations2")
                end
                self.animation:CrossFadeQueued(name, self.fadeTime, QueueMode.CompleteOthers)
            end
        end
    end
end

-- 持有该对象但是释放掉模型
function PreviewmodelComposite:Release()
    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end
    self.modelData = {}
end

-- 休闲动作展示
function PreviewmodelComposite:ShowIdle()
    if UtilsBase.IsNull(self.tpose) then
        return
    end
    if self.animation == nil then
        self.animation = self.tpose:GetComponent(animation)
    end
    if self.animation:getItem(self.animationData.idle_id) == nil then
        LogError("PreviewmodelComposite播放未加载的Idle")
    end
    self.animation:CrossFadeQueued(self.animationData.idle_id, self.fadeTime, QueueMode.PlayNow)
    self.animation:CrossFadeQueued(self.animationData.stand_id, self.fadeTime, QueueMode.CompleteOthers)
end

function PreviewmodelComposite:PlayActionRepeat(animations)
    if UtilsBase.IsNull(self.tpose) then
        return
    end
    if self.animation == nil then
        self.animation = self.tpose:GetComponent(animation)
    end
    self.repeatAnimationIndex = 0
    self.repeatAnimations = animations
    self:PlayNextRepeatAction()
end

function PreviewmodelComposite:PlayNextRepeatAction()
    self.repeatAnimationIndex = self.repeatAnimationIndex % #self.repeatAnimations
    self.repeatAnimationIndex = self.repeatAnimationIndex + 1
    local actionName = self.repeatAnimations[self.repeatAnimationIndex]
    if self.animation:getItem(actionName) == nil then
        LogError("PreviewmodelComposite播放未加载的动作，PlayNextRepeatAction")
    end
    self.animation:CrossFadeQueued(actionName, self.fadeTime, QueueMode.PlayNow)
    local time = self.animation:GetClip(actionName).length * 1000
    self.repeatTimerId = TimerManager.Add(time, function() self:PlayNextRepeatAction() end)
end
