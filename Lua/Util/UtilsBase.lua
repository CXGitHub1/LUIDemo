UtilsBase = UtilsBase or {}

UtilsBase.Time = os.time()
UtilsBase.FloatTime = os.time()
local _string_format = string.format
local _os_time = os.time
local _os_date = os.date
local _tostring = tostring
local _tonumber = tonumber
local _type = type
local _ipairs = ipairs
local _pairs = pairs
local _next = next
local _table_insert = table.insert
local _table_concat = table.concat
local _math_ceil = math.ceil
local _math_floor = math.floor
local _math_abs = math.abs

function UtilsBase.ServerTime()
    return math.round(UtilsBase.FloatTime)
end

function UtilsBase.ZeroTimeStamp()
    local year,month,day = TimeHelper.GetYMD(UtilsBase.ServerTime())
    local zero_stamp = _os_time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
    return zero_stamp
end

UtilsBase.INT32_MAX = 2147483647
UtilsBase.INT32_MIN = -2147483648

-- 剑骑普攻动作
UtilsBase.QishiAttackActionName = {
    ["attack4101"] = true
    ,["attack4102"] = true
    ,["attack4103"] = true
    ,["attack4001"] = true
    ,["attack4002"] = true
    ,["attack4003"] = true
}

-- 复制table
function UtilsBase.copytab(st, keytab)
    local keylist
    if keytab == nil then
        keylist = {}
    else
        keylist = keytab
    end
    if st == nil then return nil end
    if _type(st) ~= "table" then
        return st
    end
    local tab = {}
    for k, v in _pairs(st or {}) do
        if _type(v) ~= "table" then
            tab[k] = v
        elseif keylist[v] == nil then
            keylist[v] = true
            tab[k] = UtilsBase.copytab(v, keylist)
        end
    end
    return tab
end

-- 覆盖table属性 把tab2的所有内容赋值给tab1
function UtilsBase.covertab(tab1, tab2)
    for k, v in _pairs(tab2) do
        tab1[k] = v
    end
    return tab1
end

-- 检查table内容是否相同(正反调用两次，确保两个table相同)
function UtilsBase.sametab(tab1, tab2)
    if UtilsBase.checktab(tab1, tab2) and UtilsBase.checktab(tab2, tab1) then
        return true
    end
    return false
end

-- 检查table内容是否相同(如果tab2比tab1大则检查不出来)
function UtilsBase.checktab(tab1, tab2)
    if tab1 ~= nil and tab2 == nil then return false end

    for k, v in _pairs(tab1 or {}) do
        if _type(v) ~= "table" then
            if tab2[k] ~= v then return false end
        elseif tab2[k] ~= nil then
            if not UtilsBase.sametab(v, tab2[k]) then return false end
        else
            return false
        end
    end
    return true
end

function UtilsBase.mergeTable(...)
    local arg = {...}
    local result = {}
    for i, v in _ipairs(arg) do
        for _, vv in _ipairs(v) do
            _table_insert(result, vv)
        end
    end
    return result
end

-- 代替lua的sort，以避免出现不稳定排序问题
function UtilsBase.BubbleSort(templist, sortFuc)
    local list = {}
    for k, v in _pairs(templist) do
        _table_insert(list, v)
    end
    local tempVal = true
    for m=#list-1,1,-1 do
        tempVal = true
        for i=#list-1,1,-1 do
            local a = list[i]
            local b = list[i+1]
            local sortBoo = sortFuc(a, b)
            if sortBoo == false then
                list[i], list[i+1] = list[i+1], list[i]
                tempVal = false
            end
        end
        if tempVal then break end
    end
    return list
end

function UtilsBase.Platform()
    return Application.platform
end

function UtilsBase.PlatformStr()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        return "IPhonePlayer"
    elseif Application.platform == RuntimePlatform.Android then
        return "Android"
    elseif Application.platform == RuntimePlatform.WindowsPlayer
        or Application.platform == RuntimePlatform.WindowsEditor
        then
        return "WindowsPlayer"
    else
        return nil
    end
end

