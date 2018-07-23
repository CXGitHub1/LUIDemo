BaseDemo = BaseDemo or BaseClass()

function BaseDemo:__init()
end

function BaseDemo:SetActive(active)
    self.go:SetActive(active)
end
