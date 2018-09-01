require("CommonRequire")

for i = 1, #TestFileConfig do
    require(TestFileConfig[i])
end

local root = GameObject.Find("UIRoot")
-- LListTest.New(root.transform:Find("LListTest").gameObject)
-- LScrollViewTest.New(root.transform:Find("LScrollViewTest").gameObject)
-- LScrollPageTest.New(root.transform:Find("LScrollPageTest").gameObject)
-- LTreeTest.New(root.transform:Find("LTreeTest").gameObject)
-- local meshTest = MeshTest.New(root.transform:Find("Mesh").gameObject)
local imageMeshTest = ImageMeshTest.New(root.transform:Find("ImageMesh").gameObject)

function Update()
    if Input.GetKeyDown(KeyCode.H) and Input.GetKey(KeyCode.LeftControl) then
        for i = 1, #CommonFileConfig do
            package.loaded[CommonFileConfig[i]] = nil
            require(CommonFileConfig[i])
        end
        for i = 1, #TestFileConfig do
            package.loaded[TestFileConfig[i]] = nil
            require(TestFileConfig[i])
        end
        print("热更完毕")
    end

    if Input.GetKeyDown(KeyCode.W) and Input.GetKey(KeyCode.LeftControl) then
        print("W")
        meshTest:DrawTriangle()
    end
end

