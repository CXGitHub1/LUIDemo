import("UnityEngine")
import('UnityEngine.UI')

function Main()
    print("Main")
end

function Start()
    print("Start")
end

require("Base/BaseClass")
require("Util/UtilsBase")
require("Util/UtilsUI")
require("Util/UtilsTween")
require("Util/EventMgr")
require("Util/Tween")

require("LComponent/LItem")
require("LComponent/LList")
require("LComponent/LScrollView")
require("LComponent/LScrollPage")
require("LComponent/LTree")

require("Test/TestDefine")
require("Test/LTestItem")
require("Test/LListTest")
require("Test/LScrollViewTest")
require("Test/LScrollPageTest")

require("Demo/BaseDemo")
require("Demo/DemoManager")
require("Demo/DemoScrollViewItem")
require("Demo/LDemoItem")
require("Demo/LScrollViewDemo")

Tween.New()

_print = print
print = Debug.LogError

DemoManager.New(GameObject.Find("UIRoot").transform)

-- local go = root.transform:Find("List")
-- ListViewPanel.New(go)


-- local go = root.transform:Find("ScrollPage")
-- ScrollPagePanel.New(go)

-- local go = root.transform:Find("NExpandableListView")
-- ExpandablePanel.New(go)

-- local root = GameObject.Find("UIRoot")
-- LListTest.New(root.transform:Find("LListTest").gameObject)
-- LScrollViewTest.New(root.transform:Find("LScrollViewTest").gameObject)
-- LScrollPageTest.New(root.transform:Find("LScrollPageTest").gameObject)

function Update()
    if Input.GetKeyDown(KeyCode.Q) and Input.GetKey(KeyCode.LeftControl) then
        -- test.listView4:SetData({1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6}, {sizeType = LScrollViewTest.SizeType.fix})
    end

    if Input.GetKeyDown(KeyCode.W) and Input.GetKey(KeyCode.LeftControl) then
        -- test.listView4:SetData({1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10}, {sizeType = LScrollViewTest.SizeType.fix})
    end
end
