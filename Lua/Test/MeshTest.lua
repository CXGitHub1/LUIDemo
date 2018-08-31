MeshTest = MeshTest or BaseClass(BaseTest)

function MeshTest:__init(gameObject)
    local transform = gameObject.transform
    -- self:DrawTriangle(transform:Find("Test1"))
    -- self:DrawSquare(transform:Find("Test2"))
    -- self:DrawCircle(transform:Find("Test3"))
    -- self:DrawCircle1(transform:Find("Test4"))
    -- self:DrawRing(transform:Find("Test5"))
    -- self:DrawRadar(transform:Find("Test6"))
    -- self:DrawRadarBg(transform:Find("Test7"))
    -- self:DrawCube(transform:Find("Test8"))
    -- self:DrawOctahedron(transform:Find("Test9"))
    -- self:DrawSphere(transform:Find("Test10"))
    -- self:DrawTriangleTexture(transform:Find("Test11"))
    -- self:DrawSquareTexture(transform:Find("Test12"))
    -- self:DrawCircleTexture(transform:Find("Test13"))
    -- self:DrawRingTexture(transform:Find("Test14"))
    -- self:DrawCubeTexture(transform:Find("Test15"))
    self:DrawCubeTexture1(transform:Find("Test16"))
end

function MeshTest:GetMaterial(color)
    local material = Material(Shader.Find("Transparent/Diffuse"))
    material.color = color or Color.green
    return material
end

