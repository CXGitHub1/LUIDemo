using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

public class Utils
{
    /// <summary>
    /// 递归查找指定目录下的所有文件
    /// <param name="path">目标路径</param>
    /// </summary>
    public static List<string> GetFilesRecursive(string path)
    {
        var files = new List<string>();
        DoGetFilesRecursive(path, ref files);
        return files;
    }

    // 执行文件查找
    private static void DoGetFilesRecursive(string path, ref List<string> files)
    {
        foreach (var file in Directory.GetFiles(path))
        {
            files.Add(file.Replace("\\", "/"));
        }
        foreach (var dir in Directory.GetDirectories(path))
        {
            DoGetFilesRecursive(dir, ref files);
        }
    }

    public static string GetFileName(string path)
    {
        int startIndex = path.LastIndexOf("/") + 1;
        int endIndex = path.LastIndexOf(".");
        return path.Substring(startIndex, endIndex - startIndex);
    }

    public static string GetFileName(string path)
    {

    }

}
