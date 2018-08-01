using SLua;
using System.IO;
using UnityEngine;

public class TestMain : MonoBehaviour
{
    private LuaFunction _luaStart = null;
    private LuaFunction _luaUpdate = null;

	void Awake()
    {
        LuaSvr svr = new LuaSvr();
        LuaSvr.mainState.loaderDelegate += ReadFile;

        svr.init(null, () =>
        {
            svr.start("TestMain");
            Application.targetFrameRate = 30;

            _luaUpdate = LuaSvr.mainState.getFunction("Update");
        });
	}

    private byte[] ReadFile(string name)
    {
        string path = Directory.GetCurrentDirectory() + "../../Lua/" + name + ".lua";
        return File.ReadAllBytes(path);
    }

    void Update()
    {
        if(_luaUpdate != null)
        {
            _luaUpdate.call();
        }
	}
}
