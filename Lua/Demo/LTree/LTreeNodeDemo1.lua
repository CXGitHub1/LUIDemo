LTreeNodeDemo1 = LTreeNodeDemo1 or BaseClass(LTreeNode)

function LTreeNodeDemo1:__init(gameObject, key)
    local transform = self.transform
    self.transform = transform
    self.folderBgGo = transform:Find("FolderBg").gameObject
    self.fileBgGo = transform:Find("FileBg").gameObject
    self.text = transform:Find("Text"):GetComponent(Text)
    self.selectGo = transform:Find("Select").gameObject
    self.arrowGo = transform:Find("Arrow").gameObject
end

function LTreeNodeDemo1:SetData(nodeData, commonData)
    self.nodeData = nodeData
    local data = nodeData.data
    if data.isFolder then
        self.folderBgGo:SetActive(true)
        self.fileBgGo:SetActive(false)
    else
        self.fileBgGo:SetActive(true)
        self.folderBgGo:SetActive(false)
    end
    self.text.text = data.name
    self.selectGo:SetActive(commonData == self.key)
    if nodeData:HaveChild() then
        self.arrowGo:SetActive(true)
        if nodeData.expand then
            self.arrowGo.transform.eulerAngles = Vector3(0, 0, -45)
        else
            self.arrowGo.transform.eulerAngles = Vector3(0, 0, 0)
        end
    else
        self.arrowGo:SetActive(false)
    end
end

