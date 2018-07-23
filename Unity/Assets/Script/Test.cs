using SLua;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class Test : MonoBehaviour {

    private LuaFunction _luaStart = null;
    private LuaFunction _luaUpdate = null;

	void Awake() {
        LuaSvr svr = new LuaSvr();
        LuaSvr.mainState.loaderDelegate += ReadFile;


        svr.init(null, () =>
        {
            svr.start("test");
            Application.targetFrameRate = 30;

            //_luaStart = LuaSvr.mainState.getFunction("Start");
            _luaUpdate = LuaSvr.mainState.getFunction("Update");
        });
	}

    private byte[] ReadFile(string name)
    {
        string path = Directory.GetCurrentDirectory() + "../../Lua/" + name + ".lua";
        return File.ReadAllBytes(path);
    }

    void Start() {
        if(_luaStart != null)
        {
            _luaStart.call();
        }
    }

    void Update () {
        if(_luaUpdate != null)
        {
            _luaUpdate.call();
        }
	}
}
