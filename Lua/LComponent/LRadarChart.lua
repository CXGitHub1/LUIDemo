LRadarChart = LRadarChart or BaseClass()

local math_random = math.random

function LRadarChart:__init(transform, radius)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.radius = radius
    self.lMesh = self.gameObject:GetComponent(LMesh)
    self.lMesh.g = function(rect, vertexHelper) self:DrawRadar(rect, vertexHelper) end
    self.valueList = nil
    self.color = nil
end

function LRadarChart:DrawRadar(rect, vh)
    if self.valueList == nil then
        return vh
    end
    local left = rect.x
    local right = rect.x + rect.width
    local bottom = rect.y
    local top = rect.y + rect.height
    local origin = Vector3((left + right) / 2, (bottom + top) / 2, 0)
    local color = self.color or Color32(math_random(0, 255), math_random(0, 255), math_random(0, 255), 100)
    vh:AddVert(origin, color, Vector2(0, 0))
    local segment = #self.valueList
    local delta = 360 / segment
    local radius = self.radius
    for i = 1, segment do
        local radian = math.rad(90 + (i - 1) * delta)
        local x = math.cos(radian) * radius * self.valueList[i]
        local y = math.sin(radian) * radius * self.valueList[i]
        vh:AddVert(origin + Vector3(x, y), self.color or Color32(math_random(0, 255), math_random(0, 255), math_random(0, 255), 255), Vector2(0, 0))
    end

    for i = 1, segment - 1 do
        vh:AddTriangle(0, i + 1, i)
    end
    vh:AddTriangle(0, 1, segment)
    return vh
end

function LRadarChart:SetData(valueList, color)
    self.valueList = valueList
    self.color = color
    -- self.lMesh:SetVerticesDirty()
end

--效果
--原理
--unity的图形都是由一个个三角形拼起来的
--现在unity已经提供了接口，只需要你提供3个坐标和坐标绘制的顺序
--就可以从坐标绘制顺时针方向看到一个三角形
--有这个接口，你可以绘制
--三角形
--正方形
--圆形
--太阳
--圆环
--正方体
--八面体
--球体
--unity还提供接口，设置绘制三角形的贴图内容，下面是一些带贴图的例子
--详细的原理可以参考这专题
--UGUI的话只需要自定义一个类，继承graphic，重写OnPopulateMesh即可完成绘制
--代码地址
