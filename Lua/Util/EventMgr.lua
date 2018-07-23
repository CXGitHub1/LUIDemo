-- 事件系统
local _table_insert = table.insert
local _pairs = pairs
local _xpcall = xpcall
local _assert = assert

EventLib = EventLib or BaseClass()
function EventLib:__init(EventName)
    self.handlers = nil
    self.oncehandlers = nil
    self.args = nil
    self.EventName = EventName or "<Unknown Event>"
    self.firedelay = false
    self.notcheck = true
    self.handlerList = {}
end

function EventLib:AddListener(handler)
    self:Add(handler)
end

function EventLib:AddOnceListener(handler)
    self:AddOnce(handler)
end

function EventLib:Add(handler)
    _assert(type(handler) == "function", "非法事件")
    if self.handlers == nil then
        self.handlers = {}
    end
    for k,v in _pairs(self.handlers) do
        if v == handler then
            -- print("重复添加事件监听"..debug.traceback())
            return
        end
    end
    _table_insert(self.handlers, handler)
end
-- 添加一次性监听
function EventLib:AddOnce(handler)
    _assert(type(handler) == "function", "非法事件")
    if self.oncehandlers == nil then
        self.oncehandlers = {}
    end
    _table_insert(self.oncehandlers, handler)
end

function EventLib:ClearOnce()
    self.oncehandlers = {}
end

function EventLib:RemoveListener(handler)
    self:Remove(handler)
end
function EventLib:Remove(handler)
    -- _assert(type(handler) == "function", "非法事件")
    if not handler then
        -- self.handlers = nil
    else
        if self.handlers then
            for k, v in _pairs(self.handlers) do
                if v == handler then
                    self.handlers[k] = nil
                    return k
                end
            end
        end
        if self.oncehandlers then
            for k, v in _pairs(self.oncehandlers) do
                if v == handler then
                    self.oncehandlers[k] = nil
                    return k
                end
            end
        end
    end
end

function EventLib:RemoveAll()
    self:Remove()
end

-- 应该只有一个主线程，就不考虑多线程问题了
function EventLib:Fire(args1, args2, args3, args4)
    if not self.notcheck then
        if self.firedelay then
            TimerManager.Delete(self.firedelay)
            self.firedelay = false
        end
        self.firedelay = TimerManager.Add(1, function()
            self.firedelay = false
            self:__innerFire(args1, args2, args3, args4)
        end)
    else
        self:__innerFire(args1, args2, args3, args4)
    end
    -- local currtime = Time.time
    -- if self.lastFire == nil then
    --     self.lastFire = currtime
    -- else
    --     if self.lastFire == currtime then
    --         hzf("Repeat", self.traceinfo)
    --     else
    --         self.lastFire = currtime
    --     end
    -- end
end


function EventLib:__innerFire(args1, args2, args3, args4)
    if self.handlers ~= nil or self.oncehandlers ~= nil then
        if self.handlers then
            for _, handler in _pairs(self.handlers) do
                _table_insert(self.handlerList, handler)
            end
        end
        if self.oncehandlers then
            for _, handler in _pairs(self.oncehandlers) do
                _table_insert(self.handlerList, handler)
            end
            self.oncehandlers = nil
        end
        local list = self.handlerList
        for k, func in _pairs(list) do
            local call = function() func(args1, args2, args3, args4) end
            _xpcall(call, function(errinfo)
                if self.EventName ~= nil then
                    print("EventLib:Fire出错了[" .. self.EventName .. "]:" .. tostring(errinfo).."\n"..debug.traceback())
                else
                    print("EventLib:Fire出错了" .. tostring(errinfo).."\n"..debug.traceback())
                end
            end)
            list[k] = nil
        end

    end
end

function EventLib:Destroy()
    self:RemoveAll()
    for k, v in _pairs(self) do
        self[k] = nil
    end
end

function EventLib:__delete()
    self:Destroy()
end

-- UnityEvent.RemoveListener在某些情况下不起作用
-- 所以增加了该方式，handler为lua function
EventMgr = EventMgr or BaseClass()
function EventMgr:__init()
    EventMgr.Instance = self
    self.countFire = {}
    self.events = {}
end

function EventMgr:AddListener(event, handler)
    if not event or type(event) ~= "string" then
        print("事件名要为字符串")
    end

    if not handler or type(handler) ~= "function" then
        print("handler必须是一个函数,事件名:"..event)
    end

    if not self.events[event] then
        self.events[event] = EventLib.New(event)
    end
    self.events[event]:Add(handler)
end
-- 添加一次性监听
function EventMgr:AddOnceListener(event, handler)
    if not event or type(event) ~= "string" then
        print("事件名要为字符串")
    end

    if not handler or type(handler) ~= "function" then
        print("handler为是一个函数,事件名:"..event)
    end

    if not self.events[event] then
        self.events[event] = EventLib.New(event)
    end
    self.events[event]:AddOnce(handler)
end

function EventMgr:RemoveListener(event, handler)
    if self.events[event] then
        self.events[event]:Remove(handler)
    end
end
function EventMgr:RemoveAllListener(event)
    if self.events[event] then
        self.events[event]:RemoveAll()
    end
end

function EventMgr:Fire(event, args1, args2, args3, args4)
    if self.events[event] then
        if self.countFire[event] == nil then
            self.countFire[event] = 0
        end
        self.countFire[event] = self.countFire[event] + 1
        self.events[event]:Fire(args1, args2, args3, args4)
    end
end