function UtilsBase.IsIPhonePlayer()
    return Application.platform == RuntimePlatform.IPhonePlayer
end

-- 序列化
-- 序列化时只需传入obj的值，其它保持nil
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

-- 用于存储的序列化
function UtilsBase.serializeForSave(obj, name)
    local tmp = ""
    local showComma = false
    local objType = _type(obj)
    if objType == "table" or
        objType == "number" or
        objType == "string" or
        objType == "boolean" then
        if name then
            if _type(name) == "number" then
                tmp = tmp .. "[" .. name .. "] = "
            elseif _type(name) == "string" then
                tmp = tmp .. name .. " = "
            else
                tmp = tmp .. _tostring(name) .. " = "
            end
        end
        showComma = true

        if _type(obj) == "table" then
            tmp = tmp .. "{" ..  ""
            for k, v in _pairs(obj) do
                if k ~= "_class_type" and k ~= "traceinfo" then
                    local str, returnShowComma = UtilsBase.serializeForSave(v, k)
                    tmp =  tmp .. str .. (returnShowComma and "," or "")
                end
            end
            tmp = tmp .. "}"
        elseif _type(obj) == "number" then
            tmp = tmp .. _tostring(obj)
        elseif _type(obj) == "string" then
            tmp = tmp .. _string_format("%q", obj)
        elseif _type(obj) == "boolean" then
            tmp = tmp .. (obj and "true" or "false")
        end
    end

    return tmp, showComma
end

-- 反序列化
function UtilsBase.unserialize(str)
    return assert(loadstring("local tmp = " .. str .. " return tmp"))()
end

-- 显示指定对象的结构
function UtilsBase.dump(obj, name)
    print(UtilsBase.serialize(obj, name, true, 0))
end

-- 显示指定对象的matetable结构
function UtilsBase.dump_mt(obj, name)
    if IS_DEBUG and ctx.Editor then
        UtilsBase.dump(getmetatable(obj), name)
    end
end

-- 获取子节点路径
function UtilsBase.GetChild(transform, nodeName)
    if transform == nil then
        return nil
    end

    local childs = transform.gameObject:GetComponentsInChildren(Transform)
    local num = childs.Length
    for i = 1, num do
        if childs[i].name == nodeName then
            return childs[i]
        end
    end
    return nil
end

-- 判断值是否为null、nil
function UtilsBase.IsNull(value)
    -- 优化直接用这个接口可判断，消耗最小
    return value == nil or Slua.IsNull(value)
    -- return (value == nil or Slua.IsNull(value))
    -- return (value == nil or (type(value) == "userdata" and value:Equals(nil)))
end

function UtilsBase.DefaultHoldTime()
    if IS_IOS then
        return 90
    else
        return 180
    end
end

function UtilsBase.GetEffectPath(effectid)
    if effectid >= 100000 then
        effectid = _math_ceil(effectid/10)
    end
    if effectid >= 80000 then
        return _string_format(AssetConfig.scene_effect_path, effectid)
    else
        return _string_format(AssetConfig.effect_path, effectid)
    end
end

function UtilsBase.GetDramaPath(resname)
    return _string_format(AssetConfig.drama_path, resname)
end

