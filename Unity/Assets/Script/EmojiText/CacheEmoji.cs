using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class CacheEmoji : CacheItem
{
    public int Key;

    public override void InitFromPool(Transform parent)
    {
        base.InitFromPool(parent);
        SetActive(true);
    }

    public override void SetActive(bool active)
    {
        Go.SetActive(active);
    }
}
