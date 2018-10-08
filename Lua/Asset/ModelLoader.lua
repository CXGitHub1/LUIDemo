ModelLoader = ModelLoader or BaseClass()

function ModelLoader:__init()
    if ModelLoader.Instance then
        pError("重复生成单例")
        return
    end
    ModelLoader.Instance = self
end

function ModelLoader:Load(modelId, skinId, animationId)
    local prefab = AssetLoader.Instance:Load(string.format(AssetDefine.PREFAB_PATH, modelId))
    local go = GameObject.Instantiate(prefab)
    self:SetSkin(skinId, go.transform)
    self:SetAnimation(animationId, go)
    return go
end

function ModelLoader:SetSkin(skinId, transform)
    local renderer = transform:Find("Mesh_body"):GetComponent(Renderer)
    local mpb = MaterialPropertyBlock()
    renderer:GetPropertyBlock(mpb)
    local skin = AssetLoader.Instance:Load(string.format(AssetDefine.SKIN_PATH, skinId))
    local textureId = Shader.PropertyToID("_MainTex")
    mpb:SetTexture(textureId, skin)
    renderer:SetPropertyBlock(mpb)
end

function ModelLoader:SetAnimation(animationId, go)
    local animation = go:GetComponent(Animation)
    local playName = AssetDefine.ANIMATION_NAME_DICT[1]
    for _, name in pairs(AssetDefine.ANIMATION_NAME_DICT) do
        local path = string.format(AssetDefine.ANIMATION_PATH, animationId .. "/" .. name)
        local clip = AssetLoader.Instance:Load(path)
        local clipName = clip.name
        animation:AddClip(clip, clipName)
    end
    animation:Play(playName)
end
