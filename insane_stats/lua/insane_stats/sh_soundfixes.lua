InsaneStats:SetDefaultConVarCategory("Sound Fixes")

InsaneStats:RegisterConVar("sndfix_enabled", "insanestats_sndfix_enabled", "1", {
	display = "Enable Sound Fixes", desc = "Enables Sound Fixes, fixing the issue about sound file extensions.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("sndfix_overrides", "insanestats_sndfix_overrides", "1", {
	display = "Override Hook", desc = "Allows multiple hooks to return true for the EntityEmitSound event at the same time. You should leave this on.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("sndfix_maponly", "insanestats_sndfix_maponly", "0", {
	display = "ambient_generic Only", desc = "Only ambient_generics are affected by sound file extension fixes. Requires a map restart to take effect.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("sndfix_pause", "insanestats_sndfix_pause", "1", {
	display = "Pause Sounds on Pause", desc = "Sounds are paused when the game is paused. \z
	Note that soundscapes and sounds invoked from Lua won't be paused. Does nothing in multiplayer.",
	type = InsaneStats.BOOL
})
InsaneStats:RegisterConVar("sndfix_music", "insanestats_sndfix_music", "1", {
	display = "Drymix Music", desc = "Makes most music affected by the music volume slider and unaffected by DSP (i.e. being underwater).",
	type = InsaneStats.BOOL
})

timer.Create("InsaneStatsSoundFixes", 1, 0, function()
	-- the reason we don't alter for DLib is to prevent functions from returning true, which would stop our sounds from working
	local hookTable = hook.GetTable()
	local originalHooks = hookTable.EntityEmitSound
	local nonInsaneStatsHooks = hookTable.NonInsaneStatsEntityEmitSound or {}
	local doSoundOverride = InsaneStats:GetConVarValue("sndfix_enabled")
	
	if originalHooks and doSoundOverride then
		for k,v in pairs(originalHooks) do
			if tostring(InsaneStats.NOP) ~= tostring(v) and k ~= "InsaneStats" then
				hook.Add("NonInsaneStatsEntityEmitSound", k, v)
				hook.Add("EntityEmitSound", k, InsaneStats.NOP)
			end
		end
	end
	
	if nonInsaneStatsHooks then
		for k,v in pairs(nonInsaneStatsHooks) do
			if not originalHooks[k] then -- it's gone!
				hook.Remove("NonInsaneStatsEntityEmitSound", k)
			elseif not doSoundOverride then -- put it back!
				hook.Add("EntityEmitSound", k, v)
				hook.Remove("NonInsaneStatsEntityEmitSound", k)
			end
		end
	end
end)

hook.Add("EntityEmitSound", "InsaneStats", function(sound, ...)
	if InsaneStats:GetConVarValue("sndfix_overrides") then
		-- run the others first, but in a more roundabout way
		local nonInsaneStatsHooks = hook.GetTable().NonInsaneStatsEntityEmitSound or {}
		local shouldAlter = false
		for k,v in pairs(nonInsaneStatsHooks) do
			local ret = v(sound, ...)
			if ret then
				shouldAlter = true
			elseif ret == false then return false end
		end
		
		if shouldAlter then return true end
	end
end)

local soundDurations = {}
local function SoundExists(filename)
	if not soundDurations[filename] then
		soundDurations[filename] = SoundDuration(filename)
	end
	
	return soundDurations[filename] > 0
end
hook.Add("EntityEmitSound", "InsaneStatsSoundFixes", function(sound)
	if InsaneStats:GetConVarValue("sndfix_enabled") and not InsaneStats:GetConVarValue("sndfix_maponly") then
		local changesMade = false
		-- check to see if the sound does not exist
		if not SoundExists(sound.SoundName) then
			-- change the extension and see if a match is found
			local noExtension = string.StripExtension(sound.SoundName)
			if SoundExists(noExtension..".wav") then
				sound.SoundName = noExtension..".wav"
				changesMade = true
			elseif SoundExists(noExtension..".mp3") then
				sound.SoundName = noExtension..".mp3"
				changesMade = true
			elseif SoundExists(noExtension..".ogg") then
				sound.SoundName = noExtension..".ogg"
				changesMade = true
			end
		end
			
		--[[print(sound.SoundName,
			InsaneStats:GetConVarValue("sndfix_music"),
			string.match(sound.SoundName, "^[%w\\_/][%w\\_/]"),
			string.find(sound.SoundName, "music"),
			string.find(sound.SoundName, "song")
		)]]
		if InsaneStats:GetConVarValue("sndfix_music") and string.match(sound.SoundName, "^.[%w\\_/]")
		and (string.find(sound.SoundName, "music") or string.find(sound.SoundName, "song")) then
			sound.SoundName = '#'..sound.SoundName
			changesMade = true
		end
		
		if InsaneStats:GetConVarValue("sndfix_pause") and bit.band(sound.Flags, SND_SHOULDPAUSE) == 0 and game.SinglePlayer() then
			sound.Flags = bit.bor(sound.Flags, SND_SHOULDPAUSE)
			changesMade = true
		end
		
		if changesMade then return true end
	end
end)

hook.Add("EntityKeyValue", "InsaneStatsSoundFixes", function(ent, key, value)
	if InsaneStats:GetConVarValue("sndfix_enabled") and InsaneStats:GetConVarValue("sndfix_maponly") then
		if ent:GetClass() == "ambient_generic" and key == "message" then
			local newValue = value
			
			-- get the end part
			local extension = string.GetExtensionFromFilename(value)
			if extension == "mp3" or extension == "wav" or extension == "ogg" then
				--[[-- check that the sound is NOT a soundscript
				if not allSoundScripts[value] then
					allSoundScripts[value] = sound.GetProperties(value) or {}
				end
				
				if table.IsEmpty(allSoundScripts[value]) then]]
					-- check to see if the sound does not exist
					if SoundDuration(value) <= 0 then
						-- change the extension and see if a match is found
						local noExtension = string.StripExtension(value)
						if SoundDuration(noExtension..".wav") > 0 then
							newValue = noExtension..".wav"
						elseif SoundDuration(noExtension..".mp3") > 0 then
							newValue = noExtension..".mp3"
						elseif SoundDuration(noExtension..".ogg") > 0 then
							newValue = noExtension..".ogg"
						end
					end
				--end
			end
			
			if InsaneStats:GetConVarValue("sndfix_music") and string.match(value, "^[%w\\_/][%w\\_/]") and
			(string.find(value, "music") or string.find(value, "song")) then
				newValue = '#'..newValue
			end
			
			if newValue ~= value then return newValue end
		end
	end
end)

