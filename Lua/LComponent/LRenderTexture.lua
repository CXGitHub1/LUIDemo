LRenderTexture = LRenderTexture or BaseClass()

function LRenderTexture:__init(name, parentTrans)
    self.name = name
    self.parentTrans = parentTrans
    self.width = parentTrans.sizeDelta.x
    self.height = parentTrans.sizeDelta.y
end

function LRenderTexture:__release()
end

function LRenderTexture:SetData()
    self:CreateCamera()
    self:CreateRawImage()
end

function LRenderTexture:CreateCamera()
    if self.cameraGo then
        return
    end

    local go = GameObject(self.name)
    local camera = go:AddComponent(Camera)
    camera.orthographic = false
    camera.backgroundColor = Color(0, 0, 0, 0)
    camera.clearFlags = CameraClearFlags.SolidColor
    camera.fieldOfView = 45
    camera.nearClipPlane = 0.3
    camera.farClipPlane = 10
    camera.cullingMask = LayerMask.NameToLayer("ModelPreview")
    camera.depth = 1

    local transform = go.transform
    transform:SetParent(GameObject.Find("ModelPreview"))
    transform.position = Vector3(0, 0, 0)
    self.render = RenderTexture.GetTemporary(self.sizeDelta.x * 1.5, self.height * 1.5, 24)

end

function LRenderTexture:CreateCamera()
end

