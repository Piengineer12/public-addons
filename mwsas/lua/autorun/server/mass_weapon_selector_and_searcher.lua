if game.SinglePlayer() then
  hook.Add('PlayerButtonDown', 'MWS&S', function(ply, button)
    local _exp_0 = button
    if ply:GetInfoNum('mwsas_selector_bind', 0) == _exp_0 then
      ply:ConCommand('+mwsas_wepsel')
    elseif ply:GetInfoNum('mwsas_searcher_bind', 0) == _exp_0 then
      ply:ConCommand('mwsas_wepsearch')
    end
  end)
  return hook.Add('PlayerButtonUp', 'MWS&S', function(ply, button)
    if button == ply:GetInfoNum('mwsas_selector_bind', 0) then
      ply:ConCommand('-mwsas_wepsel')
    end
  end)
end
