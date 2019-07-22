--chen quan
--二级列表数据结构
TwoLevelListVo = TwoLevelListVo or {}

function TwoLevelListVo.New(data, y, height, firstIndex, secondIndex)
    local obj = {}
    obj.data = data
    obj.y = y
    obj.height = height
    obj.firstIndex = firstIndex
    obj.secondIndex = secondIndex
    obj.key = TwoLevelList.GenKey(firstIndex, secondIndex)
    if secondIndex == nil then
        obj.level = 1
        obj.index = firstIndex
    else
        obj.level = 2
        obj.index = secondIndex
    end
    return obj
end
