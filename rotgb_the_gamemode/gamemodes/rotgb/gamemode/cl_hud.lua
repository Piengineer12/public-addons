local levelDisplayExpiryTime = -1
local levelUpText
local oldLevel = -1

local color_aqua = Color(0, 255, 255)
local color_purple = Color(127, 0, 255)
local FONT_LEVEL_HEIGHT = ScreenScale(16)

function GM:HUDDrawXP()
	local ply = LocalPlayer()
	local barHeight = FONT_LEVEL_HEIGHT/4
	local barWidth = barHeight * 75
	
	local barX = (ScrW() - barWidth)/2
	local barY = ScrH() - barHeight*2
	
	local level = ply:RTG_GetLevel()
	
	if level ~= oldLevel and ply.rtg_PreviousXP then
		if oldLevel>0 and levelDisplayExpiryTime < RealTime() then
			local towers = ROTGB_GetAllTowers()
			if level<=#towers then
				local towerUnlocked = towers[level]
				levelUpText = ROTGB_LocalizeString("rotgb_tg.level_up.tower", towerUnlocked.PrintName)
			else
				levelUpText = "#rotgb_tg.level_up.skill_point"
				local minSkillLevel = #towers + 1
				if level >= minSkillLevel and oldLevel < minSkillLevel then
					chat.AddText(unpack(ROTGB_LocalizeMulticoloredString(
						"rotgb_tg.skills.hint",
						{"!skills", "!rtg_skills"},
						color_white,
						{color_aqua, color_aqua}
					)))
				end
			end
			levelDisplayExpiryTime = RealTime() + 10
			surface.PlaySound("ambient/levels/canals/windchime2.wav")
		end
		oldLevel = level
	end
	
	surface.SetDrawColor(0,0,0)
	surface.DrawRect(barX-2, barY-2, barWidth+4, barHeight+4)
	surface.SetDrawColor(63,0,127)
	surface.DrawRect(barX, barY, barWidth, barHeight)
	surface.SetDrawColor(127,0,255)
	surface.DrawRect(barX, barY, barWidth * ply:RTG_GetLevelFraction(), barHeight)
	
	local levelString = ROTGB_LocalizeString("rotgb_tg.level", string.Comma(level))
	draw.SimpleTextOutlined(levelString, "rotgb_level", barX, barY, color_purple, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
	if levelDisplayExpiryTime < RealTime() then
		local xp = string.Comma(math.floor(ply:RTG_GetExperience()))
		local requiredXp = string.Comma(math.ceil(ply:RTG_GetExperienceNeeded()))
		local experienceText = ROTGB_LocalizeString("rotgb_tg.experience", xp, requiredXp) 
		draw.SimpleTextOutlined(experienceText, "rotgb_experience", barX+barWidth, barY, color_purple, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
	else
		local textColor = Color(255,math.sin(RealTime()*math.pi)*127+128,255)
		draw.SimpleTextOutlined(levelUpText, "rotgb_experience", barX+barWidth, barY, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
	end
end

local blockedElements = {
	CHudHealth = true,
	CHudBattery = true,
	CHUDQuickInfo = true
}
function GM:HUDShouldDraw(name)
	if blockedElements[name] then return false end
	
	-- I don't think we should allow other weapons at all, but I'll define the wep.HUDShouldDraw
	-- functionality anyway since it is part of the base gamemode
	local ply = LocalPlayer()
	if IsValid(ply) then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.HUDShouldDraw ~= nil then
			return wep.HUDShouldDraw(wep, name)
		end
	end
	
	return true
end

function GM:HUDPaint()
	hook.Run("HUDDrawTargetID")
	hook.Run("DrawDeathNotice", 0.85, 0.04)
	hook.Run("HUDDrawXP")
end