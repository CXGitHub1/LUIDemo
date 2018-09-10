LMIScrollViewTestItem1 = LMIScrollViewTestItem1 or BaseClass(LTestItem)

function LMIScrollViewTestItem1:SetData(data, commonData)
    self.text.text = "I:" .. self.index .. "  T:1"
end