import("UnityEngine")
import('UnityEngine.UI')

require("Config")

for i = 1, #CommonFileConfig do
    require(CommonFileConfig[i])
end

Tween.New()

_print = print
print = function(msg)
    Debug.LogError(msg .. "\n" .. debug.traceback())
end
pError = Debug.LogError

string.Empty = ""

math.round = function(value)
    return math.floor(value + 0.5)
end

AssetLoader.New()
ModelLoader.New()