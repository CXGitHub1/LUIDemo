require("CommonRequire")

DemoManager.New(GameObject.Find("UIRoot").transform)

function Update()
    if Input.GetKeyDown(KeyCode.Q) and Input.GetKey(KeyCode.LeftControl) then
        DemoManager.Instance:Release()
    end
end
