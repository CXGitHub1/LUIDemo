BaseTest = BaseTest or BaseClass()

function BaseTest:CreateDataList(num)
    local result = {}
    for i = 1, num do
        table.insert(result, i)
    end
    return result
end
