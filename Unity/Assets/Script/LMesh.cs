using SLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

[CustomLuaClass]
public class LMeshEvent : UnityEvent<Rect, VertexHelper> { }

[CustomLuaClass]
public class LMesh : Graphic
{
    public delegate VertexHelper GetVertexHelper(Rect rect, VertexHelper vh);
    public GetVertexHelper g;


    public LMeshEvent OnPopulateMeshEvent = new LMeshEvent();

    private Dictionary<int, Color> _colorDict = new Dictionary<int, Color>()
    {
        {0, new Color(1, 0, 0)},
        {1, new Color(0, 1, 0)},
        {2, new Color(0, 0, 1)},
        {3, new Color(1, 1, 0)},
        {4, new Color(1, 0, 1)},
    };

    //只是了为能在lua实现而改用事件派发的方式
    //就这种情况而言，直接在c#实现比较实际
    protected override void OnPopulateMesh(VertexHelper vh)
    {
        var r = GetPixelAdjustedRect();
        float left = r.x;
        float right = r.x + r.width;
        float bottom = r.y;
        float top = r.y + r.height;

        Color32 color32 = color;
        Vector3 origin = new Vector3((left + right) / 2, (bottom + top) / 2);
        vh.Clear();
        vh.AddVert(origin, color32, new Vector2(0f, 0f));
        float segment = 5;
        float delta = 360 / segment;
        float radius = 50;
        for (int i = 0; i < segment; i++)
        {
            float radian = Mathf.Deg2Rad * (18 + i * delta);
            float x = Mathf.Cos(radian) * radius;
            float y = Mathf.Sin(radian) * radius;
            vh.AddVert(origin + new Vector3(x, y), _colorDict[i], new Vector2(0, 0));
        }

        for (int i = 0; i < segment - 1; i++)
        {
            vh.AddTriangle(0, i + 2, i + 1);
        }
        vh.AddTriangle(0, 1, (int)segment);

        Debug.Log(vh.currentVertCount);
        vh = g(r, vh);
        Debug.Log(vh.currentVertCount);
        //Debug.LogError(vh.currentVertCount);
    }
}
