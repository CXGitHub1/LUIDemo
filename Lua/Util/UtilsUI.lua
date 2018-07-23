-- --------------------------------
-- UI工具类
-- --------------------------------
local _SetLocalPosition = SetLocalPosition
local _SetLocalScale    = SetLocalScale
local _SetAPosition     = SetAPosition

UtilsUI = UtilsUI or BaseClass()
local UtilsUI = UtilsUI
-- ---------------------------------
-- 添加子对象到父容器，并做基础设置
-- ---------------------------------
local Vector2_zero = Vector2.zero
local Vector2_one = Vector2.one
local Vector3_zero = Vector3.zero
local Vector3_one = Vector3.one
local Vector2_zeroone = Vector2(0,1)
local Vector2_onezero = Vector2(1,0)
local Color_zero = Color.clear
local Color_one = Color.white

function UtilsUI.AddUIChild(parentObj, childObj)
	local trans = childObj.transform
	trans:SetParent(parentObj.transform)
	trans.localScale = Vector3_one
	trans.localPosition = Vector3_zero
	trans.localRotation = Quaternion.identity

	local rect = childObj:GetComponent(RectTransform)
	rect.anchorMax = Vector2_one
	rect.anchorMin = Vector2_zero
	rect.offsetMin = Vector2_zero
	rect.offsetMax = Vector2_zero
	rect.localScale = Vector3_one
	rect.localPosition = Vector3_zero
	rect.anchoredPosition3D = Vector3_zero
	childObj:SetActive(true)

	local canvas = childObj:GetComponent(Canvas)
	if canvas ~= nil then
		canvas.pixelPerfect = false;
		canvas.overrideSorting = true;
	end
end

function UtilsUI.AddBigbg(parentTransform, childObj)
	local childTransform = childObj.transform
	childTransform:SetParent(parentTransform)
	childTransform.localScale = Vector3_one
	childTransform.localPosition = Vector3_zero
    childTransform.anchoredPosition = Vector2_zero
end

function UtilsUI.AddHappyGirl(parentTransform, childObj, scale)
    scale = scale or Vector3_one
    local childTransform = childObj.transform
    childTransform:SetParent(parentTransform)
    UtilsBase.SetOrder(childObj, UIOrder.AssetsPanel)
    childTransform.localScale = scale
    childTransform.localPosition = Vector3(115,-300,0)
end

function UtilsUI.SetPivot(rect, newPivot)
	local sizeDelta = rect.sizeDelta
	local oldPivot = rect.pivot
	rect.pivot = newPivot
	local oldPosition = rect.anchoredPosition
	local newX = oldPosition.x + sizeDelta.x * (newPivot.x - oldPivot.x)
	local newY = oldPosition.y + sizeDelta.y * (newPivot.y - oldPivot.y)
	rect.anchoredPosition = Vector2(newX, newY)
end

function UtilsUI.CalculateSize(transform)
	if transform.childCount == 0 then
		transform.sizeDelta = Vector2(0, 0)
		return
	end
	local left, right, top, bottom = UtilsBase.INT32_MAX, UtilsBase.INT32_MIN, UtilsBase.INT32_MIN, UtilsBase.INT32_MAX
    local haveActiveChild = false
	for i = 1, transform.childCount do
		local rectChild = transform:GetChild(i - 1):GetComponent(RectTransform)
        --可能会加载特效，特效获取不到RectTransform
		if rectChild and rectChild.gameObject.activeInHierarchy then
            haveActiveChild = true
			local sizeDelta = rectChild.sizeDelta
            local pivot = rectChild.pivot
			local position = rectChild.localPosition
            local x = position.x - sizeDelta.x * pivot.x
            local y = position.y + (1 - pivot.y) * sizeDelta.y
			if x < left then left = x end
			if (x + sizeDelta.x) > right then right = x + sizeDelta.x end
			if y > top then top = y end
			if (y - sizeDelta.y) < bottom then bottom = y - sizeDelta.y end
		end
	end
    if haveActiveChild == false then
		transform.sizeDelta = Vector2(0, 0)
		return
    end
	transform.sizeDelta = Vector2(right - left, top - bottom)
end

