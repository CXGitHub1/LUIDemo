import("UnityEngine")
import('UnityEngine.UI')

_print = print
print = function(msg)
    Debug.LogError(msg .. "\n" .. debug.traceback())
end
pError = Debug.LogError

string.Empty = ""

math.round = function(value)
    return math.floor(value + 0.5)
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
    "LComponent/LTreeNode",
    "LComponent/LTreeNodeData",
    "Util/UtilsTable",
    "Demo/BaseDemo",
    "Test/BaseTest",
    "Test/TestDefine",
}

Main.LoadLuaClass = function(tb)
    for _, classPath in ipairs(PriorClassPathArray) do
        require(classPath)
    end
    local loadedClassPathDict = UtilsTable.ArrayToTable(PriorClassPathArray)
    loadedClassPathDict["Main"] = true
    for t in Slua.iter(tb.Keys) do
        local classPath = tb[t]
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
    -- LScrollPageTest.New(root.transform:Find("LScrollPageTest").gameObject)
    -- LTreeTest.New(root.transform:Find("LTreeTest").gameObject)
    -- local meshTest = MeshTest.New(root.transform:Find("MeshTest").gameObject)
    -- local imageMeshTest = ImageMeshTest.New(root.transform:Find("ImageMeshTest").gameObject)
    -- local scrollViewTest = LMIScrollViewTest.New(root.transform:Find("LMIScrollViewTest").gameObject)
    -- local scrollViewTest = LSIScrollViewTest.New(root.transform:Find("LSIScrollViewTest").gameObject)
    -- local rtModelTest = LRTModelTest.New(root.transform:Find("LRTModelTest").gameObject)
    local uiModelTest = LUIModelTest.New(root.transform:Find("LUIModelTest").gameObject)
end

function DemoMain()
    Init()
    DemoManager.New(GameObject.Find("UIRoot").transform)
end

function Init()
    Tween.New()
    AssetLoader.New()
    ModelLoader.New()
end

function Update()
    if Input.GetKeyDown(KeyCode.H) and Input.GetKey(KeyCode.LeftControl) then
        print("热更完毕")
    end

    if Input.GetKeyDown(KeyCode.W) and Input.GetKey(KeyCode.LeftControl) then
        print("W")
        -- scrollViewTest.scrollView:Release()
        -- meshTest:DrawTriangle()
    end
end