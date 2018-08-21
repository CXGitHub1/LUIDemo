--简单文件系统
LTreeDemo1 = LTreeDemo1 or BaseClass(BaseDemo)

LTreeDemo1.Config = {
    {
        name = "我的电脑",
        isFolder = true,
        dataList =
        {
            {name = "C盘",
            isFolder = true,
            dataList = 
                {
                    {name = "文件1"},
                    {name = "文件2"},
                    {name = "文件3"},
                    {name = "文件4"},
                    {name = "文件5"},
                }
            },
            {name = "D盘",
            isFolder = true,
            dataList =
                {
                    {name = "文件1"},
                    {name = "文件2"},
                    {name = "文件3"},
                    {name = "文件4"},
                    {name = "文件5"},
                    {name = "文件6"},
                    {name = "文件7"},
                    {name = "文件8"},
                    {name = "文件9"},
                    {name = "文件10"},
                }
            },
            {name = "E盘",
            isFolder = true,
            dataList =
                {
                    {name = "滚动组件",
                    isFolder = true,
                    dataList =
                        {
                            {name = "LScrollView"},
                            {name = "LScrollPage"},
                            {name = "LScrollTree"},
                        }
                    },
                    {name = "固定组件",
                    isFolder = true,
                    dataList =
                        {
                            {name = "LList"},
                        }
                    },
                }
            },

        }
    },
}

function LTreeDemo1:__init(transform)
    self.lTree = LTree.New(transform:Find("Test"), LTreeNodeDemo1)
    self.lTree.NodeSelectEvent:AddListener(function(rootNodeData, key, node)
        self.lTree:SetData(rootNodeData, key)
    end)
    self.lTree.LeafSelectEvent:AddListener(function(rootNodeData, key, node)
        self.lTree:SetData(rootNodeData, key)
    end)
    self.lTree:SetGap(20, 20)
end

function LTreeDemo1:SetData()
    local rootData = LTree.GetRootNodeData()
    LTree.InitTree(rootData, LTreeDemo1.Config)
    -- LTree.Dump(rootData)
    self.selectKey = nil
    self.lTree:SetData(rootData, self.selectKey)
end