function UtilsUI.GetCanvasWidth()
    return ctx.CanvasContainer.transform.sizeDelta.x
end

function UtilsUI.GetCanvasHeight()
    return ctx.CanvasContainer.transform.sizeDelta.y
end

function UtilsUI.GetGameObject(transform, path)
	if path == nil or path == "" then
		return transform.gameObject
	end
	return transform:Find(path).gameObject
end

function UtilsUI.GetTransform(transform, path)
	if path == nil or path == "" then
		return transform
	end
	return transform:Find(path)
end

function UtilsUI.GetRectTransform(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(RectTransform)
	end
	return transform:Find(path):GetComponent(RectTransform)
end

function UtilsUI.GetText(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(Text)
	end
	return transform:Find(path):GetComponent(Text)
end

function UtilsUI.GetImage(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(Image)
	end
	return transform:Find(path):GetComponent(Image)
end

function UtilsUI.GetButton(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(Button)
	end
	return transform:Find(path):GetComponent(Button)
end

function UtilsUI.GetInput(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(InputField)
	end
	return transform:Find(path):GetComponent(InputField)
end

function UtilsUI.GetScroll(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(ScrollRect)
	end
	return transform:Find(path):GetComponent(ScrollRect)
end

function UtilsUI.GetSlider(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(Slider)
    end
    return transform:Find(path):GetComponent(Slider)
end

function UtilsUI.GetToggle(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(Toggle)
	end
	return transform:Find(path):GetComponent(Toggle)
end

function UtilsUI.AddButtonListener(transform, path, callback)
	UtilsUI.GetButton(transform, path).onClick:AddListener(callback)
end

function UtilsUI.RemoveButtonListener(transform, path, callback)
    UtilsUI.GetButton(transform, path).onClick:RemoveListener(callback)
end

function UtilsUI.RemoveAllButtonListener(transform, path)
    UtilsUI.GetButton(transform, path).onClick:RemoveAllListeners()
end

function UtilsUI.GetCustomButton(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(CustomButton)
	end
	return transform:Find(path):GetComponent(CustomButton)
end

function UtilsUI.AddCustomClick(transform, path, callback)
	UtilsUI.GetCustomButton(transform, path).onClick:AddListener(callback)
end

function UtilsUI.AddCustomDown(transform, path, callback)
	UtilsUI.GetCustomButton(transform, path).onDown:AddListener(callback)
end

function UtilsUI.AddCustomUp(transform, path, callback)
	UtilsUI.GetCustomButton(transform, path).onUp:AddListener(callback)
end

function UtilsUI.AddCustomHold(transform, path, callback)
	UtilsUI.GetCustomButton(transform, path).onHold:AddListener(callback)
end

function UtilsUI.GetCustomDragButton(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(CustomDragButton)
	end
	return transform:Find(path):GetComponent(CustomDragButton)
end

function UtilsUI.AddCustomBeginDrag(transform, path, callback)
	UtilsUI.GetCustomDragButton(transform, path).onBeginDrag:AddListener(callback)
end

function UtilsUI.AddCustomEndDrag(transform, path, callback)
	UtilsUI.GetCustomDragButton(transform, path).onEndDrag:AddListener(callback)
end

function UtilsUI.AddCustomDrag(transform, path, callback)
	UtilsUI.GetCustomDragButton(transform, path).onDrag:AddListener(callback)
end

function UtilsUI.GetCanvasGroup(transform, path)
	if path == nil or path == "" then
		return transform:GetComponent(CanvasGroup)
	end
	return transform:Find(path):GetComponent(CanvasGroup)
end

function UtilsUI.SetActive(gameObject, bool)
    if UtilsBase.IsNull(gameObject) then
        return
    end
	gameObject:SetActive(bool)
end

function UtilsUI.Active(gameObject)
    if UtilsBase.IsNull(gameObject) then
        return
    end
	gameObject:SetActive(true)
end

function UtilsUI.InActive(gameObject)
    if UtilsBase.IsNull(gameObject) then
        return
    end
	gameObject:SetActive(false)
end

function UtilsUI.SetWidth(rect, width)
    if rect == nil then
        return
    end
    local sizeDelta = rect.sizeDelta
    rect.sizeDelta = Vector2(width, sizeDelta.y)
end

function UtilsUI.SetHeight(rect, height)
    if rect == nil then
        return
    end
    local sizeDelta = rect.sizeDelta
    rect.sizeDelta = Vector2(sizeDelta.x, height)
end

function UtilsUI.SetPreferredWidth(text)
    local sizeDelta = text.transform.sizeDelta
    text.transform.sizeDelta = Vector2(text.preferredWidth, sizeDelta.y)
end

function UtilsUI.SetPreferredHeight(text)
    local sizeDelta = text.transform.sizeDelta
    text.transform.sizeDelta = Vector2(sizeDelta.x, text.preferredHeight)
end

function UtilsUI.SetParent(child, parent)
	child:SetParent(parent)
    _SetLocalPosition(child, 0, 0, 0)
    _SetLocalScale(child, 1, 1, 1)
end

function UtilsUI.SetAnchoredX(transform, x)
     local position = transform.anchoredPosition
    transform.anchoredPosition = Vector2(x, position.y)
end

function UtilsUI.SetX(transform, x)
    local lx, ly, lz = transform.localPosition.x, transform.localPosition.y, transform.localPosition.z
    transform.localPosition = Vector3(x, ly, lz)
end

function UtilsUI.SetY(transform, y)
    local lx, ly, lz = transform.localPosition.x, transform.localPosition.y, transform.localPosition.z
    transform.localPosition = Vector3(lx, y, lz)
end

function UtilsUI.SetAnchoredY(transform, y)
    local position = transform.anchoredPosition
    transform.anchoredPosition = Vector2(position.x, y)
end

function UtilsUI.SetZ(transform, z)
    local lx, ly, lz = transform.localPosition.x, transform.localPosition.y, transform.localPosition.z
    transform.localPosition = Vector3(lx, ly, z)
end

--attachTrans的父节点必须是全屏界面
function UtilsUI.HorizonalAttach(fixTrans, attachTrans)
    local fixSizeDelta = fixTrans.sizeDelta
    local fixPivot = fixTrans.pivot
    local anchorPos
    if UtilsUI.RightSpaceEnough(fixTrans, attachTrans) then
        anchorPos = fixTrans.localPosition + Vector3(fixSizeDelta.x * (1 - fixPivot.x), fixSizeDelta.y * (1 - fixPivot.y), 0)
        attachTrans.pivot = Vector2(0, 1)
    else
        anchorPos = fixTrans.localPosition + Vector3(-fixSizeDelta.x * fixPivot.x, fixSizeDelta.y * (1 - fixPivot.y), 0)
        attachTrans.pivot = Vector2(1, 1)
    end
    local worldPos = fixTrans.parent:TransformPoint(anchorPos)
    local screenPos = ctx.UICamera:WorldToScreenPoint(worldPos)
    local _, result = RectTransformUtility.ScreenPointToLocalPointInRectangle(attachTrans.parent, screenPos, ctx.UICamera)
    local height = ctx.CanvasContainer.transform.sizeDelta.y
    local z = attachTrans.localPosition.z
    local attachParentTrans = attachTrans.parent
    local topY =  UtilsUI.GetTopY(attachTrans.parent, attachTrans, result.y)
    if math.abs(topY) + attachTrans.sizeDelta.y > height then
        topY = -(height - attachTrans.sizeDelta.y)
    end
    local localY = UtilsUI.ReverseTopYToLocalY(attachTrans.parent, attachTrans, topY)
    attachTrans.localPosition = Vector3(result.x, localY, z)
end

function UtilsUI.RightSpaceEnough(fixTrans, attachTrans)
    local fixSizeDelta = fixTrans.sizeDelta
    local fixPivot = fixTrans.pivot
    local maxX = fixTrans.localPosition.x + fixSizeDelta.x * (1 - fixPivot.x) + attachTrans.sizeDelta.x
    local worldPos = fixTrans.parent:TransformPoint(Vector2(maxX, 0))
    local screenPos = ctx.UICamera:WorldToScreenPoint(worldPos)
    return RectTransformUtility.RectangleContainsScreenPoint(ctx.CanvasContainer.transform, screenPos, ctx.UICamera)
end

--获取父节点子节点pivot为Vector2(*, 1)时，传入y值对应子节点的y坐标
function UtilsUI.GetTopY(parentTrans, childTrans, y)
    local pHeight = parentTrans.rect.size.y
    local pPivot = parentTrans.pivot
    local cHeight = childTrans.rect.size.y
    local cPivotY = childTrans.pivot.y
    local topY = y - pHeight * (1 - pPivot.y) + cHeight * (1 - cPivotY)
    return topY
end

function UtilsUI.ReverseTopYToLocalY(parentTrans, childTrans, topY)
    local pHeight = parentTrans.rect.size.y
    local pPivot = parentTrans.pivot
    local cHeight = childTrans.rect.size.y
    local cPivotY = childTrans.pivot.y
    return topY + pHeight * (1 - pPivot.y) - cHeight * (1 - cPivotY)
end

-- classSelf 类对象引用
-- customButton 长按按钮组件
-- callback 长按回调函数(被多次调用)
-- duration 时间间隔
function UtilsUI.SetCustomButtonOnHold(classSelf, customButton, callback, duration)
	if classSelf._timerList == nil then classSelf._timerList = {} end
	if duration == nil then duration = 400 end
	local ClearTimer = function ()
		if classSelf._timerList[customButton] ~= nil then
			TimerManager.Delete(classSelf._timerList[customButton])
        	classSelf._timerList[customButton] = nil
		end
	end
	customButton.onDown:AddListener( function () callback() end )
	customButton.onHold:AddListener(
		function()
	        ClearTimer()
	        callback()
	        classSelf._timerList[customButton] = TimerManager.Add(0, duration, function() callback() end)
	    end
	)
	customButton.onUp:AddListener( function () ClearTimer() end )
end

-- 自动设置Text内容并且自动设置宽高
function UtilsUI.SetTextAuto(com, str)
    if com.gameObject.activeInHierarchy then
        com.text = str
        com.transform.sizeDelta = Vector2(com.preferredWidth, com.preferredHeight)
    else
        local parent = com.transform.parent
        local locapos = com.transform.localPosition
        com.transform.parent = ctx.CanvasContainer.transform
        com.text = str
        com.transform.sizeDelta = Vector2(com.preferredWidth, com.preferredHeight)
        com.transform.parent = ctx.CanvasContainer.transform
        com.transform.localPosition = locapos
    end
end

function UtilsUI.HorizonalLayout(list, gap)
    local x = 0
    for i = 1, #list do
        local transform = list[i]
        local text = transform:GetComponent(Text)
        if text then
            UtilsUI.SetPreferredWidth(text)
        end
        UtilsUI.SetX(transform, x)
        x = x + transform.sizeDelta.x + gap or 0
    end
end

function UtilsUI.HorizonalAnchoredLayout(list, gap)
    local x = 0
    for i = 1, #list do
        local transform = list[i]
        local text = transform:GetComponent(Text)
        if text then
            UtilsUI.SetPreferredWidth(text)
        end
        UtilsUI.SetAnchoredX(transform, x)
        x = x + transform.sizeDelta.x + gap or 0
    end
end

function UtilsUI.TextByText(textList, gap)
    local x
    for i = 1, #textList do
        local text = textList[i]
        if i == 1 then
            x = text.transform.anchoredPosition.x + text.preferredWidth + gap
        else
            UtilsUI.SetAnchoredX(text.transform, x)
            x = text.transform.anchoredPosition.x + text.preferredWidth + gap
        end
    end
end

function UtilsUI.Vector2OneZero()
    return Vector2_onezero
end

function UtilsUI.Vector2ZeroOne()
    return Vector2_zeroone
end

function UtilsUI.Vector2One()
    return Vector2_one
end

function UtilsUI.Vector2Zero()
    return Vector2_zero
end

function UtilsUI.Vector3One()
    return Vector3_one
end

function UtilsUI.Vector3Zero()
    return Vector3_zero
end

function UtilsUI.ColorZero()
    return Color_zero
end

function UtilsUI.ColorOne()
    return Color_one
end
