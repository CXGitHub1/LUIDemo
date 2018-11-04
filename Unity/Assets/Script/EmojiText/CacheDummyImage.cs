using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

public class CacheDummyImage : CacheItem
{
    public Button Button;

    public override void Init(GameObject go, Transform parent)
    {
        base.Init(go, parent);
        this.Button = go.GetComponent<Button>();
    }
}
