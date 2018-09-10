BaseDemo = BaseDemo or BaseClass()

function BaseDemo:__init(transform)
    self.gameObject = transform.gameObject
end

function BaseDemo:SetActive(active)
    self.gameObject:SetActive(active)
end

function BaseDemo:CreateDataList(num)
    local result = {}
    for i = 1, num do
        table.insert(result, i)
    end
    return result
end
