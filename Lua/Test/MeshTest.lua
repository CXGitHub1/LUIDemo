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
    -- self:DrawCub(transform:Find("Test8"))
    self:DrawOctahedron(transform:Find("Test9"))
    self:DrawSphere(transform:Find("Test10"))
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

function MeshTest:DrawCub(transform)
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
    local position = self.transform.position
    local radius = 50
    local vertices = {}
    table.insert(vertices, Vector3(position.x + 0, position.y + 0, position.z + radius))
    mesh.vertices = vertices

    local triangles = {}
    mesh.triangles = triangles
end
