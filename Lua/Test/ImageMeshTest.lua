ImageMeshTest = ImageMeshTest or BaseClass(BaseTest)

ImageMeshTest.ColorDict = {
    Color(1, 0, 0, 1),
    Color(0, 1, 0, 1),
    Color(0, 0, 1, 1),
    Color(1, 1, 0, 1),
    Color(0, 1, 1, 1),
    Color(1, 0, 1, 1),
}

function ImageMeshTest:__init(gameObject)
    local transform = gameObject.transform
    self:AddListener(transform:Find("Test1"),
        function(rect, vertexHelper)
            self:DrawRadar(rect, vertexHelper)
    end)
end

function ImageMeshTest:AddListener(transform, cb)
    local lMesh = transform.gameObject:GetComponent(LMesh)
    print("AddListener")
    transform.gameObject:SetActive(true)
    lMesh.g = cb
    -- lMesh.OnPopulateMeshEvent:AddListener(cb)
end

function ImageMeshTest:DrawRadar(rect, vh)
    print("EEEEEEEEEEEEEEEEE")
    -- do return vh end
    print("DDDDDDDDDDDDDDDDD")
    local left = rect.x
    local right = rect.x + rect.width
    local bottom = rect.y
    local top = rect.y + rect.height;
    vh:Clear()

    local origin = Vector3((left + right) / 2, (bottom + top) / 2, 0)
    print(origin)
    print(Color.white)
    print(Vector2(0, 0))
    local vertex = UIVertex()
    vertex.position = origin
    vertex.color = Color.white
    -- vh:AddVert(origin, Color.white, Vector2(0, 0))
    vh:AddVert(vertex)
    local segment = 5
    local delta = 360 / segment
    local radius = 50
    for i = 1, segment do
        local radian = math.rad(18 + (i - 1) * delta)
        local x = math.cos(radian) * radius
        local y = math.sin(radian) * radius
        local vertex = UIVertex()
        vertex.position = origin + Vector3(x, y)
        vh:AddVert(vertex)
        -- vh:AddVert(origin + Vector3(x, y), ImageMeshTest.ColorDict[i + 1], Vector2(0, 0))
    end

    for i = 1, segment - 1 do
        vh:AddTriangle(0, i + 2, i + 1)
    end
    vh:AddTriangle(0, 1, segment)
    return vh
end
