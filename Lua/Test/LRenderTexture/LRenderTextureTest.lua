LRenderTextureTest = LRenderTextureTest or BaseClass(BaseTest)

function LRenderTextureTest:__init(gameObject)
    local transform = gameObject.transform
    self.scrollPage = LScrollPage.New(transform:Find("Test1"), LRenderTextureTestItem, 1, 2, LDefine.Direction.horizontal)

    local dataList = {}
    for i = 0, 10 do
        table.insert(dataList, ModelLoaderData.New(80002 + i, 80002 + i, 80002 + i))
    end
    self.scrollPage:SetData(dataList)
end
