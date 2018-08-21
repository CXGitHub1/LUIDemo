require("CommonRequire")

for i = 1, #TestFileConfig do
	require(TestFileConfig[i])
end

local root = GameObject.Find("UIRoot")
-- LListTest.New(root.transform:Find("LListTest").gameObject)
-- LScrollViewTest.New(root.transform:Find("LScrollViewTest").gameObject)
-- LScrollPageTest.New(root.transform:Find("LScrollPageTest").gameObject)
LTreeTest.New(root.transform:Find("LTreeTest").gameObject)

function Update()
    if Input.GetKeyDown(KeyCode.Q) and Input.GetKey(KeyCode.LeftControl) then
    end

    if Input.GetKeyDown(KeyCode.W) and Input.GetKey(KeyCode.LeftControl) then
    end
end

