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


Vector2One = Vector3(1, 1)
Vector2Zero = Vector3(0, 0)
Vector2Down = Vector3(0, -1)
Vector2Left = Vector3(-1, 0)
Vector2Up = Vector3(0, 1)
Vector2Right = Vector3(1, 0)

Vector3One = Vector3(1, 1, 1)
Vector3Zero = Vector3(0, 0, 0)