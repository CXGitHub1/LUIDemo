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

    //用委托来解决override函数的问题，略别扭
    //也可以考虑直接在c#层实现
    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();
        if(g != null)
        {
            vh = g(GetPixelAdjustedRect(), vh);
        }
    }
}
