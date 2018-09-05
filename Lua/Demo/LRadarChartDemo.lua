LRadarChartDemo = LRadarChartDemo or BaseClass(BaseDemo)

function LRadarChartDemo:__init(transform)
    self.radarChart1Bg = LRadarChart.New(transform:Find("Test1"), 100)
    self.radarChart1 = LRadarChart.New(transform:Find("Test1/Radar"), 100)

    self.radarChart2Bg = LRadarChart.New(transform:Find("Test2"), 150)
    self.radarChart2 = LRadarChart.New(transform:Find("Test2/Radar"), 150)
end

function LRadarChartDemo:SetData()
    self.radarChart1Bg:SetData({1, 1, 1}, Color32(0, 0, 0, 255))
    self.radarChart1:SetData({0.5, 0.8, 0.7})
    self.radarChart2Bg:SetData({1, 1, 1, 1, 1}, Color32(0, 0, 0, 255))
    self.radarChart2:SetData({0.8, 0.5, 0.7, 0.9, 0.6})
end
