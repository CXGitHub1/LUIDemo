using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

public class LMesh : Graphic
{
    protected override void OnPopulateMesh(VertexHelper vh)
    {
        //base.OnPopulateMesh(vh);
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
        //float radius = 50;
        for(int i = 0; i < segment; i++)
        {
            Debug.LogError(18 + i * delta);
            float radian = Mathf.Deg2Rad * (18 + i * delta);
            float x = Mathf.Cos(radian) * radius;
            float y = Mathf.Sin(radian) * radius;
            vh.AddVert(origin + new Vector3(x, y), color32, new Vector2(0, 0));
        }

        for(int i = 0; i < segment - 1; i++)
        {
            vh.AddTriangle(0, i + 2, i + 1);
        }
        vh.AddTriangle(0, 1, (int)segment);
    }
}
