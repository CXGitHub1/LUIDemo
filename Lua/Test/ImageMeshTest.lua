ImageMeshTest = ImageMeshTest or BaseClass(BaseTest)

ImageMeshTest.ColorDict = {
    Color32(255, 255, 255, 255),
    Color32(255, 0, 0, 255),
    Color32(0, 255, 0, 255),
    Color32(0, 0, 255, 255),
    Color32(255, 255, 0, 255),
    Color32(0, 255, 255, 255),
    Color32(255, 0, 255, 255),
}

function ImageMeshTest:__init(gameObject)
    local transform = gameObject.transform
    self.transform = transform
    self:SetDelegate("Test1", function(rect, vertexHelper) self:DrawRadar(rect, vertexHelper) end)
    self:SetDelegate("Test2", function(rect, vertexHelper) self:DrawCircle(rect, vertexHelper) end)
    self:SetDelegate("Test3", function(rect, vertexHelper) self:DrawCube(rect, vertexHelper) end)
    self:SetDelegate("Test4", function(rect, vertexHelper) self:DrawSphere(rect, vertexHelper) end)
end

function ImageMeshTest:SetDelegate(name, cb)
    local lMesh = self.transform:Find(name).gameObject:GetComponent(LMesh)
    lMesh.g = cb
    lMesh.gameObject:SetActive(true)
end

function ImageMeshTest:DrawRadar(rect, vh)
    local left = rect.x
    local right = rect.x + rect.width
    local bottom = rect.y
    local top = rect.y + rect.height
    vh:Clear()
    local origin = Vector3((left + right) / 2, (bottom + top) / 2, 0)
    vh:AddVert(origin, ImageMeshTest.ColorDict[1], Vector2(0, 0))
    local segment = 5
    local delta = 360 / segment
    local radius = 100
    for i = 1, segment do
        local radian = math.rad(18 + (i - 1) * delta)
        local x = math.cos(radian) * radius
        local y = math.sin(radian) * radius
        --注意不要数组溢出
        vh:AddVert(origin + Vector3(x, y), ImageMeshTest.ColorDict[i + 1], Vector2(0, 0))
    end

    for i = 1, segment - 1 do
        vh:AddTriangle(0, i + 1, i)
    end
    vh:AddTriangle(0, 1, segment)
    return vh
end

