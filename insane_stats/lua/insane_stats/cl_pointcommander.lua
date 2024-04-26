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

hook.Add("HUDPaint", "InsaneStatsPointCommand", function()
    local timerInfo = InsaneStats.PointCommanderTimer
    if timerInfo and InsaneStats:GetConVarValue("hud_pointcmder_enabled") then
        local timeRemaining = timerInfo.expiry - CurTime()
        if timeRemaining > -5 then
            local color = color_white
            local formattedTime = "0.00"
            local x = InsaneStats:GetConVarValue("hud_pointcmder_x") * ScrW()
            local y = InsaneStats:GetConVarValue("hud_pointcmder_y") * ScrH()
            local outlineThickness = InsaneStats:GetConVarValue("hud_outline")

            if timeRemaining > 0 then
                local hue = timerInfo.color * 60 + 60
                hue = hue + math.abs((timeRemaining + 1) % 2 - 1) * 60
                color = HSVToColor(hue % 360, 0.75, 1)

                local h, m, s, cs
                h, m = math.modf(timeRemaining / 3600)
                m, s = math.modf(m * 60)
                s, cs = math.modf(s * 60)
                cs = cs * 100
                if h > 0 then
                    formattedTime = string.format("%u:%02u:%02u.%02u", h, m, s, cs)
                elseif m > 0 then
                    formattedTime = string.format("%u:%02u.%02u", m, s, cs)
                else
                    formattedTime = string.format("%u.%02u", s, cs)
                end
            end

            local zeroedFormattedTime = formattedTime:gsub('%d', '0')
            surface.SetFont("InsaneStats.Big")
            local maxLength = surface.GetTextSize(zeroedFormattedTime)

            local drawX = x - maxLength / 2
            
            for i=1, #formattedTime do
                local size = surface.GetTextSize(zeroedFormattedTime[i])
                draw.SimpleTextOutlined(
                    formattedTime[i], "InsaneStats.Big", drawX + size/2, y,
                    color_transparent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,
                    outlineThickness, color_black
                )

                drawX = drawX + size
            end

            drawX = x - maxLength / 2
            
            for i=1, #formattedTime do
                local size = surface.GetTextSize(zeroedFormattedTime[i])
                draw.SimpleText(
                    formattedTime[i], "InsaneStats.Big", drawX + size/2, y,
                    color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
                )

                drawX = drawX + size
            end
        else
            InsaneStats.PointCommanderTimer = nil
        end
    end
end)