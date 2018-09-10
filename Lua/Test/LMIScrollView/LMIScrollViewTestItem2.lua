LMIScrollViewTestItem2 = LMIScrollViewTestItem2 or BaseClass(LTestItem)

function LMIScrollViewTestItem2:SetData(data, commonData)
    self.text.text = "I:" .. self.index .. "  T:2"
end