function ImageMeshTest:DrawCircle(rect, vh)
    local left = rect.x
    local right = rect.x + rect.width
    local bottom = rect.y
    local top = rect.y + rect.height
    vh:Clear()

    local segments = 60
    local radius = 100
    local origin = Vector3((left + right) / 2, (bottom + top) / 2, 0)
    vh:AddVert(origin, ImageMeshTest.ColorDict[1], Vector2(0, 0))
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        local x = math.cos(radian) * radius
        local y = math.sin(radian) * radius
        vh:AddVert(origin + Vector3(x, y), ImageMeshTest.ColorDict[(i % #ImageMeshTest.ColorDict) + 1], Vector2(0, 0))
    end

    local triangles = {}
    for i = 1, segments - 1 do
        vh:AddTriangle(0, i + 1, i)
    end
    vh:AddTriangle(0, 1, segments - 1)
    return vh
end

function ImageMeshTest:DrawCube(rect, vh)
    local left = rect.x
    local right = rect.x + rect.width
    local bottom = rect.y
    local top = rect.y + rect.height
    vh:Clear()

    local origin = Vector3((left + right) / 2, (bottom + top) / 2, 0)
    local l = 100
    vh:AddVert(origin + Vector3(0, 0, -l), ImageMeshTest.ColorDict[1], Vector2(0, 0))
    vh:AddVert(origin + Vector3(l, 0, 0), ImageMeshTest.ColorDict[2], Vector2(0, 0))
    vh:AddVert(origin + Vector3(0, 0, l), ImageMeshTest.ColorDict[3], Vector2(0, 0))
    vh:AddVert(origin + Vector3(-l, 0, 0), ImageMeshTest.ColorDict[4], Vector2(0, 0))
    vh:AddVert(origin + Vector3(0, l, 0), ImageMeshTest.ColorDict[5], Vector2(0, 0))
    vh:AddVert(origin + Vector3(0, -l, 0), ImageMeshTest.ColorDict[6], Vector2(0, 0))

    vh:AddTriangle(0, 5, 1)
    vh:AddTriangle(1, 5, 2)
    vh:AddTriangle(2, 5, 3)
    vh:AddTriangle(3, 5, 0)
    vh:AddTriangle(0, 1, 4)
    vh:AddTriangle(1, 2, 4)
    vh:AddTriangle(2, 3, 4)
    vh:AddTriangle(3, 0, 4)

    return vh
end

function ImageMeshTest:DrawSphere(rect, vh)
    local left = rect.x
    local right = rect.x + rect.width
    local bottom = rect.y
    local top = rect.y + rect.height
    vh:Clear()

    local origin = Vector3((left + right) / 2, (bottom + top) / 2, 0)
    local l = 100

    local top = Vector3(0, 1, 0)
    local bottom = Vector3(0, -1, 0)
    local left = Vector3(-1, 0, 0)
    local front = Vector3(0, 0, -1)
    local right = Vector3(1, 0, 0)
    local back = Vector3(0, 0, 1)

    local divideTimes = 16
    local vertices = self:GetSphereVertices(divideTimes, top, bottom, left, front, right, back)
    -- UtilsBase.dump(vertices)
    local radius = 100
    for i = 1, #vertices do
        vh:AddVert(origin + vertices[i].normalized * radius, ImageMeshTest.ColorDict[(i % #ImageMeshTest.ColorDict) + 1], Vector2(0, 0))
    end

    local triangles = self:GetSphereTriangles(divideTimes)
    for i = 1, #triangles, 3 do
        vh:AddTriangle(triangles[i], triangles[i + 1], triangles[i + 2])
    end
    return vh
end

function ImageMeshTest:GetSphereVertices(divideTimes, top, bottom, left, front, right, back)
    local vertices = {}
    --上半球
    table.insert(vertices, top)
    for i = 1, divideTimes do
        self:InsertLineVertices(vertices, divideTimes, i, top, left, front, right, back)
    end
    --下半球
    for i = divideTimes - 1, 1, -1 do
        self:InsertLineVertices(vertices, divideTimes, i, bottom, left, front, right, back)
    end
    table.insert(vertices, bottom)
    return vertices
end

function ImageMeshTest:InsertLineVertices(vertices, divideTimes, i, topOrBottom, left, front, right, back)
    local p1 = Vector3.Lerp(topOrBottom, left, i / divideTimes)
    local p2 = Vector3.Lerp(topOrBottom, front, i / divideTimes)
    local p3 = Vector3.Lerp(topOrBottom, right, i / divideTimes)
    local p4 = Vector3.Lerp(topOrBottom, back, i / divideTimes)
    table.insert(vertices, p1)
    for j = 1, i - 1 do
        table.insert(vertices, Vector3.Lerp(p1, p2, j / i))
    end
    table.insert(vertices, p2)
    for j = 1, i - 1 do
        table.insert(vertices, Vector3.Lerp(p2, p3, j / i))
    end
    table.insert(vertices, p3)
    for j = 1, i - 1 do
        table.insert(vertices, Vector3.Lerp(p3, p4, j / i))
    end
    table.insert(vertices, p4)
    for j = 1, i - 1 do
        table.insert(vertices, Vector3.Lerp(p4, p1, j / i))
    end
end

function ImageMeshTest:GetSphereTriangles(divideTimes)
    local triangles = {}
    local parentStartIndex = 0
    local startIndex = parentStartIndex + 1
    local parentStartIndex, startIndex = self:GetSphereUpperTriangles(triangles, divideTimes, parentStartIndex, startIndex)
    self:GetSphereLowerTriangles(triangles, divideTimes, parentStartIndex, startIndex)
    -- UtilsBase.dump(triangles)
    return triangles
end

function ImageMeshTest:GetSphereUpperTriangles(triangles, divideTimes, parentStartIndex, startIndex)
    for i = 1, divideTimes do
        local parentPerPoint = i
        local length = i * 4
        local parentIndex = parentStartIndex
        local index = startIndex
        for j = 1, length do
            --正三角
            table.insert(triangles, index)
            if j == length then
                table.insert(triangles, parentStartIndex)
                table.insert(triangles, startIndex)
            else
                table.insert(triangles, parentIndex)
                table.insert(triangles, index + 1)
            end
            index = index + 1
            if j % parentPerPoint ~= 0 then
                parentIndex = parentIndex + 1
                --倒三角
                table.insert(triangles, parentIndex - 1)
                if parentIndex == startIndex then
                    table.insert(triangles, parentStartIndex)
                else
                    table.insert(triangles, parentIndex)
                end
                table.insert(triangles, startIndex + j)
            end
        end

        --下一层
        parentStartIndex = startIndex
        startIndex = startIndex + length
    end
    return parentStartIndex, startIndex
end

function ImageMeshTest:GetSphereLowerTriangles(triangles, divideTimes, parentStartIndex, startIndex)
    for i = divideTimes, 1, -1 do
        local perPoint = i
        local parentLength = i * 4
        local length = (i - 1) * 4

        local parentIndex = parentStartIndex
        local index = startIndex
        for j = 1, parentLength do
            --倒三角
            table.insert(triangles, parentIndex)
            if j == parentLength then
                table.insert(triangles, parentStartIndex)
                table.insert(triangles, startIndex)
            else
                table.insert(triangles, parentIndex + 1)
                table.insert(triangles, index)
            end
            parentIndex = parentIndex + 1
            if j % perPoint ~= 0 then
                index = index + 1
                --正三角
                if index == (startIndex + length) then
                    table.insert(triangles, startIndex)
                else
                    table.insert(triangles, index)
                end
                table.insert(triangles, index - 1)
                table.insert(triangles, parentIndex)
            end
        end

        --下一层
        parentStartIndex = startIndex
        startIndex = startIndex + length
    end
end

