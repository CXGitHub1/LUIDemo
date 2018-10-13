using SLua;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class TestMain : MonoBehaviour
{
    private LuaFunction _luaUpdate = null;

    private HashSet<string> _ignoreNameHash = new HashSet<string>()
    {

    };

    public delegate string[] GetPriorPathListDelegate();

    public static GetPriorPathListDelegate GetPriorPathArray;

	void Awake()
    {
        LuaSvr svr = new LuaSvr();
        LuaSvr.mainState.loaderDelegate += ReadFile;
        LuaSvr.MainState luaState = LuaSvr.mainState;

        string luaRoot = Directory.GetCurrentDirectory() + "../../Lua/";
        luaRoot = luaRoot.Replace("\\", "/");
        List<string> pathList = Utils.GetFilesRecursive(luaRoot);
        Dictionary<string, string> fileNameDict = new Dictionary<string, string>();

        for (int i = 0; i < pathList.Count; i++)
        {
            string path = pathList[i];
            if(!path.EndsWith(".lua"))
            {
                continue;
            }
            string fileName = Utils.GetFileName(path);
            fileNameDict.Add(fileName, path.Replace(luaRoot, string.Empty));
        }

        svr.init(null, () =>
        {
            Application.targetFrameRate = 30;
            svr.start("TestMain");
            string[] priorPathArray = GetPriorPathArray.Invoke();
            HashSet<string> loadedHash = new HashSet<string>();
            for(int i = 0; i < priorPathArray.Length; i++)
            {
                loadedHash.Add(priorPathArray[i]);
            }
            foreach(string fileName in fileNameDict.Keys)
            {
                if(!loadedHash.Contains(fileName))
                {
                    luaState.doString(string.Format("require('{0}')"), fileNameDict[fileName]);
                }
            }
            _luaUpdate = LuaSvr.mainState.getFunction("Update");
            LuaFunction main = LuaSvr.mainState.getFunction("Main");
            main.call();
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
