local Statistics = {
	Background = { Dictionary = "commonmenu", Texture = "gradient_bgd", Y = 4, Width = 431, Height = 42 },
	Text = {
		Left = { X = -40, Y = 15, Scale = 0.35 }
	},
	Bar = { X = 190, Y = 27, Width = 250, Height = 10 },
	Divider = {
		{ X = 200, Y = 27, Width = 2, Height = 10 },
		{ X = 200, Y = 27, Width = 2, Height = 10 },
		{ X = 200, Y = 27, Width = 2, Height = 10 },
		{ X = 200, Y = 27, Width = 2, Height = 10 },
		{ X = 200, Y = 27, Width = 2, Height = 10 }
	}
}

---StatisticPanel
---@param Percent number
---@param Text string
---@param Index number
---@return void
---@public
function RageUI.StatisticPanel(Percent, Text, Index)
	local CurrentMenu = RageUI.CurrentMenu

	if CurrentMenu ~= nil then
		if CurrentMenu() and (Index == nil or (CurrentMenu.Index == Index)) then
			RenderRectangle(CurrentMenu.X, CurrentMenu.Y + Statistics.Background.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset + (RageUI.StatisticPanelCount * 42), Statistics.Background.Width + CurrentMenu.WidthOffset, Statistics.Background.Height, 0, 0, 0, 170)
			RenderText(Text or "", CurrentMenu.X + Statistics.Text.Left.X + (CurrentMenu.WidthOffset / 2), (RageUI.StatisticPanelCount * 40) + CurrentMenu.Y + Statistics.Text.Left.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, Statistics.Text.Left.Scale, 245, 245, 245, 255, 0)
			RenderRectangle(CurrentMenu.X + Statistics.Bar.X + (CurrentMenu.WidthOffset / 2), (RageUI.StatisticPanelCount * 40) + CurrentMenu.Y + Statistics.Bar.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Statistics.Bar.Width, Statistics.Bar.Height, 87, 87, 87, 255)
			RenderRectangle(CurrentMenu.X + Statistics.Bar.X + (CurrentMenu.WidthOffset / 2), (RageUI.StatisticPanelCount * 40) + CurrentMenu.Y + Statistics.Bar.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Percent * Statistics.Bar.Width, Statistics.Bar.Height, 255, 255, 255, 255)

			for i = 1, #Statistics.Divider, 1 do
				RenderRectangle(CurrentMenu.X + i * 40 + 193 + (CurrentMenu.WidthOffset / 2), (RageUI.StatisticPanelCount * 40) + CurrentMenu.Y + Statistics.Divider[i].Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Statistics.Divider[i].Width, Statistics.Divider[i].Height, 0, 0, 0, 255)
			end

			RageUI.StatisticPanelCount = RageUI.StatisticPanelCount + 1
		end
	end
end