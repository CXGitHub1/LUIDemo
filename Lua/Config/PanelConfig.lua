PanelConfig = PanelConfig or {}


PanelOrder = {
    FirstPanel = 50,
    SecondPanel = 60,
    ThridPanel = 70,
}

--cacheTime 缓存时间
--fullScreen 全屏界面
--order 层次
--window 界面有且只有显示一个window 如果同时打开两个window，后者会隐藏前者
PanelConfig.Data = {
    [1] = {
            id = 1, className = "LoginWindow", cacheTime = 30, fullScreen = true, order = PanelOrder.FirstPanel, window = true,
            assetList = {
                {path = "LoginWindow"},
            },
          },
    [2] = {
            id = 2, className = "SelectWindow", cacheTime = 30, fullScreen = true, order = PanelOrder.FirstPanel, window = true,
            assetList = {
                {path = "SelectWindow"},
            },
          },
}