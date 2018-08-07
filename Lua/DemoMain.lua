require("CommonRequire")

require("Test/TestDefine")

require("Demo/BaseDemo")
require("Demo/DemoManager")
require("Demo/MenuItem")
require("Demo/LDemoItem")
require("Demo/LListDemo")
require("Demo/LScrollViewDemo")
require("Demo/LScrollViewDemo1")
require("Demo/LScrollViewDemoItem1")
require("Demo/LScrollPageDemo")

require("Demo/LTree/LTreeDemo1")
require("Demo/LTree/LTreeNodeDataDemo1")
require("Demo/LTree/LTreeNodeDemo1")

DemoManager.New(GameObject.Find("UIRoot").transform)

function Update()
    if Input.GetKeyDown(KeyCode.Q) and Input.GetKey(KeyCode.LeftControl) then
        DemoManager.Instance:Release()
    end
end