function MeshTest:DrawTriangle(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position

    mesh.vertices = {
        Vector3(position.x, position.y, position.z),
        Vector3(position.x, position.y + 100, position.z),
        Vector3(position.x + 100, position.y + 100, position.z),
    }
    mesh.triangles = {
        0, 1, 2,
    }
end

function MeshTest:DrawSquare(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position

    mesh.vertices = {
        Vector3(position.x, position.y, position.z),
        Vector3(position.x, position.y + 100, position.z),
        Vector3(position.x + 100, position.y + 100, position.z),
        Vector3(position.x + 100, position.y, position.z),
    }
    mesh.triangles = {
        0, 1, 2,
        0, 2, 3,
    }
end

function MeshTest:DrawCircle(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local segments = 60
    local vertices = {}
    local radius = 50
    table.insert(vertices, Vector3(position.x, position.y, position.z))
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        local x = math.cos(radian) * radius
        local y = math.sin(radian) * radius
        table.insert(vertices, Vector3(position.x + x, position.y + y, position.z))
    end
    mesh.vertices = vertices
    local triangles = {}
    for i = 1, segments - 1 do
        table.insert(triangles, 0)
        table.insert(triangles, i + 1)
        table.insert(triangles, i)
    end
    table.insert(triangles, 0)
    table.insert(triangles, 1)
    table.insert(triangles, #vertices - 1)
    mesh.triangles = triangles
end

function MeshTest:DrawCircle1(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local segments = 60
    local vertices = {}
    local radius = 50
    table.insert(vertices, Vector3(position.x, position.y, position.z))
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        local x = math.cos(radian) * radius
        local y = math.sin(radian) * radius
        table.insert(vertices, Vector3(position.x + x, position.y + y, position.z))
    end
    mesh.vertices = vertices
    local triangles = {}
    for i = 1, segments - 1, 2 do
        table.insert(triangles, 0)
        table.insert(triangles, i + 1)
        table.insert(triangles, i)
    end
    mesh.triangles = triangles
end

function MeshTest:DrawRing(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local segments = 60
    local vertices = {}
    local sRadius = 30
    local bRadius = 50
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        table.insert(vertices, Vector3(position.x + math.cos(radian) * sRadius, position.y + math.sin(radian) * sRadius, position.z))
        table.insert(vertices, Vector3(position.x + math.cos(radian) * bRadius, position.y + math.sin(radian) * bRadius, position.z))
    end
    mesh.vertices = vertices
    local triangles = {}
    for i = 1, #vertices - 2, 2 do
        table.insert(triangles, i - 1)
        table.insert(triangles, i + 1)
        table.insert(triangles, i)

        table.insert(triangles, i)
        table.insert(triangles, i + 1)
        table.insert(triangles, i + 2)
    end

    table.insert(triangles, #vertices - 2)
    table.insert(triangles, 0)
    table.insert(triangles, #vertices - 1)

    table.insert(triangles, #vertices - 1)
    table.insert(triangles, 0)
    table.insert(triangles, 1)
    mesh.triangles = triangles
end

function MeshTest:DrawRadarBg(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local segments = 5
    local vertices = {}
    local radius = 50
    table.insert(vertices, Vector3(position.x, position.y, position.z))
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta + 18)
        local x = math.cos(radian) * radius
        local y = math.sin(radian) * radius
        table.insert(vertices, Vector3(position.x + x, position.y + y, position.z))
    end
    mesh.vertices = vertices
    local triangles = {}
    for i = 1, segments - 1 do
        table.insert(triangles, 0)
        table.insert(triangles, i + 1)
        table.insert(triangles, i)
    end
    table.insert(triangles, 0)
    table.insert(triangles, 1)
    table.insert(triangles, #vertices - 1)
    mesh.triangles = triangles
end

function MeshTest:DrawRadar(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial(Color.red)
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local segments = 5
    local valueList = {0.9, 0.6, 0.8, 0.5, 0.7}
    local vertices = {}
    local radius = 50
    table.insert(vertices, Vector3(position.x, position.y, position.z))
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta + 18)
        local x = math.cos(radian) * radius * valueList[i]
        local y = math.sin(radian) * radius * valueList[i]
        table.insert(vertices, Vector3(position.x + x, position.y + y, position.z))
    end
    mesh.vertices = vertices
    local triangles = {}
    for i = 1, segments - 1 do
        table.insert(triangles, 0)
        table.insert(triangles, i + 1)
        table.insert(triangles, i)
    end
    table.insert(triangles, 0)
    table.insert(triangles, 1)
    table.insert(triangles, #vertices - 1)
    mesh.triangles = triangles
end

function MeshTest:DrawCube(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local vertices = {}
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z - 5))
    table.insert(vertices, Vector3(position.x + 100, position.y + 0, position.z - 5))
    table.insert(vertices, Vector3(position.x + 0, position.y + 100, position.z - 5))
    table.insert(vertices, Vector3(position.x + 100, position.y + 100, position.z - 5))

    table.insert(vertices, Vector3(position.x + 105, position.y + 0, position.z + 0))
    table.insert(vertices, Vector3(position.x + 105, position.y + 0, position.z + 100))
    table.insert(vertices, Vector3(position.x + 105, position.y + 100, position.z + 0))
    table.insert(vertices, Vector3(position.x + 105, position.y + 100, position.z + 100))

    table.insert(vertices, Vector3(position.x + 100, position.y + 0, position.z + 105))
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + 105))
    table.insert(vertices, Vector3(position.x + 100, position.y + 100, position.z + 105))
    table.insert(vertices, Vector3(position.x + 0, position.y + 100, position.z + 105))

    table.insert(vertices, Vector3(position.x - 5, position.y + 0, position.z + 100))
    table.insert(vertices, Vector3(position.x - 5, position.y + 0, position.z + 0))
    table.insert(vertices, Vector3(position.x - 5, position.y + 100, position.z + 100))
    table.insert(vertices, Vector3(position.x - 5, position.y + 100, position.z + 0))

    table.insert(vertices, Vector3(position.x + 0, position.y + 105, position.z + 0))
    table.insert(vertices, Vector3(position.x + 100, position.y + 105, position.z + 0))
    table.insert(vertices, Vector3(position.x + 0, position.y + 105, position.z + 100))
    table.insert(vertices, Vector3(position.x + 100, position.y + 105, position.z + 100))

    table.insert(vertices, Vector3(position.x + 0, position.y - 5, position.z + 100))
    table.insert(vertices, Vector3(position.x + 100, position.y - 5, position.z + 100))
    table.insert(vertices, Vector3(position.x + 0, position.y - 5, position.z + 0))
    table.insert(vertices, Vector3(position.x + 100, position.y - 5, position.z + 0))
    mesh.vertices = vertices

    local triangles = {}
    for i = 1, 6 do
        local index = (i - 1) * 4 + 1
        table.insert(triangles, index)
        table.insert(triangles, index - 1)
        table.insert(triangles, index + 1)

        table.insert(triangles, index)
        table.insert(triangles, index + 1)
        table.insert(triangles, index + 2)
    end
    mesh.triangles = triangles
end

function MeshTest:DrawOctahedron(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local vertices = {}
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z - 50))
    table.insert(vertices, Vector3(position.x + 50, position.y + 0, position.z - 0))
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + 50))
    table.insert(vertices, Vector3(position.x - 50, position.y + 0, position.z + 0))
    table.insert(vertices, Vector3(position.x - 0, position.y + 50, position.z + 0))
    table.insert(vertices, Vector3(position.x - 0, position.y - 50, position.z + 0))
    mesh.vertices = vertices

    local triangles = {
        0, 5, 1,
        1, 5, 2,
        2, 5, 3,
        3, 5, 0,
        0, 1, 4,
        1, 2, 4,
        2, 3, 4,
        3, 0, 4,
    }
    mesh.triangles = triangles
end

function MeshTest:DrawSphere(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    go:GetComponent(MeshRenderer).material = self:GetMaterial()
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()

    local top = Vector3(0, 1, 0)
    local bottom = Vector3(0, -1, 0)
    local left = Vector3(-1, 0, 0)
    local front = Vector3(0, 0, -1)
    local right = Vector3(1, 0, 0)
    local back = Vector3(0, 0, 1)

    local divideTimes = 16
    local vertices = self:GetSphereVertices(divideTimes, top, bottom, left, front, right, back)
    -- UtilsBase.dump(vertices)
    local radius = 50
    for i = 1, #vertices do
        vertices[i] = self.transform.position + vertices[i].normalized * radius
    end
    mesh.vertices = vertices

    local triangles = self:GetSphereTriangles(divideTimes)
    mesh.triangles = triangles
end

function MeshTest:GetSphereVertices(divideTimes, top, bottom, left, front, right, back)
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

function MeshTest:InsertLineVertices(vertices, divideTimes, i, topOrBottom, left, front, right, back)
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

function MeshTest:GetSphereTriangles(divideTimes)
    local triangles = {}
    local parentStartIndex = 0
    local startIndex = parentStartIndex + 1
    local parentStartIndex, startIndex = self:GetSphereUpperTriangles(triangles, divideTimes, parentStartIndex, startIndex)
    self:GetSphereLowerTriangles(triangles, divideTimes, parentStartIndex, startIndex)
    -- UtilsBase.dump(triangles)
    return triangles
end

function MeshTest:GetSphereUpperTriangles(triangles, divideTimes, parentStartIndex, startIndex)
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

function MeshTest:GetSphereLowerTriangles(triangles, divideTimes, parentStartIndex, startIndex)
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

function MeshTest:DrawTriangleTexture(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position

    mesh.vertices = {
        Vector3(position.x, position.y, position.z),
        Vector3(position.x, position.y + 100, position.z),
        Vector3(position.x + 100, position.y + 100, position.z),
    }
    mesh.triangles = {
        0, 1, 2,
    }
    mesh.uv = {
        Vector2(0, 0),
        Vector2(0, 1),
        Vector2(1, 1),
    }
end

function MeshTest:DrawSquareTexture(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position

    mesh.vertices = {
        Vector3(position.x, position.y, position.z),
        Vector3(position.x, position.y + 100, position.z),
        Vector3(position.x + 100, position.y + 100, position.z),
        Vector3(position.x + 100, position.y, position.z),
    }
    mesh.triangles = {
        0, 1, 2,
        0, 2, 3,
    }
    mesh.uv = {
        Vector2(0, 0),
        Vector2(0, 1),
        Vector2(1, 1),
        Vector2(1, 0),
    }
end

function MeshTest:DrawCircleTexture(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local segments = 60
    local vertices = {}
    local radius = 50
    table.insert(vertices, Vector3(position.x, position.y, position.z))
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        local x = math.cos(radian) * radius
        local y = math.sin(radian) * radius
        table.insert(vertices, Vector3(position.x + x, position.y + y, position.z))
    end
    mesh.vertices = vertices
    local triangles = {}
    for i = 1, segments - 1 do
        table.insert(triangles, 0)
        table.insert(triangles, i + 1)
        table.insert(triangles, i)
    end
    table.insert(triangles, 0)
    table.insert(triangles, 1)
    table.insert(triangles, #vertices - 1)
    mesh.triangles = triangles

    local uv = {}
    table.insert(uv, Vector2(0.5, 0.5))
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        local x = math.cos(radian)
        local y = math.sin(radian)
        table.insert(uv, Vector2(0.5 + 0.5 * x, 0.5 + 0.5 * y))
    end
    mesh.uv = uv
end

function MeshTest:DrawRingTexture(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local segments = 60
    local vertices = {}
    local sRadius = 30
    local bRadius = 50
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        table.insert(vertices, Vector3(position.x + math.cos(radian) * sRadius, position.y + math.sin(radian) * sRadius, position.z))
        table.insert(vertices, Vector3(position.x + math.cos(radian) * bRadius, position.y + math.sin(radian) * bRadius, position.z))
    end
    mesh.vertices = vertices
    local uv = {}
    local delta = 360 / segments
    for i = 1, segments do
        local radian = math.rad((i - 1) * delta)
        table.insert(uv, Vector2(0.5 + math.cos(radian) * 0.3, 0.5 + math.sin(radian) * 0.3))
        table.insert(uv, Vector2(0.5 + math.cos(radian) * 0.5, 0.5 + math.sin(radian) * 0.5))
    end
    mesh.uv = uv
    local triangles = {}
    for i = 1, #vertices - 2, 2 do
        table.insert(triangles, i - 1)
        table.insert(triangles, i + 1)
        table.insert(triangles, i)

        table.insert(triangles, i)
        table.insert(triangles, i + 1)
        table.insert(triangles, i + 2)
    end

    table.insert(triangles, #vertices - 2)
    table.insert(triangles, 0)
    table.insert(triangles, #vertices - 1)

    table.insert(triangles, #vertices - 1)
    table.insert(triangles, 0)
    table.insert(triangles, 1)
    mesh.triangles = triangles
end

function MeshTest:DrawCubeTexture(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position
    local vertices = {}

    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z - 0))
    table.insert(vertices, Vector3(position.x + 100, position.y + 0, position.z - 0))
    table.insert(vertices, Vector3(position.x + 0, position.y + 100, position.z - 0))
    table.insert(vertices, Vector3(position.x + 100, position.y + 100, position.z - 0))

    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + 100))
    table.insert(vertices, Vector3(position.x + 100, position.y + 0, position.z + 100))
    table.insert(vertices, Vector3(position.x + 0, position.y + 100, position.z + 100))
    table.insert(vertices, Vector3(position.x + 100, position.y + 100, position.z + 100))

    --上下两个面的冗余顶点，为了正确显示贴图
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z - 0))
    table.insert(vertices, Vector3(position.x + 100, position.y + 0, position.z - 0))
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + 100))
    table.insert(vertices, Vector3(position.x + 100, position.y + 0, position.z + 100))

    table.insert(vertices, Vector3(position.x + 0, position.y + 100, position.z - 0))
    table.insert(vertices, Vector3(position.x + 100, position.y + 100, position.z - 0))
    table.insert(vertices, Vector3(position.x + 0, position.y + 100, position.z + 100))
    table.insert(vertices, Vector3(position.x + 100, position.y + 100, position.z + 100))
    mesh.vertices = vertices

    local triangles = {
        0, 2, 3,
        0, 3, 1,
        1, 3, 7,
        1, 7, 5,
        5, 7, 6,
        5, 6, 4,
        4, 6, 2,
        4, 2, 0,
        12, 14, 15,
        12, 15, 13,
        10, 8, 9,
        10, 9, 11,
    }
    mesh.triangles = triangles

    local uv = {}
    table.insert(uv, Vector2(0, 0))
    table.insert(uv, Vector2(1, 0))
    table.insert(uv, Vector2(0, 1))
    table.insert(uv, Vector2(1, 1))

    table.insert(uv, Vector2(1, 0))
    table.insert(uv, Vector2(0, 0))
    table.insert(uv, Vector2(1, 1))
    table.insert(uv, Vector2(0, 1))

    table.insert(uv, Vector2(0, 0))
    table.insert(uv, Vector2(1, 0))
    table.insert(uv, Vector2(0, 1))
    table.insert(uv, Vector2(1, 1))
    table.insert(uv, Vector2(0, 0))
    table.insert(uv, Vector2(1, 0))
    table.insert(uv, Vector2(0, 1))
    table.insert(uv, Vector2(1, 1))
    mesh.uv = uv
end

function MeshTest:DrawCubeTexture1(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    local position = self.transform.position

    local r = 100
    local vertices = {}
    local uv = {}

    local w = 1/4
    local h = 1/3

    --front
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + 0))
    table.insert(uv, Vector2(w, h))
    table.insert(vertices, Vector3(position.x + r, position.y + 0, position.z + 0))
    table.insert(uv, Vector2(2 * w, h))
    table.insert(vertices, Vector3(position.x + 0, position.y + r, position.z + 0))
    table.insert(uv, Vector2(w, 2 * h))
    table.insert(vertices, Vector3(position.x + r, position.y + r, position.z + 0))
    table.insert(uv, Vector2(2 * w, 2 * h))

    --right
    table.insert(vertices, Vector3(position.x + r, position.y + 0, position.z + 0))
    table.insert(uv, Vector2(2 * w, h))
    table.insert(vertices, Vector3(position.x + r, position.y + 0, position.z + r))
    table.insert(uv, Vector2(3 * w, h))
    table.insert(vertices, Vector3(position.x + r, position.y + r, position.z + 0))
    table.insert(uv, Vector2(2 * w, 2 * h))
    table.insert(vertices, Vector3(position.x + r, position.y + r, position.z + r))
    table.insert(uv, Vector2(3 * w, 2 * h))

    --back
    table.insert(vertices, Vector3(position.x + r, position.y + 0, position.z + r))
    table.insert(uv, Vector2(3 * w, h))
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + r))
    table.insert(uv, Vector2(4 * w, h))
    table.insert(vertices, Vector3(position.x + r, position.y + r, position.z + r))
    table.insert(uv, Vector2(3 * w, 2 * h))
    table.insert(vertices, Vector3(position.x + 0, position.y + r, position.z + r))
    table.insert(uv, Vector2(4 * w, 2 * h))

    --left
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + r))
    table.insert(uv, Vector2(0, h))
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + 0))
    table.insert(uv, Vector2(w, h))
    table.insert(vertices, Vector3(position.x + 0, position.y + r, position.z + r))
    table.insert(uv, Vector2(0, 2 * h))
    table.insert(vertices, Vector3(position.x + 0, position.y + r, position.z + 0))
    table.insert(uv, Vector2(w, 2 * h))

    --top
    table.insert(vertices, Vector3(position.x + 0, position.y + r, position.z + 0))
    table.insert(uv, Vector2(w, 2 * h))
    table.insert(vertices, Vector3(position.x + r, position.y + r, position.z + 0))
    table.insert(uv, Vector2(2 * w, 2 * h))
    table.insert(vertices, Vector3(position.x + 0, position.y + r, position.z + r))
    table.insert(uv, Vector2(w, 3 * h))
    table.insert(vertices, Vector3(position.x + r, position.y + r, position.z + r))
    table.insert(uv, Vector2(2 * w, 3 * h))

    --bottom
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + r))
    table.insert(uv, Vector2(w, 0))
    table.insert(vertices, Vector3(position.x + r, position.y + 0, position.z + r))
    table.insert(uv, Vector2(2 * w, 0))
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + 0))
    table.insert(uv, Vector2(w, h))
    table.insert(vertices, Vector3(position.x + r, position.y + 0, position.z + 0))
    table.insert(uv, Vector2(2 * w, h))

    mesh.vertices = vertices
    mesh.uv = uv

    local triangles = {}
    for i = 1, #vertices, 4 do
        table.insert(triangles, i - 1)
        table.insert(triangles, i + 1)
        table.insert(triangles, i + 2)

        table.insert(triangles, i - 1)
        table.insert(triangles, i + 2)
        table.insert(triangles, i)
    end
    mesh.triangles = triangles
end

