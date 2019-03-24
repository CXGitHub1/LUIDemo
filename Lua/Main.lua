import("UnityEngine")
import('UnityEngine.UI')

_print = print
print = function(...)
    local content = ""
    local parameter = {...}
    for _, v in pairs(parameter) do
        content = content .. v .. "\n"
    end
    Debug.LogError(content .. debug.traceback())
end
pError = Debug.LogError

string.Empty = ""

math.round = function(value)
    return math.floor(value + 0.5)
end

math.clamp = function(value, min, max)
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end

Vector2One = Vector3(1, 1)
Vector2Zero = Vector3(0, 0)
Vector2Down = Vector3(0, -1)
Vector2Left = Vector3(-1, 0)
Vector2Up = Vector3(0, 1)
Vector2Right = Vector3(1, 0)

Vector3One = Vector3(1, 1, 1)
Vector3Zero = Vector3(0, 0, 0)

--优先加载的类路径数组
PriorClassPathArray = {
    "Base/BaseClass",
    "LComponent/LDefine",
    "LComponent/LItem",
    "LComponent/LBaseScroll",
    "LComponent/LTreeNode",
    "LComponent/LTreeNodeData",
    "LComponent/LPanel",
    "Util/UtilsTable",
    "Demo/BaseDemo",
    "Test/BaseTest",
    "Test/TestDefine",
}

Main.LoadLuaClass = function(classPathArray)
    for _, classPath in ipairs(PriorClassPathArray) do
        require(classPath)
    end
    local loadedClassPathDict = UtilsTable.ArrayToTable(PriorClassPathArray)
    loadedClassPathDict["Main"] = true

    for classPath in Slua.iter(classPathArray) do
        if not loadedClassPathDict[classPath] then
            require(classPath)
        end
    end
end

function TestMain()
    Init()
    local root = GameObject.Find("UIRoot")
    -- LListTest.New(root.transform:Find("LListTest").gameObject)
    -- LScrollViewTest.New(root.transform:Find("LScrollViewTest").gameObject)
    LScrollPageTest.New(root.transform:Find("LScrollPageTest").gameObject)
    -- LTreeTest.New(root.transform:Find("LTreeTest").gameObject)
    -- local meshTest = MeshTest.New(root.transform:Find("MeshTest").gameObject)
    -- local imageMeshTest = ImageMeshTest.New(root.transform:Find("ImageMeshTest").gameObject)
    -- local scrollViewTest = LMIScrollViewTest.New(root.transform:Find("LMIScrollViewTest").gameObject)
    -- local scrollViewTest = LSIScrollViewTest.New(root.transform:Find("LSIScrollViewTest").gameObject)
    -- local rtModelTest = LRTModelTest.New(root.transform:Find("LRTModelTest").gameObject)
    -- local uiModelTest = LUIModelTest.New(root.transform:Find("LUIModelTest").gameObject)
    -- local layerTest = LLayerTest.New(root.transform:Find("LLayerTest").gameObject)
    -- local emojiTextTest = LEmojiTextTest.New(root.transform:Find("LEmojiTextTest").gameObject)
end

function DemoMain()
    Init()
    DemoManager.New(GameObject.Find("UIRoot").transform)
end

function Init()
    Tween.New()
    AssetLoader.New()
    ModelLoader.New()
    UIEffectLoader.New()
    PanelManager.New()
end

function Update()
    if Input.GetKeyDown(KeyCode.H) and Input.GetKey(KeyCode.LeftControl) then
        print("热更完毕")
    end

    if Input.GetKeyDown(KeyCode.W) and Input.GetKey(KeyCode.LeftControl) then
        print("W")
        local position = Vector2(1, 1)
        local c
        local count = 10000

        local go = GameObject.Find("UIRoot/LScrollPageTest").gameObject
        local pivot = go.transform.pivot
        local sizeDelta = go.transform.sizeDelta
        Profiling.Profiler.BeginSample("BBB")
        for i = 1, count do
            -- local pivot = go.transform.pivot
            -- local sizeDelta = go.transform.sizeDelta
            go.transform.anchoredPosition = position + Vector2(pivot.x * sizeDelta.x, (pivot.y - 1) * sizeDelta.y)
        end
        Profiling.Profiler.EndSample()

        Profiling.Profiler.BeginSample("AAA")
        for i = 1, count do
            local pivot = go.transform.pivot
            local sizeDelta = go.transform.sizeDelta
            go.transform.anchoredPosition = position + Vector2(pivot.x * sizeDelta.x, (pivot.y - 1) * sizeDelta.y)
        end
        Profiling.Profiler.EndSample()

        
        -- scrollViewTest.scrollView:Release()
        -- meshTest:DrawTriangle()
    end

    if Input.GetKeyDown(KeyCode.E) and Input.GetKey(KeyCode.LeftControl) then
        print("E")
    end
    PanelManager.Instance:Update()
end