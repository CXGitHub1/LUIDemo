--简单文件系统
LTreeDemo1 = LTreeDemo1 or BaseClass(BaseDemo)

LTreeDemo1.Config = {
    {
        name = "我的电脑",
        dataList =
        {
            {name = "C盘",
            isFolder = true,
            dataList = 
                {
                    {name = "文件夹1",
                    isFolder = true,
                    },
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
    self.lTree.ItemSelectEvent:AddListener(function(key, node)
        self.selectKey = key
        nodeData.expand = not nodeData.expand
        self.lTree:SetData(rootData, self.selectKey)
    end)
end

function LTreeDemo1:SetData()
    local rootData = LTree.InitTree(LTreeDemo1.Config[1], LTreeNodeDataDemo1)
    self.selectKey = nil
    self.lTree:SetData(rootData, self.selectKey)
end
