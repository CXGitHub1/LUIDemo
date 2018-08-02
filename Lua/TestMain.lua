require("CommonRequire")

require("Test/TestDefine")
require("Test/BaseTest")
require("Test/LTestItem")
require("Test/LListTest")
require("Test/LScrollViewTest")
require("Test/LScrollPageTest")

local root = GameObject.Find("UIRoot")
LListTest.New(root.transform:Find("LListTest").gameObject)
-- LScrollViewTest.New(root.transform:Find("LScrollViewTest").gameObject)
-- LScrollPageTest.New(root.transform:Find("LScrollPageTest").gameObject)

function Update()
    if Input.GetKeyDown(KeyCode.Q) and Input.GetKey(KeyCode.LeftControl) then
    end

    if Input.GetKeyDown(KeyCode.W) and Input.GetKey(KeyCode.LeftControl) then
    end
end

