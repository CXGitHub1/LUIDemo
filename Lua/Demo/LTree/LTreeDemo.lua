LTreeDemo = LTreeDemo or BaseClass(BaseDemo)

LTreeDemo.Config = {
    {
        name = "组件类型",
        expand = true,
        dataList =
        {
            {name = "滚动组件",
            expand = true,
            dataList =
                {
                    {name = "LScrollView",
                    dataList =
                        {
                            {name = "测试1"},
                            {name = "测试2"},
                            {name = "测试3"},
                            {name = "测试4"},
                            {name = "测试5"},
                            {name = "测试6"},
                        }
                    },
                    {name = "LScrollPage",
                    dataList =
                        {
                            {name = "测试1"},
                            {name = "测试2"},
                            {name = "测试3"},
                            {name = "测试4"},
                            {name = "测试5"},
                            {name = "测试6"},
                        }
                    },
                    {name = "LScrollTree"},
                }
            },
            {name = "固定组件",
            dataList =
                {
                    {name = "LList",
                    dataList =
                        {
                            {name = "测试1"},
                            {name = "测试2"},
                            {name = "测试3"},
                            {name = "测试4"},
                            {name = "测试5"},
                            {name = "测试6"},
                        }
                    },
                }
            },
        }
    },
}

LTreeDemo.Config3 = {
    {
        name = "一级组件1",
        value = 1,
        expand = true,
        dataList =
        {
            {name = "二级组件1", value = 2},
            {name = "二级组件2", value = 3},
            {name = "二级组件3", value = 3},
            {name = "二级组件4", value = 3},
            {name = "二级组件5", value = 3},
            {name = "二级组件6", value = 3},
            {name = "二级组件7", value = 3},
            {name = "二级组件8", value = 3},
        },
    },
    {
        name = "一级组件2",
        value = 11,
        expand = true,
        dataList =
        {
            {name = "二级组件1", value = 2},
            {name = "二级组件2", value = 3},
            {name = "二级组件3", value = 3},
            {name = "二级组件4", value = 3},
        },
    },
    {
        name = "一级组件3",
        value = 21,
        expand = true,
        dataList =
        {
            {name = "二级组件1", value = 2},
            {name = "二级组件2", value = 3},
            {name = "二级组件3", value = 3},
            {name = "二级组件4", value = 3},
        },
    },
    {
        name = "一级组件4",
        value = 31,
        expand = true,
        dataList =
        {
            {name = "二级组件1", value = 2},
            {name = "二级组件2", value = 3},
            {name = "二级组件3", value = 3},
            {name = "二级组件4", value = 3},
            {name = "二级组件5", value = 3},
            {name = "二级组件6", value = 3},
            {name = "二级组件7", value = 3},
            {name = "二级组件8", value = 3},
        },
    },
}

function LTreeDemo:__init(transform)
    local tree = LTree.New(transform:Find("Test1"), LTreeNodeDemo)
    tree:SetGap(50, 5)
    self.lTree1 = tree

    local tree = LTree.New(transform:Find("Test2"), LTreeNodeDemo)
    tree:SetGap(20, 5)
    transform:Find("Button1").gameObject:SetActive(true)
    UtilsUI.AddButtonListener(transform, "Button1", function()
        local rootData = LTree.GetRootNodeData()
        LTree.InitTree(rootData, self:CreateTreeData())
        tree:SetData(rootData)
    end)
    transform:Find("Button2").gameObject:SetActive(true)
    transform:Find("InputField").gameObject:SetActive(true)
    UtilsUI.AddButtonListener(transform, "Button2", function()
        local key = transform:Find("InputField"):GetComponent(InputField).text
        tree:Focus(key)
    end)
    self.lTree2 = tree

    local tree = LTree.New(transform:Find("Test3"), LTreeNodeDemo_1, {LTreeNodeDemo})
    tree:SetGap(40)
    self.lTree3 = tree
end

function LTreeDemo:SetData()
    local rootData = LTree.GetRootNodeData()
    LTree.InitTree(rootData, LTreeDemo.Config)
    self.lTree1:SetData(rootData)

    local rootData = LTree.GetRootNodeData()
    LTree.InitTree(rootData, self:CreateTreeData())
    self.lTree2:SetData(rootData)

    local rootData = LTree.GetRootNodeData()
    LTree.InitTree(rootData, LTreeDemo.Config3)
    self.lTree3:SetData(rootData)
end


function LTreeDemo:CreateTreeData()
    local config = {}
    local value1 = math.random(0, 5)
    for i = 1, value1 do
        local config1 = {name = i, expand = true}
        local value2 = math.random(0, 5)
        config1.dataList = {}
        for j = 1, value2 do
            table.insert(config1.dataList, {name = j, expand = true})
        end
        table.insert(config, config1)
    end
    return config
end
