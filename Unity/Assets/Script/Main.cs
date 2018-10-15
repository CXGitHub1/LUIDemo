using SLua;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

[CustomLuaClass]
public class Main : MonoBehaviour
{
    public string MainFunName;
    private LuaFunction _luaUpdate = null;

    public delegate string[] LoadPriorClassDelegate();

    public static LoadPriorClassDelegate LoadPriorClass;

    void Awake()
    {
        Application.targetFrameRate = 30;
        LuaSvr svr = new LuaSvr();
        LuaSvr.mainState.loaderDelegate += LoadFile;
        LuaSvr.MainState luaState = LuaSvr.mainState;

        svr.init(null, () =>
        {
            Dictionary<string, string> luaClassNameDict = GetLuaClassNameDict();
            svr.start("Main");
            HashSet<string> LoadedPriorClassHash = GetLoadedClassNameHash();
            foreach (string fileName in luaClassNameDict.Keys)
            {
                if (!LoadedPriorClassHash.Contains(fileName))
                {
                    luaState.doString(string.Format("require('{0}')", luaClassNameDict[fileName]));
                }
            }
            _luaUpdate = LuaSvr.mainState.getFunction("Update");
            LuaFunction main = LuaSvr.mainState.getFunction(MainFunName);
            main.call();
        });
    }

    private HashSet<string> GetLoadedClassNameHash()
    {
        HashSet<string> result = new HashSet<string>();
        string[] LoadedClassNameArray = LoadPriorClass.Invoke();
        for (int i = 0; i < LoadedClassNameArray.Length; i++)
        {
            result.Add(LoadedClassNameArray[i]);
        }
        result.Add("Main");
        return result;
    }

    /// <summary>
    /// Dictionary key:lua name value:lua relative path
    /// </summary>
    /// <returns></returns>
    private Dictionary<string, string> GetLuaClassNameDict()
    {
        Dictionary<string, string> result = new Dictionary<string, string>();
        List<string> pathList = FileUtils.GetFilesRecursive(FileUtils.LUA_ROOT);
        for (int i = 0; i < pathList.Count; i++)
        {
            string path = pathList[i];
            if (!path.EndsWith(".lua"))
            {
                continue;
            }
            string fileName = FileUtils.GetFileName(path);
            path = path.Replace(FileUtils.LUA_ROOT, string.Empty);
            result.Add(fileName, path.Replace(".lua", string.Empty));
        }
        return result;
    }

    private byte[] LoadFile(string name)
    {
        string path = FileUtils.LUA_ROOT + name + ".lua";
        return File.ReadAllBytes(path);
    }

    void Update()
    {
        if (_luaUpdate != null)
        {
            _luaUpdate.call();
        }
    }
}
