BaseDemo = BaseDemo or BaseClass()

function BaseDemo:__init(transform)
    self.gameObject = transform.gameObject
end

function BaseDemo:SetActive(active)
    self.gameObject:SetActive(active)
end
