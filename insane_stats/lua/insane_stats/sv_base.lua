gameevent.Listen("entity_killed")
gameevent.Listen("break_prop")
gameevent.Listen("break_breakable")

hook.Add("OnEntityCreated", "InsaneStats", function(ent)
	timer.Simple(0, function()
		if (IsValid(ent) and not ent:IsPlayer()) then
			hook.Run("InsaneStatsEntityCreated", ent)
		end
	end)
end)