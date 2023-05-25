gameevent.Listen("entity_killed")
gameevent.Listen("break_prop")
gameevent.Listen("break_breakable")

hook.Add("OnEntityCreated", "InsaneStats", function(ent)
	timer.Simple(0, function()
		if (IsValid(ent) and not ent:IsPlayer()) then
			hook.Run("InsaneStatsTransitionCompat", ent)
			hook.Run("InsaneStatsEntityCreated", ent)
		end
	end)
end)

-- MISC

-- For some reason "color" isn't included under game_text:GetKeyValues(). Why?
hook.Add("EntityKeyValue", "InsaneStats", function(ent, key, value)
	if ent:GetClass() == "game_text" and key == "color" then
		ent.insaneStats_TextColor = string.ToColor(value.." 255")
	end
end)

local pendingGameTexts = {}
hook.Add("AcceptInput", "InsaneStats", function(ent, input, activator, caller, value)
	if ent:GetClass() == "game_text" and input == "Display" and InsaneStats:GetConVarValue("gametext_tochat")
	and not (InsaneStats:GetConVarValue("gametext_tochat_once") and ent.insaneStats_DisplayedInChat) then
		local keyValues = ent:GetKeyValues()
		local xPos = tonumber(keyValues.x)
		local yPos = tonumber(keyValues.y)
		
		table.insert(pendingGameTexts, {
			order = (xPos < 0 and 0.5 or xPos) + (yPos < 0 and 0.5 or yPos),
			t = keyValues.message,
			c = ent.insaneStats_TextColor,
			target = not ent:HasSpawnFlags(1) and activator:IsPlayer() and activator
		})
		ent.insaneStats_DisplayedInChat = true
	end
end)

hook.Add("Think", "InsaneStats", function()
	if next(pendingGameTexts) then
		for k,v in SortedPairsByMemberValue(pendingGameTexts, "order") do
			net.Start("insane_stats")
			net.WriteUInt(5, 8)
			net.WriteString(v.t)
			net.WriteColor(v.c)
			if v.target then
				net.Send(v.target)
			else
				net.Broadcast()
			end
		end
		
		pendingGameTexts = {}
	end
end)

local ammoCrateTypes = {
	-- Valve can't count.
	
	3, -- pistol
	4, -- smg
	1, -- ar2
	8, -- rpg
	7, -- shotgun
	10, -- grenade
	5, -- 357
	6, -- crossbow
	2, -- ar2 alt
	9, -- smg alt
}
hook.Add("PlayerUse", "InsaneStats", function(ply, ent)
	if InsaneStats:GetConVarValue("ammocrate_maxammo") then
		if ent:GetClass() == "item_ammo_crate" then
			local crateType = tonumber(ent:GetKeyValues().AmmoType)
			local ammoType = ammoCrateTypes[crateType+1]
			timer.Simple(0.8, function()
				if IsValid(ply) and (IsValid(ent) and ent:GetSequence() ~= 0) then
					ply:GiveAmmo(9999, ammoType)
				end
			end)
		elseif ent:GetClass() == "prop_vehicle_jeep" then
			if ply:GetEyeTrace().HitGroup == 5 then
				ply:GiveAmmo(9999, 4)
			end
		end
	end
end)

hook.Add("InitPostEntity", "InsaneStats", function()
	for k,v in pairs(ents.FindByClass("trigger_changelevel")) do
		local oldSolidFlags = v:GetSolidFlags()
		if bit.band(oldSolidFlags, FSOLID_TRIGGER) ~= 0 and InsaneStats:GetConVarValue("transition_delay") then
			local newSolidFlags = bit.bxor(oldSolidFlags, FSOLID_TRIGGER)
			v:SetSolidFlags(newSolidFlags)
			timer.Simple(15, function()
				if IsValid(v) then
					v:SetSolidFlags(oldSolidFlags)
				end
			end)
		end
	end
end)