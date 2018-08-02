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



Tween.New()

_print = print
print = Debug.LogError
pError = Debug.LogError