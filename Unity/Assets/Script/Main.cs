using SLua;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

[CustomLuaClass]
public class Main : MonoBehaviour
{
    public string MainFunName;
    private LuaFunction _luaUpdate = null;

    //一般不以Dictionary为参数，目前项目规模小，所以怎么方便怎么来
    //如果lua文件太多，再考虑如何优化
    public delegate void LoadLuaClassDelegate(Dictionary<string, string> dict);

    public static LoadLuaClassDelegate LoadLuaClass;

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
            LoadLuaClass.Invoke(luaClassNameDict);
            _luaUpdate = LuaSvr.mainState.getFunction("Update");
            LuaFunction main = LuaSvr.mainState.getFunction(MainFunName);
            main.call();
        });
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
