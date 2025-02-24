if game.SinglePlayer!
	hook.Add 'PlayerButtonDown', 'MWS&S', (ply, button) ->
		switch button
			when ply\GetInfoNum 'mwsas_selector_bind', 0 then ply\ConCommand '+mwsas_wepsel'
			when ply\GetInfoNum 'mwsas_searcher_bind', 0 then ply\ConCommand 'mwsas_wepsearch'
		return

	hook.Add 'PlayerButtonUp', 'MWS&S', (ply, button) ->
		if button == ply\GetInfoNum 'mwsas_selector_bind', 0
			ply\ConCommand '-mwsas_wepsel'
		return