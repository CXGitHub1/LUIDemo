require("CommonRequire")

for i = 1, #DemoFileConfig do
	require(DemoFileConfig[i])
end

DemoManager.New(GameObject.Find("UIRoot").transform)

function Update()
    if Input.GetKeyDown(KeyCode.H) and Input.GetKey(KeyCode.LeftControl) then
    	for i = 1, #CommonFileConfig do
    		package.loaded[CommonFileConfig[i]] = nil
			require(CommonFileConfig[i])
		end
    	for i = 1, #DemoFileConfig do
    		package.loaded[DemoFileConfig[i]] = nil
			require(DemoFileConfig[i])
		end
		print("热更完毕")
    end
    if Input.GetKeyDown(KeyCode.Q) and Input.GetKey(KeyCode.LeftControl) then
        -- DemoManager.Instance:Release()
        -- DemoManager.Instance.demoList[6].lTree:Test()
    end
end
