MeshTest = MeshTest or BaseClass(BaseTest)

function MeshTest:__init(gameObject)
    local transform = gameObject.transform
    self:DrawTriangle(transform:Find("Test1"))
    -- self:DrawSquare(transform:Find("Test2"))
end

function MeshTest:DrawTriangle(transform)
    self.transform = transform or self.transform
    local go = self.transform.gameObject
    local mesh = go:GetComponent(MeshFilter).mesh
    mesh:Clear()
    mesh.vertices = {
        Vector3(0, 0, 0),
        Vector3(0, 1, 0),
        Vector3(1, 1, 0),
    }
    mesh.triangles = {
        0, 1, 2,
    }
end
