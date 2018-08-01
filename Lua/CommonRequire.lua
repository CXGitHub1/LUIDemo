import("UnityEngine")
import('UnityEngine.UI')

require("Base/BaseClass")
require("Base/EventLib")
require("Util/UtilsBase")
require("Util/UtilsUI")
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
require("Demo/MenuItem")
require("Demo/LDemoItem")
require("Demo/LScrollViewDemo")
require("Demo/LScrollViewDemo1")
require("Demo/LScrollViewDemoItem1")

Tween.New()

_print = print
print = Debug.LogError
pError = Debug.LogError