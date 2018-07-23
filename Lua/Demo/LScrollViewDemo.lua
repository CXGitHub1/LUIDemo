--chen quan
LScrollViewDemo = LScrollViewDemo or BaseClass(BaseDemo)

LScrollViewDemo.Config = {
    {column = 2, dataLength = 20, sizeType = TestDefine.SizeType.specified2},
    {row = 3, dataLength = 10000, startIndex = 1000, gapVertical = 10, gapHorizontal = 10, TestDefine.SizeType.fix},
    {column = 3, dataLength = 20, startIndex = 2, gapVertical = 10, gapHorizontal = 10,
        paddingLeft = 5, paddingRight = 20, paddingTop = 40, paddingBottom = 50,
        sizeType = TestDefine.SizeType.specified2},
    {column = 2, dataLength = 20, sizeType = TestDefine.SizeType.specified2}, --sendCallback
    --普通应用
    --游戏应用
    --成就界面
    --无限滑动？
}

function LScrollViewDemo:__init()
end