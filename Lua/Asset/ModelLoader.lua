ModelLoader = ModelLoader or BaseClass()

-- AssetDefine.PREFAB_PATH = "Unit/Vehicle/Prefab/%s.prefab"
-- AssetDefine.SKIN_PATH = "Unit/Vehicle/Skin/%s.TGA"
-- AssetDefine.ANIMATION_PATH = "Unit/Vehicle/Animation/%s"

function ModelLoader:__init()
    if ModelLoader.Instance then
        pError("重复生成单例")
        return
    end
    ModelLoader.Instance = self
end

function ModelLoader:Load(modelId, skinId, animationId)
    local prefab = AssetLoader.Instance:Load(string.format(AssetDefine.PREFAB_PATH, modelId))
    return prefab
end

