UtilsBase = UtilsBase or {}

UtilsBase.INT32_MAX = 2147483647
UtilsBase.INT32_MIN = -2147483648

function UtilsBase.FieldDeleteMe(object, name)
    if IS_DEBUG then
        if type(name) ~= "string" then
            LogError("FieldDeleteMe 传入参数不为字符串")
        end
    end

    if object[name] ~= nil then
        object[name]:DeleteMe()
        object[name] = nil
    end
end

function UtilsBase.TableDeleteMe(object, name)
    if object[name] ~= nil then
        for key, item in _pairs(object[name]) do
            if item.DeleteMe then
                item:DeleteMe()
            end
        end
        object[name] = nil
    end
end

function UtilsBase.DestroyGameObject(object, name)
    if object[name] ~= nil then
        GameObject.Destroy(object[name])
        object[name] = nil
    end
end

function UtilsBase.TweenDelete(object, name)
    if object[name] ~= nil then
        Tween.Instance:Cancel(object[name])
        object[name] = nil
    end
end

function UtilsBase.TweenIdListDelete(object, name)
    if object[name] then
        for _, tweenId in _pairs(object[name]) do
            Tween.Instance:Cancel(tweenId)
        end
        object[name] = nil
    end
end

function UtilsBase.CancelTween(id)
    Tween.Instance:Cancel(id)
end

-- 序列化
function UtilsBase.serialize(obj, name, newline, depth, keytab)
    local keylist
    if keytab == nil then
        keylist = {}
    else
        keylist = keytab
    end
    local space = newline and "    " or ""
    newline = newline and true
    depth = depth or 0

    local tmp = string.rep(space, depth)

    if name then
        if _type(name) == "number" then
            tmp = tmp .. "[" .. name .. "] = "
        elseif _type(name) == "string" then
            tmp = tmp .. name .. " = "
        else
            tmp = tmp .. _tostring(name) .. " = "
        end
    end

    if _type(obj) == "table" and keylist[obj] == nil then
            keylist[obj] = true
            tmp = tmp .. "{" .. (newline and "\n" or "")

            for k, v in _pairs(obj) do
                tmp =  tmp .. UtilsBase.serialize(v, k, newline, depth + 1, keylist) .. "," .. (newline and "\n" or "")
            end

            tmp = tmp .. string.rep(space, depth) .. "}"
        -- end
    elseif _type(obj) == "number" then
        tmp = tmp .. _tostring(obj)
    elseif _type(obj) == "string" then
        tmp = tmp .. _string_format("%q", obj)
    elseif _type(obj) == "boolean" then
        tmp = tmp .. (obj and "true" or "false")
    elseif _type(obj) == "function" then
        -- tmp = tmp .. _tostring(obj)
        tmp = tmp .. "【function】"
    elseif _type(obj) == "userdata" then
        tmp = tmp .. "【userdata】"
    else
        -- tmp = tmp .. "\"[" .. _string_format("%s", _tostring(obj)) .. "]\""
        tmp = tmp .. "\"[" .. _string_format("%s", "???") .. "]\""
    end

    return tmp
end

function UtilsBase.dump(obj, name)
    print(UtilsBase.serialize(obj, name, true, 0))
end

function UtilsBase.XPCall(func, errcb)
    local status, err = xpcall(func, function(errinfo)
        if errcb then
            errcb()
        else
            LogError("代码报错了: ".. _tostring(errinfo)..debug.force_traceback())
        end
    end)
end
