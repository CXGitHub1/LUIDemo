UtilsTween = UtilsTween or {}

function UtilsTween.MoveX(gameObject, to, time, callback, type)
    local tweenId = Tween.Instance:MoveX(gameObject, to, time, callback, type):setIgnoreTimeScale(true).id
    return tweenId, UtilsTween.CanvasFadeIn(gameObject, time, type)
end

function UtilsTween.MoveY(gameObject, to, time, callback, type)
    local tweenId = Tween.Instance:MoveY(gameObject, to, time, callback, type):setIgnoreTimeScale(true).id
    return tweenId, UtilsTween.CanvasFadeIn(gameObject, time, type)
end

function UtilsTween.MoveLocalX(gameObject, to, time, callback, type)
    local tweenId = Tween.Instance:MoveLocalX(gameObject, to, time, callback, type):setIgnoreTimeScale(true).id
    return tweenId, UtilsTween.CanvasFadeIn(gameObject, time, type)
end

function UtilsTween.MoveLocalY(gameObject, to, time, callback, type)
    local tweenId = Tween.Instance:MoveLocalY(gameObject, to, time, callback, type):setIgnoreTimeScale(true).id
    return tweenId, UtilsTween.CanvasFadeIn(gameObject, time, type)
end

function UtilsTween.CanvasFadeIn(gameObject, time, type, startVal, delay)
    local canvas = gameObject:GetComponent(CanvasGroup)
    if not canvas then
        canvas = gameObject:AddComponent(CanvasGroup)
    end
    canvas.alpha = 0
    return Tween.Instance:ValueChange(startVal or 0, 1, time, nil, type, function(value) canvas.alpha = value end):setDelay(delay or 0):setIgnoreTimeScale(true).id
end

function UtilsTween.CanvasFadeOut(gameObject, time, type)
    local canvas = gameObject:GetComponent(CanvasGroup)
    if not canvas then
        canvas = gameObject:AddComponent(CanvasGroup)
    end
    canvas.alpha = 1
    return Tween.Instance:ValueChange(1, 0, time, nil, type, function(value) canvas.alpha = value end):setIgnoreTimeScale(true).id
end

function UtilsTween.Scale(gameObject, to, time, callback, type)
    local tweenId = Tween.Instance:Scale(gameObject, to, time, callback, type):setIgnoreTimeScale(true).id
    return tweenId, UtilsTween.CanvasFadeIn(gameObject, time, type)
end

function UtilsTween.MoveDown(gameObject, time, callback, fadeIn)
    local position = gameObject.transform.localPosition
    UtilsUI.SetY(gameObject.transform, position.y + 150)
    local tweenId1 = Tween.Instance:MoveLocalY(gameObject, position.y, time, callback, LeanTweenType.linear):setIgnoreTimeScale(true).id
    local tweenId2
    if fadeIn then
        tweenId2 = UtilsTween.CanvasFadeIn(gameObject, time, LeanTweenType.linear)
    else
        tweenId2 = UtilsTween.CanvasFadeOut(gameObject, time, LeanTweenType.linear)
    end
    return tweenId1, tweenId2
end

function UtilsTween.MoveUp(gameObject, time, callback, fadeIn, positionStay, y)
    local position = gameObject.transform.localPosition
    local tweenId1
    local tweenId2
    if positionStay then
        UtilsUI.SetY(gameObject.transform, position.y - (y or 150))
        tweenId1 = Tween.Instance:MoveLocalY(gameObject, position.y, time, callback, LeanTweenType.linear):setIgnoreTimeScale(true).id
    else
        tweenId1 = Tween.Instance:MoveLocalY(gameObject, position.y + 150, time, callback, LeanTweenType.linear):setIgnoreTimeScale(true).id
    end
    if fadeIn then
        tweenId2 = UtilsTween.CanvasFadeIn(gameObject, time, LeanTweenType.linear)
    else
        tweenId2 = UtilsTween.CanvasFadeOut(gameObject, time, LeanTweenType.linear)
    end
    return tweenId1, tweenId2
end

function UtilsTween.PanelMoveLeft(gameObject)
    return UtilsTween.MoveLeft(gameObject, 0.3, nil, true)
