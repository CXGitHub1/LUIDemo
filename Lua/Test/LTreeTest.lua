LTreeTest = LTreeTest or BaseClass(BaseTest)

LTreeTest.Config = {
    {
        name = "总共",
        dataList =
        {
            {name = "滚动组件",
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
                            {name = "测试7"},
                            {name = "测试8"},
                            {name = "测试9"},
                        }
                    },
                    {name = "LScrollPage"},
                    {name = "LScrollTree"},
                }
            },
            {name = "固定组件",
            dataList =
                {
                    {name = "LList"}
                }
            },
        }
    },
}

function LTreeTest:__init(gameObject)
    local transform = gameObject.transform
    for i = 1, #LTreeTest.Config do
        local config = LTreeTest.Config[i]
        local tree = LTree.New(transform:Find("Test" .. i), LTreeNode)
        tree:SetData(config.dataList)
    end
end