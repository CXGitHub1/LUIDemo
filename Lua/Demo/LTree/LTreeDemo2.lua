--二级列表
LTreeDemo2 = LTreeDemo2 or BaseClass(BaseDemo)

LTreeDemo2.Config = {
    {
        name = "成就1",
        value = 1,
        dataList =
        {
            {name = "成就1_1", value = 2},
            {name = "成就1_2", value = 2},
            {name = "成就1_3", value = 2},
            {name = "成就1_4", value = 2},
            {name = "成就1_5", value = 2},
            {name = "成就1_6", value = 2},
        }
    },
    {
        name = "成就2",
        value = 16,
        dataList =
        {
            {name = "成就2_1", value = 21},
            {name = "成就2_2", value = 22},
            {name = "成就2_3", value = 23},
        }
    },
    {
        name = "成就3",
        value = 13,
        dataList =
        {
            {name = "成就3_1", value = 31},
            {name = "成就3_2", value = 32},
            {name = "成就3_3", value = 33},
            {name = "成就3_4", value = 34},
            {name = "成就3_5", value = 35},
            {name = "成就3_6", value = 36},
            {name = "成就3_7", value = 37},
            {name = "成就3_8", value = 38},
            {name = "成就3_9", value = 39},
            {name = "成就3_10", value = 310},
            {name = "成就3_11", value = 311},
            {name = "成就3_12", value = 312},
            {name = "成就3_13", value = 313},
            {name = "成就3_14", value = 314},
        }
    },
    {
        name = "成就4",
        value = 46,
        dataList =
        {
            {name = "成就4_1", value = 41},
            {name = "成就4_2", value = 42},
            {name = "成就4_3", value = 43},
        }
    },
    {
        name = "成就5",
        value = 56,
    },
    {
        name = "成就6",
        value = 66,
    },
    {
        name = "成就7",
        value = 66,
        dataList =
        {
            {name = "成就7_1", value = 61},
            {name = "成就7_2", value = 62},
            {name = "成就7_3", value = 63},
        }
    },
}

function LTreeDemo2:__init(transform)
    self.lTree = LTree.New(transform:Find("Test"), LTreeNodeDemo2_1, {[2] = LTreeNodeDemo2_2})
    self.lTree.NodeSelectEvent:AddListener(function(rootNodeData, key, node)
        self.lTree:SetData(rootNodeData, key)
        local nodeData = node.nodeData
        if nodeData.expand then
            local childList = nodeData:GetChildList()
            for i = 1, #childList do
                local childNodeData = childList[i]
                local node = self.lTree:GetNode(childNodeData:GetKey())
                if node then
                    node:SetActive(false)
                    UtilsUI.SetAnchoredY(node.transform, childNodeData:GetY() - 50)
                    local ltDescr = Tween.Instance:MoveLocalY(node.gameObject, childNodeData:GetY(), 0.1)
                    ltDescr:setDelay((i - 1) * 0.05)
                    ltDescr:setOnStart(function()
                        node:SetActive(true)
                    end)
                end
            end
        end
    end)
    self.lTree.LeafSelectEvent:AddListener(function(rootNodeData, key, node)
        self.lTree:SetData(rootNodeData, key)
    end)
    self.lTree:SetGap(50, 5)
end

function LTreeDemo2:SetData()
    local rootData = LTree.GetRootNodeData()
    LTree.InitTree(rootData, LTreeDemo2.Config, LTreeNodeDataDemo1, {[2] = LTreeNodeDataDemo2_2})
    -- LTree.Dump(rootData)
    self.lTree:SetData(rootData)
end
