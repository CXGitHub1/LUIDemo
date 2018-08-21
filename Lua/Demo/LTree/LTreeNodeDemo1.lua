LTreeNodeDemo1 = LTreeNodeDemo1 or BaseClass(LTreeNode)

function LTreeNodeDemo1:__init(gameObject, key)
    local transform = self.transform
    self.transform = transform
    self.folderBgGo = transform:Find("FolderBg").gameObject
    self.fileBgGo = transform:Find("FileBg").gameObject
    self.text = transform:Find("Text"):GetComponent(Text)
    self.selectGo = transform:Find("Select").gameObject
end

-- function LTreeNodeDemo1:__release()
-- end

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
end

