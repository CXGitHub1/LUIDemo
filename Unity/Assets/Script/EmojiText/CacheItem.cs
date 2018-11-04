using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class CacheItem
{
    public static readonly Vector3 HIDE_POSITION = new Vector3(10000, 10000, 0);
    public bool Used = false;
    public GameObject Go;
    public RectTransform RectTrans;

    public CacheItem() { }

    public virtual void Init(GameObject go, Transform parent)
    {
        this.Go = go;
        this.RectTrans = go.GetComponent<RectTransform>();
        this.RectTrans.SetParent(parent);
        this.RectTrans.localScale = Vector3.one;
        this.RectTrans.localRotation = Quaternion.identity;
        this.RectTrans.pivot = Vector2.zero;
        this.RectTrans.anchorMin = Vector2.zero;
        this.RectTrans.anchorMax = Vector2.zero;
    }

    public virtual void SetActive(bool active)
    {
        if(!active)
        {
            this.RectTrans.anchoredPosition = HIDE_POSITION;
        }
    }

    public virtual void InitFromPool(Transform parent)
    {
        this.RectTrans.SetParent(parent);
        this.RectTrans.localScale = Vector3.one;
        this.RectTrans.localRotation = Quaternion.identity;
        this.RectTrans.pivot = Vector2.zero;
        this.RectTrans.anchorMin = Vector2.zero;
        this.RectTrans.anchorMax = Vector2.zero;
    }
}