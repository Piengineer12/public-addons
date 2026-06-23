InsaneStats:SetDefaultConVarCategory("Point Commander")

InsaneStats:RegisterClientConVar("hud_pointcmder_enabled", "insanestats_hud_pointcmder_enabled", "1", {
	display = "Timer", desc = "Enables the HUD for the Point Commander timer.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pointcmder_x", "insanestats_hud_pointcmder_x", "0.5", {
	display = "Timer X", desc = "Horizontal position of timer.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_pointcmder_y", "insanestats_hud_pointcmder_y", "0.02", {
	display = "Timer Y", desc = "Vertical position of timer.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_pointcmder_align", "insanestats_hud_pointcmder_align", "0.5", {
	display = "Timer Horizontal Alignment", desc = "Horizontal alignment of timer.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})

hook.Add("HUDPaint", "InsaneStatsPointCommand", function()
    local timerInfo = InsaneStats.PointCommanderTimer
    if timerInfo and InsaneStats:GetConVarValue("hud_pointcmder_enabled") and InsaneStats:ShouldDrawHUD() then
        local timeRemaining = timerInfo.expiry - CurTime()
        if timeRemaining > -5 then
            local color = color_white
            local formattedTime = "0.00"
            local x = InsaneStats:GetConVarValue("hud_pointcmder_x") * ScrW()
            local y = InsaneStats:GetConVarValue("hud_pointcmder_y") * ScrH()
            local align = InsaneStats:GetConVarValue("hud_pointcmder_align")
            local outlineThickness = InsaneStats:GetOutlineThickness()

            if timeRemaining > 0 then
                local hue = timerInfo.color * 60 + 60
                if timeRemaining == math.huge or timerInfo.color == math.huge then
                    hue = timeRemaining * 60
                else
                    hue = hue + math.abs((timeRemaining + 1) % 2 - 1) * 60
                end
                color = HSVToColor(hue % 360, 0.75, 1)

                local d, h, m, s, cs
                d, h = math.modf(timeRemaining / 86400)
                h, m = math.modf(h * 24)
                m, s = math.modf(m * 60)
                s, cs = math.modf(s * 60)
                cs = cs * 100
                if timeRemaining == math.huge then
                    formattedTime = InsaneStats:FormatNumber(timeRemaining)
                elseif d > 0 then
                    formattedTime = string.format(
                        "%s:%02u:%02u:%02u.%02u",
                        InsaneStats:FormatNumber(d), h, m, s, cs
                    )
                elseif h > 0 then
                    formattedTime = string.format("%u:%02u:%02u.%02u", h, m, s, cs)
                elseif m > 0 then
                    formattedTime = string.format("%u:%02u.%02u", m, s, cs)
                else
                    formattedTime = string.format("%u.%02u", s, cs)
                end
            end

            local text = timerInfo.text
            if text ~= "" then
                surface.SetFont("InsaneStats.Small")
                local size = surface.GetTextSize(text)

                y = y + outlineThickness + select(2, InsaneStats:DrawTextOutlined(
                    text, 1, x - size * align, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                ))
            end

            local zeroedFormattedTime = formattedTime:gsub('%d', '0')
            surface.SetFont("InsaneStats.Big")
            local maxLength = surface.GetTextSize(zeroedFormattedTime)

            local drawX = x - maxLength * align

            for b,c in utf8.codes(formattedTime) do
                local size = surface.GetTextSize(zeroedFormattedTime[b])
                InsaneStats:DrawTextOutlined(
                    utf8.char(c), 3, drawX + size/2, y,
                    color_transparent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
                )

                drawX = drawX + size
            end

            drawX = x - maxLength * align

            for b,c in utf8.codes(formattedTime) do
                local size = surface.GetTextSize(zeroedFormattedTime[b])
                draw.SimpleText(
                    utf8.char(c), "InsaneStats.Big", drawX + size/2, y,
                    color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
                )

                drawX = drawX + size
            end
        else
            InsaneStats.PointCommanderTimer = nil
        end
    end
end)