function UtilsBase.Key(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    if arg8 ~= nil then
        return _string_format("%s_%s_%s_%s_%s_%s_%s_%s", _tostring(arg1), _tostring(arg2), _tostring(arg3), _tostring(arg4), _tostring(arg5), _tostring(arg6), _tostring(arg7), _tostring(arg8))
    elseif arg7 ~= nil then
        return _string_format("%s_%s_%s_%s_%s_%s_%s", _tostring(arg1), _tostring(arg2), _tostring(arg3), _tostring(arg4), _tostring(arg5), _tostring(arg6), _tostring(arg7))
    elseif arg6 ~= nil then
        return _string_format("%s_%s_%s_%s_%s_%s", _tostring(arg1), _tostring(arg2), _tostring(arg3), _tostring(arg4), _tostring(arg5), _tostring(arg6))
    elseif arg5 ~= nil then
        return _string_format("%s_%s_%s_%s_%s", _tostring(arg1), _tostring(arg2), _tostring(arg3), _tostring(arg4), _tostring(arg5))
    elseif arg4 ~= nil then
        return _string_format("%s_%s_%s_%s", _tostring(arg1), _tostring(arg2), _tostring(arg3), _tostring(arg4))
    elseif arg3 ~= nil then
        return _string_format("%s_%s_%s", _tostring(arg1), _tostring(arg2), _tostring(arg3))
    elseif arg2 ~= nil then
        return _string_format("%s_%s", _tostring(arg1), _tostring(arg2))
    elseif arg1 ~= nil then
        return _tostring(arg1)
    end

    -- if IS_DEBUG then
    --     return _table_concat({...}, "_")
    -- else
    --     local params = {...}
    --     local retval = nil
    --     for _, v in _ipairs(params) do
    --         if (retval == nil) then
    --             retval = _tostring(v)
    --         else
    --             retval = _string_format("%s_%s", retval, _tostring(v))
    --         end
    --     end
    --     return retval
    -- end
end

local self_key = false

function UtilsBase.SelfKey()
    if not self_key then
        local roledata = RoleManager.Instance.roleBaseData
        if roledata == nil then
            return nil
        end
        self_key = UtilsBase.Key(roledata.rid, roledata.platform, roledata.zone_id)
    end
    return self_key
end

function UtilsBase.ClearSelfKey()
    self_key = false
end

function UtilsBase.IsSelf(rid, platform, zone_id)
    local roleData = RoleManager.Instance.roleData
    if roleData == nil then
        return false
    end
    return rid == roleData.rid and platform == roleData.platform and zone_id == roleData.zone_id
end

function UtilsBase.IsSameRole(sRid, sPlatform, sZoneId, tRid, tPlatform, tZoneId)
    return sRid == tRid and sPlatform == tPlatform and sZoneId == tZoneId
end

-- 复制table
function UtilsBase.Copy(st)
    if st == nil then return nil end
    if _type(st) ~= "table" then
        return st
    end
    local tab = {}
    for k, v in _pairs(st or {}) do
        if _type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = UtilsBase.Copy(v)
        end
    end
    return tab
end

function UtilsBase.ChangeLayer(go, layername)
    local uilayer = LayerMask.NameToLayer(layername)
    if uilayer == 0 then
        return
    end
    local childs = go:GetComponentsInChildren(Transform, true)
    local num = childs.Length
    for i = 1, num do
        childs[i].gameObject.layer = uilayer
    end
end

function UtilsBase.ChangeLayerTo(go, from_layername, to_layername)
    local formlayer = LayerMask.NameToLayer(from_layername)
    local tolayer = LayerMask.NameToLayer(to_layername)
    local childs = go:GetComponentsInChildren(Transform, true)
    local num = childs.Length
    for i = 1, num do
        if childs[i].gameObject.layer == formlayer then
            childs[i].gameObject.layer = tolayer
        end
    end
end

-- 默认不需要传递secondlayer, 当有多个遮罩叠加的时候需要设置为TRUE
function UtilsBase.SetMaskMat(ImgCom, secondlayer)
    if not secondlayer then
        if UtilsBase.maskmat == nil then
            local shader = ShaderManager.Instance:GetShader("Custom/MyUIDefault")
            UtilsBase.maskmat = PreloadManager.Instance:GetObject(AssetConfig.mask_mat)
            UtilsBase.maskmat.shader = shader
        end
        ImgCom.material = UtilsBase.maskmat
    else
        if UtilsBase.maskmat2 == nil then
            local shader = ShaderManager.Instance:GetShader("Custom/MyUIDefault2")
            UtilsBase.maskmat2 = PreloadManager.Instance:GetObject(AssetConfig.mask_mat2)
            UtilsBase.maskmat2.shader = shader
        end
        ImgCom.material = UtilsBase.maskmat2
    end
end

function UtilsBase.GetHeight(x, z)
    local result, hit = Physics.Raycast(Vector3(x, 1000, z), Vector3(0, -1, 0), Slua.out, 2000, SettingManager.GetLayerMaskVal("Default"))
    -- Debug.DrawLine(Vector3(x, 400, z), hit.point, Color.green, 20);
    if result then
        return hit.point.y + 0.1, result
    else
        return 1, result
    end
end

-- 判断是否到达一个点
function UtilsBase.IsReach(pos1, pos2)
    local mapcellsize = MapManager.Instance.cellSize
    if _math_abs(pos1.x - pos2.x) <= mapcellsize and _math_abs(pos1.z - pos2.z) <= mapcellsize then
        return true
    end
    return false
end

-- norelative 不管相对层级
function UtilsBase.SetOrder(go, order, norelative)
    local renders = go:GetComponentsInChildren(Renderer, true)
    for t in Slua.iter(renders) do
        if norelative then
            t.sortingOrder = order
        elseif _math_abs(t.sortingOrder - order) > 10 then
            t.sortingOrder = order + t.sortingOrder
        else
            t.sortingOrder = order + t.sortingOrder %10
        end
    end
end

function UtilsBase.SetMaterialStencil(material, secondlayer)
    if not secondlayer then
        material:SetInt("_Stencil", 1);
    else
        material:SetInt("_Stencil", 3);
    end
end

function UtilsBase.ChangeEffectMaskShader(go, order, layername, secondlayer)
    if layername ~= nil then
        UtilsBase.ChangeLayer(go, layername)
    end
    local renders = go.transform:GetComponentsInChildren(Renderer, true)
    for t in Slua.iter(renders) do
        if string.find(t.material.shader.name, "ParticlesAdditive") then
            t.material.shader = ShaderManager.Instance:GetShader("Xcqy/ParticleMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
            if order ~= nil then
                t.sortingOrder = order
            end
        elseif string.find(t.material.shader.name, "ParticlesAlphaBlended") then
            t.material.shader = ShaderManager.Instance:GetShader("Xcqy/ParticlesAlphaBlendedMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
            if order ~= nil then
                t.sortingOrder = order
            end
        elseif string.find(t.material.shader.name, "ZQLTTextureAdd") then
            t.material.shader = ShaderManager.Instance:GetShader("ZQLT/Particles/ZQLTTextureAddMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
            if order ~= nil then
                t.sortingOrder = order
            end
        elseif string.find(t.material.shader.name, "UVRoll_add") then
            t.material.shader = ShaderManager.Instance:GetShader("Custom/UVRoll_addMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
            if order ~= nil then
                t.sortingOrder = order
            end
        end
    end
end

local _orginal_id = 100000
function UtilsBase.GetClientID()
    _orginal_id = _orginal_id + 1
    return _orginal_id
end

-- 长文本格式，后面点点点
function UtilsBase.LongTextFormat(str, len)
    local list = string.ConvertStringTable(str)
    if #list <= len then
        return str
    end

    local result = ""
    for i,v in _ipairs(list) do
        if i <= (len - 3) then
            result = result .. v
        else
            break
        end
    end
    result = _string_format("%s...", result)
    return result
end

function UtilsBase.TableDeleteMe(object, name)
    if object[name] ~= nil then
        for key, item in _pairs(object[name]) do
            if item.DeleteMe then
                item:DeleteMe()
            -- else
            --     LogError("TableDeleteMe找不到销毁方法")
            --     Log.Info(tostring(key) .. ":" .. tostring(item) .. ":" .. tostring(item.name))
            --     if item.gameObject then
            --         Log.Info(tostring(item.gameObject.name))
            --     end
            --     Log.Info(debug.traceback())
            end
        end
        object[name] = nil
    end

end

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

function UtilsBase.TimerDelete(object, name)
    if object[name] ~= nil then
        TimerManager.Delete(object[name])
        object[name] = nil
    end
end

function UtilsBase.LoadAndPlayEffect(object, name, effectId, parent, position, order, changeMaskShader, scale, constancy, secondMask)
    if object[name] ~= nil then
        if constancy then
            if not object[name].activeInHierarchy then
                UtilsBase.PlayEffect(object, name)
            end
        else
            UtilsBase.PlayEffect(object, name)
        end
    else
        if object[name .. "_loading"] then
            object[name .. "_callback"] = object[name .. "_callback"] or {}
            table.insert(object[name .. "_callback"], function() UtilsBase.HideEffect(object, name) end)
        else
            local cb = function() UtilsBase.PlayEffect(object, name) end
            UtilsBase.LoadEffect(object, name, effectId, parent, position, order, cb, changeMaskShader, scale, secondMask)
        end
    end
end

function UtilsBase.PlayEffect(object, name)
    if object[name] ~= nil then
        object[name]:SetActive(false)
        object[name]:SetActive(true)
    end
end

function UtilsBase.HideEffect(object, name)
    if object[name] ~= nil then
        object[name]:SetActive(false)
    else
        if object[name .. "_loading"] then
            object[name .. "_callback"] = object[name .. "_callback"] or {}
            table.insert(object[name .. "_callback"], function() UtilsBase.HideEffect(object, name) end)
        end
    end
end

function UtilsBase.LoadEffect(object, name, effectId, parent, position, order, cb, changeMaskShader, scale, secondMask)
    if object[name] then
        return
    end
    object[name .. "_loading"] = true
    local loader = nil
    local callback = function(assetsloader)
        if object[name] == nil then
            if not UtilsBase.IsNull(parent) then
                local effect = assetsloader:Pop(UtilsBase.GetEffectPath(effectId))
                object[name] = effect
                local transform = effect.transform
                transform:SetParent(parent)
                transform.localScale = scale ~= nil and scale or Vector3.one
                transform.localPosition = position
                transform.localRotation = Quaternion.identity
                if changeMaskShader then
                    UtilsBase.ChangeEffectMaskShader(effect, order, "UI", secondMask)
                else
                    UtilsBase.SetOrder(effect, order)
                end
                object[name .. "_loading"] = false
                if cb then
                    cb()
                end
                for _,__cb in ipairs(object[name .. "_callback"] or {}) do
                    __cb()
                end
            end
        end
        loader:DeleteMe()
        loader = nil
    end
    loader = EffectLoader.New({effectId}, callback)
    loader:Load()
end

function UtilsBase.TableToList(tab)
    local result = {}
    for _, v in _pairs(tab) do
        _table_insert(result, v)
    end
    return result
end

function UtilsBase.TableReverse(tab)
    local result = {}
    for i = #tab, 1, -1 do
        _table_insert(result, tab[i])
    end
    return result
end

function UtilsBase.GetTableCount(tab)
    local count = 0
    for _, v in _pairs(tab) do
        count = count + 1
    end
    return count
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

function UtilsBase.SetParent(childTrans, parentTrans)
    childTrans:SetParent(parentTrans)
    childTrans.localScale = Vector3.one
    childTrans.localPosition = Vector3.zero
    childTrans.localRotation = Quaternion.identity
end

-- classSelf 类对象引用
-- name 定时器名字 字符串
-- time 定时时长 1000 为1秒
-- callback 回调函数
-- repeatFlag 循环标示
-- 注意反复添加同一名字的计时器会覆盖掉之前的
function UtilsBase.AddTimer(classSelf, name, time, callback, repeatFlag)
    if classSelf["timer_"..name] ~= nil then
        TimerManager.Delete(classSelf["timer_"..name])
        classSelf["timer_"..name] = nil
    end
    if time < 0 then return end
    if repeatFlag then
        classSelf["timer_"..name] = TimerManager.Add(0,time,callback)
    else
        classSelf["timer_"..name] = TimerManager.Add(time,callback)
    end
end

-- classSelf 类对象引用
-- name 定时器名字 字符串
function UtilsBase.DeleteTimer(classSelf, name)
    if classSelf["timer_"..name] ~= nil then
        TimerManager.Delete(classSelf["timer_"..name])
        classSelf["timer_"..name] = nil
    end
end

function UtilsBase.ContainValueTable(tab, value)
    for k,v in _pairs(tab) do
        if value == v then
            return true
        end
    end
    return false
end

-- SDK接口传递参数处理
function UtilsBase.GetServerId(roleData)
    local platform = roleData.platform
    local zone_id =  roleData.zone_id
    if platform == "beta" then
        return 1000 + _tonumber(zone_id)
    elseif platform == "ios" then
        return 2000 + _tonumber(zone_id)
    elseif platform == "mix" then
        return 3000 + _tonumber(zone_id)
    elseif platform == "unite" then
        return 4000 + _tonumber(zone_id)
    elseif platform == "kkk" then
        return 5000 + _tonumber(zone_id)
    elseif platform == "verifyios" then
        return 10000 + _tonumber(zone_id)
    end
    return zone_id
end

-- 获取地区说明
-- cn => 国内
-- sg => 新马
function UtilsBase.GetLocation()
    if CSInfo then
        return CSInfo.Location
    else
        return "cn"
    end
end

function UtilsBase.ToBase64(source_str)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local s64 = ""
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(_math_floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. "="
        end
    end

    return s64
end

function UtilsBase.GetServerName(zoneId, platform)
    local list = ServerConfig.testServers
    for _, data in _ipairs(list) do
        if data.zone_id == zoneId and data.platform == platform then
            return data.zone_name
        end
    end
    list = ServerConfig.servers
    for _, data in _ipairs(list) do
        if data.zone_id == zoneId and data.platform == platform then
            return data.zone_name
        end
    end
    return _T("未知服")
end

function UtilsBase.UrlEncode(s)
     s = string.gsub(s, "([^%w%.%- ])", function(c) return _string_format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function UtilsBase.AccountByChanelId(pchanlid, uid)
    if KKKChaneelShare[pchanlid] ~= nil then
        return uid .. "_" .. KKKChaneelShare[pchanlid]
    else
        return uid .. "_" .. _tostring(pchanlid)
    end
end


function UtilsBase.PlayMovie(name, canskip, callback)
    if Application.platform ~= RuntimePlatform.Android and Application.platform ~= RuntimePlatform.IPhonePlayer then
        NoticeManager.Instance:ShowFloat(_T("非移动平台不支持视频播放"))
        if callback then
            callback()
        end
        return
    end
    if UtilsBase.playmovieCom == nil then
        UtilsBase.playmovieCom = ctx.MainCamera.gameObject:AddComponent(MoviePlayer)
    end
    UtilsBase.playmovieCom.path = name
    -- Log.Info("开始播放视频~~~~~~")
    UtilsBase.playmovieCom.onFinish = nil
    if callback ~= nil then
        local event = UnityEvent()
        event:AddListener(callback)
        UtilsBase.playmovieCom.onFinish = event
    end
    UtilsBase.playmovieCom:Play(canskip == true)
    -- Log.Info("播放视频结束~~~~~~")
end

function UtilsBase.ContrastData(classes,sex)
    local roleData = RoleManager.Instance.roleData
    if (roleData.classes == classes or classes == 0) and (roleData.sex == sex or sex == 2) then
        return true
    end
    return false
end

function UtilsBase.TimeDeltaToDate(delta)
    local floor = _math_floor
    return floor(delta / 86400), floor((delta % 86400) / 3600), floor((delta % 3600) / 60), floor(delta % 60)
end

function UtilsBase.TimeDeltaToString(delta)
    local floor = _math_floor
    local args = {floor(delta / 86400), floor((delta % 86400) / 3600), floor((delta % 3600) / 60), floor(delta % 60)}
    local result = {}
    local preok = 0
    if args[1] > 0 or preok > 0 then preok = 1 _table_insert(result, args[1]) _table_insert(result, _T("日")) end
    if args[2] > 0 or preok > 0 then preok = 1 _table_insert(result, _string_format("%02d", args[2])) _table_insert(result, _T("时")) end
    if args[3] > 0 or preok > 0 then preok = 1 _table_insert(result, _string_format("%02d", args[3])) _table_insert(result, _T("分")) end
    if args[4] > 0 or preok > 0 then preok = 1 _table_insert(result, _string_format("%02d", args[4])) _table_insert(result, _T("秒")) end
    if _next(result) then
        return _table_concat(result)
    else
        return ""
    end
end

function UtilsBase.GetDate(timeStemp)
    return _tonumber(_os_date("%y", timeStemp)), _tonumber(_os_date("%m", timeStemp)), _tonumber(_os_date("%d", timeStemp)), _tonumber(_os_date("%H", timeStemp)), _tonumber(_os_date("%M", timeStemp)), _tonumber(_os_date("%S", timeStemp))
end

-- format = {0,1,1,0,1,0}, 分别表示年月日时分秒是否显示
function UtilsBase.GetDateString(timeStemp, format)
    format = format or {}
    local result = {}
    local args = {0, 0, 0, 0, 0, 0}
    args[1],args[2],args[3],args[4],args[5],args[6] = UtilsBase.GetDate(timeStemp)
    if format[1] == 1 then _table_insert(result, args[1]) _table_insert(result, _T("年")) end
    if format[2] == 1 then _table_insert(result, args[2]) _table_insert(result, _T("月")) end
    if format[3] == 1 then _table_insert(result, args[3]) _table_insert(result, _T("日")) end
    if format[4] == 1 then _table_insert(result, args[4]) _table_insert(result, _T("时")) end
    if format[5] == 1 then _table_insert(result, args[5]) _table_insert(result, _T("分")) end
    if format[6] == 1 then _table_insert(result, args[6]) _table_insert(result, _T("秒")) end

    if _next(result) then
        return _table_concat(result)
    else
        return ""
    end
end

-- 判断两个时间戳是否在同一天
-- 适用于2018年1月1日0点往后的时间戳
function UtilsBase.IsDifferentDate(stemp1, stemp2)
    UtilsBase.standardStemp = UtilsBase.standardStemp or _os_time({year = 2018, month = 1, day = 1, hour = 0, min = 0, sec = 0})
    return _math_floor((stemp1 - UtilsBase.standardStemp) / 86400) ~= _math_floor((stemp2 - UtilsBase.standardStemp) / 86400)
end

-- 是否玩家体验服
function UtilsBase.IsExperienceSrv()
    if CSVersion.platform == "android_experience" then
        return true
    else
        return false
    end
end

-- 获取网络状态
function UtilsBase.NetworkStatus()
    local val = Application.internetReachability
    if val == 0 then
        return "none"
    elseif val == 1 then
        return "data"
    elseif val == 2 then
        return "wifi"
    end
    return "wifi"
    -- return SdkManager.Instance:GetNetworkType()
end

local _dynamicShadowVector
function UtilsBase.DynamicShadowVector()
    if _dynamicShadowVector == nil then
        _dynamicShadowVector = Vector3(-0.29, -0.57, -0.2)
    end
    return _dynamicShadowVector
end

-- 中文utf-8字符串截取，超过指定长度的部分用...代替
function UtilsBase.SplitStringToLength(str,len)
    if str == nil then
        return ""
    end
    local lengthUTF_8 = #(string.gsub(str, "[\128-\191]", ""))
    if lengthUTF_8 <= len then
        return str
    else
        local matchStr = "^"
        for var=1, len do
            matchStr = matchStr..".[\128-\191]*"
        end
        local string = string.match(str, matchStr)
        return string.format("%s...",string);
    end
end

function UtilsBase.ExchangeNum(nowVal)
  local valueData = nowVal
  if nowVal > 9999 then
    if nowVal > 99999999 then
        local vlaue1 = nowVal/100000000
        vlaue1 = vlaue1-vlaue1%0.1
        valueData = vlaue1 .. "亿"
    else
        local vlaue1 = nowVal/10000
        vlaue1 = vlaue1-vlaue1%0.1
        valueData = vlaue1 .. "万"
    end
  end
  return valueData
end

function UtilsBase.HasItemNum(id)
    local hasNum = BackpackManager.Instance:GetItemCount(id)
    if hasNum == nil or hasNum == 0 then
        hasNum = RoleManager.Instance:GetAssetsValue(id)
    end
    return hasNum
end