LLayerTest = LLayerTest or BaseClass(BaseTest)

function LLayerTest:__init(gameObject)
    local transform = gameObject.transform
    local testTrans = transform:Find("Layer1")
    
    local modelGo = ModelLoader.Instance:Load(ModelLoaderData.New(80003, 80003, 80003))
    local modelTrans = modelGo.transform
    UtilsBase.SetParent(modelTrans, testTrans)
    UtilsBase.SetLayer(modelTrans, "UI")
    modelTrans.localEulerAngles = Vector3(0, 180, 0)
    modelTrans.localScale = Vector3One * 50
    local effectGo = UIEffectLoader.Instance:Load(20166)
    UtilsBase.SetParent(effectGo.transform, testTrans)
end
