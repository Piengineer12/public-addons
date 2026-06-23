InsaneStats:SetDefaultConVarCategory("Notifications")

InsaneStats:RegisterClientConVar("hud_pickup_enabled", "insanestats_hud_pickup_enabled", "1", {
	display = "Pickup Notifications", desc = "Causes picked up items and weapons to be displayed at the top right by default.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pickup_x", "insanestats_hud_pickup_x", "0.99", {
	display = "Pickup Notifications X", desc = "Horizontal position of pickup notifications.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_pickup_y", "insanestats_hud_pickup_y", "0.02", {
	display = "Pickup Notifications Y", desc = "Vertical position of pickup notifications.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_pickup_align", "insanestats_hud_pickup_align", "1", {
	display = "Pickup Notifications Horizontal Alignment", desc = "Horizontal alignment of pickup notifications.",
	type = InsaneStats.FLOAT, min = 0, max = 1
})
InsaneStats:RegisterClientConVar("hud_pickup_stacking", "insanestats_hud_pickup_stacking", "1", {
	display = "Pickup Stacking", desc = "If disabled, entries will never stack.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pickup_simplified", "insanestats_hud_pickup_simplified", "0", {
	display = "Pickup Compact Numbers", desc = "Makes notification numbers use a simplified display like in Insane Stats Coin Shops.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pickup_flash_duration", "insanestats_hud_pickup_flash_duration", "1", {
	display = "Pickup Flash Duration", desc = "New notifications flash for this many seconds.",
	type = InsaneStats.FLOAT, min = 0, max = 10
})
InsaneStats:RegisterClientConVar("hud_pickup_flash_outline", "insanestats_hud_pickup_flash_outline", "0", {
	display = "Pickup Flash Outline", desc = "New notifications flash the outline color instead of the text color.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pickup_weapon_rarity", "insanestats_hud_pickup_weapon_rarity", "0", {
	display = "Pickup Rarity", desc = "WPASS2 rarity to use for displaying weapons when WPASS2 is disabled.",
	type = InsaneStats.INT, min = -999, max = 999
})
InsaneStats:RegisterClientConVar("hud_pickup_expiring_order", "insanestats_hud_pickup_expiring_order", "0", {
	display = "Expiring Order", desc = "Entries are ordered by expiry time instead of insertion time.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pickup_reversed_order", "insanestats_hud_pickup_reversed_order", "1", {
	display = "Reversed Order", desc = "Entries are displayed in reverse order.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pickup_timer_item", "insanestats_hud_pickup_timer_item", "5", {
	display = "Pickup Notifications Items Timer", desc = "How many seconds to display picked up items for.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_pickup_timer_weapon", "insanestats_hud_pickup_timer_weapon", "10", {
	display = "Pickup Notifications Weapons Timer", desc = "How many seconds to display picked up weapons for.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})
InsaneStats:RegisterClientConVar("hud_pickup_kills", "insanestats_hud_pickup_kills", "1", {
	display = "Kill Notifications", desc = "Causes kills to be displayed on the top right just like pickups.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterClientConVar("hud_pickup_timer_kills", "insanestats_hud_pickup_timer_kills", "10", {
	display = "Kill Notifications Timer", desc = "How many seconds to display kills for.",
	type = InsaneStats.FLOAT, min = 0, max = 100
})

local notifs = {}
local notifI = 0
hook.Add("HUDDrawPickupHistory", "InsaneStats", function()
	local ply = LocalPlayer()
	local hasSuit = ply:IsSuitEquipped()

	if InsaneStats:ShouldDrawHUD() and InsaneStats:GetConVarValue("hud_pickup_enabled") then
        local outlineThickness = InsaneStats:GetConVarValue("hud_outline")
		local scrW = ScrW()
		local scrH = ScrH()
        local x = scrW * InsaneStats:GetConVarValue("hud_pickup_x")
        local y = scrH * InsaneStats:GetConVarValue("hud_pickup_y")
        local itemTime = InsaneStats:GetConVarValue("hud_pickup_timer_item")
        local weaponTime = InsaneStats:GetConVarValue("hud_pickup_timer_weapon")
        local killTime = InsaneStats:GetConVarValue("hud_pickup_timer_kills")
        local realTime = RealTime()

        local order = {}
        for k,v in pairs(notifs) do
            local timeToShow = v.wep and weaponTime or v.isKill and killTime or itemTime
            local timeLeft = v.time + timeToShow - realTime
            table.insert(order, {id = k, time = v.time, timeLeft = timeLeft, data = v})
        end

        table.SortByMember(
            order,
            InsaneStats:GetConVarValue("hud_pickup_expiring_order") and "timeLeft" or "time",
            InsaneStats:GetConVarValue("hud_pickup_reversed_order")
        )

        for i,v in ipairs(order) do
            if v.timeLeft < 0 then
                notifs[v.id] = nil
            else
                local timeLeft = v.timeLeft
                local data = v.data
                local colors = {unpack(data.colors)}
                local texts = data.texts
                local subX = x
                local nextY = 0
                surface.SetFont("InsaneStats.Big")

                if data.wep then
                    local wep = data.wep
                    local tier = InsaneStats:GetConVarValue("hud_pickup_weapon_rarity")
                    local alignment = InsaneStats:GetConVarValue("hud_pickup_align")
                    local text = texts[1]
                    local lastText = texts[#texts]
                    local lastColor = table.remove(colors)

                    if InsaneStats:GetConVarValue("wpass2_enabled") and IsValid(wep) then
                        if wep.insaneStats_Modifiers then
                            text = InsaneStats:GetWPASS2Name(wep)
                            lastText = string.format(" (slot %i)", wep.GetSlot and wep:GetSlot() or -1)
                            tier = InsaneStats:GetWPASS2Rarity(wep)
                        else
                            wep:InsaneStats_MarkForUpdate()
                        end
                    end

                    texts = {"Received "}
                    local offsetX, offsetY = surface.GetTextSize(texts[1])
                    subX = subX - offsetX * alignment

                    offsetX, offsetY = surface.GetTextSize(lastText)
                    subX = subX - offsetX * alignment

                    offsetX, offsetY = surface.GetTextSize(text)
                    subX = subX - offsetX * alignment
                    nextY = offsetY

                    local outlineThickness = InsaneStats:GetOutlineThickness()
                    local dX = 0
                    for _, code in utf8.codes(utf8.force(text)) do
                        local chr = utf8.char(code)
                        dX = dX + surface.GetTextSize(chr)
                        if subX + dX + outlineThickness > 0 then
                            local phase = dX / math.min(offsetX, ScrW())
                            table.insert(texts, chr)
                            table.insert(colors, InsaneStats:GetPhasedRarityColor(tier, phase))

                            if subX + dX > ScrW() + outlineThickness then
                                break
                            end
                        else
                            subX = subX + dX
                            dX = 0
                        end
                    end

                    table.insert(texts, lastText)
                    table.insert(colors, lastColor)
                else
                    local offsetX, offsetY = surface.GetTextSize(table.concat(texts))
                    subX = subX - offsetX * InsaneStats:GetConVarValue("hud_pickup_align")
                    nextY = offsetY
                end

                local alpha = math.min(timeLeft, 1)
                surface.SetAlphaMultiplier(alpha)
                local brightnessFactor = math.Remap(realTime - v.time, 0, InsaneStats:GetConVarValue("hud_pickup_flash_duration"), 1, 0)
				local useOutlineFlash = InsaneStats:GetConVarValue("hud_pickup_flash_outline")
                if brightnessFactor > 0 and not useOutlineFlash then
					for i,v in ipairs(colors) do
						colors[i] = Color(
							Lerp(brightnessFactor, v.r, 255),
							Lerp(brightnessFactor, v.g, 255),
							Lerp(brightnessFactor, v.b, 255),
							v.a
						)
					end
                end
				-- FIXME: can't data.wep be replaced with true?
				-- in other words, can the other conditional be deleted?
                if data.wep then
                    local oldSubX = subX
                    for i,v in ipairs(texts) do
                        subX = subX + InsaneStats:DrawTextOutlined(
                            v, 3, subX, y,
                            colors[i], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP,
                            {
								outlineOnly = true,
								outlineColor = useOutlineFlash
								and InsaneStats:GetOutlineColor(colors[i]):Lerp(color_white, brightnessFactor)
							}
                        )
                    end
                    subX = oldSubX
                    for i,v in ipairs(texts) do
                        subX = subX + draw.SimpleText(
                            v, "InsaneStats.Big", subX, y,
                            colors[i], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
                        )
                    end
                else
                    for i,v in ipairs(texts) do
                        subX = subX + InsaneStats:DrawTextOutlined(
                            v, 3, subX, y,
                            colors[i], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP,
                            {
								outlineColor = useOutlineFlash
								and InsaneStats:GetOutlineColor(colors[i]):Lerp(color_white, brightnessFactor)
							}
                        )
                    end
                end
                y = y + nextY + outlineThickness
            end
        end
        surface.SetAlphaMultiplier(1)

        return true
    end
end)

hook.Add("HUDAmmoPickedUp", "InsaneStats", function(item, amount)
	local simplified = InsaneStats:GetConVarValue("hud_pickup_simplified")
    local class = item.."_ammo"
    local id = notifI
    if InsaneStats:GetConVarValue("hud_pickup_stacking") then
        id = class
    else
        notifI = notifI + 1
    end
    if notifs[id] then
        local data = notifs[id]
        data.time = RealTime()
        data.count = data.count + amount
        data.texts[2] = string.format(
            "%sx %s",
            InsaneStats:FormatNumber(data.count, {noShortening = not simplified}),
            language.GetPhrase(class)
        )
    else
        notifs[id] = {
            time = RealTime(),
            count = amount,
            texts = {"Looted ", string.format(
                "%sx %s",
                InsaneStats:FormatNumber(amount, {noShortening = not simplified}),
                language.GetPhrase(class)
            )},
            colors = {color_white, InsaneStats:GetColor("light_gray")}
        }
    end
end)

hook.Add("HUDItemPickedUp", "InsaneStats", function(class)
	local simplified = InsaneStats:GetConVarValue("hud_pickup_simplified")
    local ply = LocalPlayer()
    local color = InsaneStats:GetColor("light_gray")
    if class == "item_healthvial" then
        color = InsaneStats:GetColor("light_green")
    elseif class == "item_healthkit" then
        color = InsaneStats:GetColor("light_green")
    elseif class == "item_grubnugget" then
        color = InsaneStats:GetColor("light_green")
    elseif class == "item_battery" then
        color = InsaneStats:GetColor("light_aqua")
    end

    local id = notifI
    if InsaneStats:GetConVarValue("hud_pickup_stacking") then
        id = class
    else
        notifI = notifI + 1
    end

    if notifs[id] then
        local data = notifs[id]
        data.time = RealTime()
        data.count = (data.count or 0) + 1
        data.texts = {"Consumed ", string.format(
            "%sx %s",
            InsaneStats:FormatNumber(data.count, {noShortening = not simplified}),
            language.GetPhrase(class)
        )}
    else
        notifs[id] = {
            time = RealTime(),
            count = 1,
            texts = {"Consumed a ", language.GetPhrase(class)},
            colors = {color_white, color}
        }
    end
end)

hook.Add("HUDWeaponPickedUp", "InsaneStats", function(wep)
    local id = notifI
    if InsaneStats:GetConVarValue("hud_pickup_stacking") then
        id = wep:GetClass()
    else
        notifI = notifI + 1
    end

    notifs[id] = {
        time = RealTime(),
        texts = {
            InsaneStats:GetWeaponName(wep),
            string.format(" (slot %i)", wep.GetSlot and wep:GetSlot() or -1)
        },
        colors = {color_white, color_white},
        wep = wep
    }
end)

local function getDeathColor(teamID)
	if teamID == -1 then
		return Color(250, 50, 50, 255)
	elseif teamID == -2 then
		return Color(50, 200, 50, 255)
    else
        return team.GetColor(teamID)
	end
end

hook.Add("AddDeathNotice", "InsaneStats", function(attacker, team1, inflictor, victim, team2, flags)
    if InsaneStats:GetConVarValue("hud_pickup_enabled") and InsaneStats:GetConVarValue("hud_pickup_kills") then
        attacker = attacker or inflictor

        local id = notifI
        if InsaneStats:GetConVarValue("hud_pickup_stacking") then
            id = string.format(
                "%s%i%s%s%i", attacker, team1,
                inflictor, victim, team2
            )
        else
            notifI = notifI + 1
        end
        if notifs[id] then
			local simplified = InsaneStats:GetConVarValue("hud_pickup_simplified")
            local data = notifs[id]
            data.time = RealTime()
            data.count = data.count + 1
            if inflictor == "suicide" then
                data.texts = {
                    language.GetPhrase(victim).." ",
                    language.GetPhrase(inflictor).."'d ",
                    "x"..InsaneStats:FormatNumber(notifs[id].count, {noShortening = not simplified})
                }
                data.colors = {
                    getDeathColor(team2),
                    color_white,
                    color_white
                }
            else
                data.texts = {
                    language.GetPhrase(attacker).." ",
                    language.GetPhrase(inflictor).."'d ",
                    language.GetPhrase(victim).." ",
                    "x"..InsaneStats:FormatNumber(notifs[id].count, {noShortening = not simplified})
                }
                data.colors = {
                    getDeathColor(team1),
                    color_white,
                    getDeathColor(team2),
                    color_white
                }
            end
        elseif inflictor == "suicide" then
            notifs[id] = {
                time = RealTime(),
                count = 1,
                texts = {
                    language.GetPhrase(victim).." ",
                    language.GetPhrase(inflictor).."'d"
                },
                colors = {
                    getDeathColor(team2),
                    color_white
                },
				isKill = true
            }
        else
            notifs[id] = {
                time = RealTime(),
                count = 1,
                texts = {
                    language.GetPhrase(attacker).." ",
                    language.GetPhrase(inflictor).."'d ",
                    language.GetPhrase(victim)
                },
                colors = {
                    getDeathColor(team1),
                    color_white,
                    getDeathColor(team2)
                },
				isKill = true
            }
        end
    end
end)
hook.Add("DrawDeathNotice", "InsaneStats", function(x, y)
    if InsaneStats:ShouldDrawHUD() and InsaneStats:GetConVarValue("hud_pickup_enabled")
    and InsaneStats:GetConVarValue("hud_pickup_kills") then
        return true
    end
end)
