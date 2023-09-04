InsaneStats:SetDefaultConVarCategory("Coin Drops")

InsaneStats:RegisterClientConVar("hud_coins_enabled", "insanestats_hud_coins_enabled", "1", {
	display = "Coins", desc = "Shows the number of coins collected.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_coins_x", "insanestats_hud_coins_x", "0.01", {
	display = "Coin Display X", desc = "Horizontal position of coin display.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_coins_y", "insanestats_hud_coins_y", "0.02", {
	display = "Coin Display Y", desc = "Vertical position of coin display.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})

local color_red = InsaneStats:GetColor("red")
local color_green = InsaneStats:GetColor("green")

local lastCoinUpdate = 0
local slowCoins = 0
local oldCoins = LocalPlayer():InsaneStats_GetCoins()
local icons = {
	Material("insane_stats/metal-disc.png", "mips smooth"),
	Material("insane_stats/emerald.png", "mips smooth")
}

local function DangerousPaint()
	local ply = LocalPlayer()
	local coins = ply:InsaneStats_GetCoins()
	local lastCoinTier = ply:InsaneStats_GetLastCoinTier()
	local x = 8
	local y = 8

	InsaneStats:DrawMaterialOutlined(
		icons[InsaneStats:GetConVarValue("coins_legacy") and 2 or 1],
		x, y,
		InsaneStats.FONT_BIG, InsaneStats.FONT_BIG,
		InsaneStats:GetCoinColor(lastCoinTier),
		2,
		color_black
	)

	x = x + InsaneStats.FONT_BIG + 2

	local text = string.Comma(math.floor(coins))
	draw.SimpleTextOutlined(text, "InsaneStats.Big", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)

	if slowCoins ~= coins then
		y = y + InsaneStats.FONT_BIG

		local change = coins - slowCoins
		local textColor = change > 0 and color_green or change < 0 and color_red or color_white
		text = string.format(
			"%s%s",
			change < 0 and "" or "+",
			string.Comma(math.floor(change))
		)
		draw.SimpleTextOutlined(text, "InsaneStats.Big", x, y, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
	end
end

hook.Add("HUDPaint", "InsaneStatsCoins", function()
	if InsaneStats:GetConVarValue("hud_coins_enabled") then
		local ply = LocalPlayer()
		local coins = ply:InsaneStats_GetCoins()
		local mustShow = ply:KeyDown(IN_WALK)
		local realTime = RealTime()
		if oldCoins ~= coins then
			if oldCoins then
				lastCoinUpdate = realTime
			end
			oldCoins = coins
		elseif mustShow then
			lastCoinUpdate = math.max(lastCoinUpdate, realTime - 3.5)
		end
		local life = 5 + lastCoinUpdate - realTime
		if life < 0 then
			slowCoins = coins
		else
			surface.SetAlphaMultiplier(life)
	
			local popAmt = math.max(1, life - 3.75)
			local scrW = ScrW()
			local scrH = ScrH()
			local x = scrW * InsaneStats:GetConVarValue("hud_coins_x") - 8
			local y = scrH * InsaneStats:GetConVarValue("hud_coins_y") - 8
	
			local m = Matrix()
			m:Translate(Vector(x, y, 0))
			m:Scale(Vector(popAmt, popAmt, popAmt))
			
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			cam.PushModelMatrix(m, true)

			local ok, err = pcall(DangerousPaint)
	
			cam.PopModelMatrix()
			render.PopFilterMag()
			surface.SetAlphaMultiplier(1)

			if not ok then
				error(err)
			end
		end
	end
end)