end

function UtilsTween.MoveLeft(gameObject, time, callback, fadeIn)
    local tweenIdList = {}
    local position = gameObject.transform.localPosition
    UtilsUI.SetX(gameObject.transform, position.x + 50)
    local tweenId1 = Tween.Instance:MoveLocalX(gameObject, position.x, time, callback, LeanTweenType.linear):setIgnoreTimeScale(true).id
    table.insert(tweenIdList, tweenId1)
    local tweenId2
    if fadeIn then
        tweenId2 = UtilsTween.CanvasFadeIn(gameObject, time, LeanTweenType.linear, 0.8)
    else
        tweenId2 = UtilsTween.CanvasFadeOut(gameObject, time, LeanTweenType.linear)
    end
    table.insert(tweenIdList, tweenId2)
    return tweenIdList
end

function UtilsTween.ZoomOut(gameObject, time, callback)
    local tweenIdList = {}
    local mainTrans = gameObject.transform
    UtilsUI.SetPivot(mainTrans, Vector2(0.5, 0.5))
    mainTrans.localScale = Vector3.one * 0.85
    local tweenId = Tween.Instance:Scale(mainTrans.gameObject, Vector3.one, time, callback, LeanTweenType.easeOutBack):setIgnoreTimeScale(true).id
    table.insert(tweenIdList, tweenId)
    tweenId = UtilsTween.CanvasFadeIn(mainTrans.gameObject, time, LeanTweenType.linear)
    table.insert(tweenIdList, tweenId)
    return tweenIdList
end

function UtilsTween.ZoomIn(gameObject, time, callback)
    local tweenIdList = {}
    local mainTrans = gameObject.transform
    UtilsUI.SetPivot(mainTrans, Vector2(0.5, 0.5))
    mainTrans.localScale = Vector3.one
    local tweenId = Tween.Instance:Scale(mainTrans.gameObject, Vector3.one * 0.85, time, callback, LeanTweenType.linear):setIgnoreTimeScale(true).id
    table.insert(tweenIdList, tweenId)
    tweenId = UtilsTween.CanvasFadeOut(mainTrans.gameObject, time, LeanTweenType.linear)
    table.insert(tweenIdList, tweenId)
    return tweenIdList
end

function UtilsTween.PanelMove(panelGo)
    local time = 0.2
    local tweenIdList = {}
    local bgTrans = panelGo.transform:Find("Panel")
    local tweenId = UtilsTween.CanvasFadeIn(bgTrans.gameObject, time, LeanTweenType.linear)
    table.insert(tweenIdList, tweenId)
    local mainTrans = panelGo.transform:Find("Main")
    local tweenId = UtilsTween.CanvasFadeIn(mainTrans.gameObject, time, LeanTweenType.linear)
    table.insert(tweenIdList, tweenId)
    local position = mainTrans.localPosition
    UtilsUI.SetY(mainTrans, position.y - 15)
    tweenId = Tween.Instance:MoveLocalY(mainTrans.gameObject, position.y, time, nil, LeanTweenType.linear):setIgnoreTimeScale(true).id
    table.insert(tweenIdList, tweenId)
    return tweenIdList
end

function UtilsTween.PanelCloseMove(panelGo, cb)
    local time = 0.2
    local tweenIdList = {}
    local bgTrans = panelGo.transform:Find("Panel")
    local tweenId = UtilsTween.CanvasFadeOut(bgTrans.gameObject, time, LeanTweenType.linear)
    table.insert(tweenIdList, tweenId)
    local mainTrans = panelGo.transform:Find("Main")
    tweenId = UtilsTween.CanvasFadeOut(mainTrans.gameObject, time, LeanTweenType.linear)
    table.insert(tweenIdList, tweenId)
    local position = mainTrans.localPosition
    UtilsUI.SetY(mainTrans, position.y)
    tweenId = Tween.Instance:MoveLocalY(mainTrans.gameObject, position.y - 15, time, function()
        UtilsUI.SetY(mainTrans, position.y)
        cb()
    end, LeanTweenType.linear):setIgnoreTimeScale(true).id
    table.insert(tweenIdList, tweenId)
    return tweenIdList
end
