function GM:StartVote(ply, typ, target, reason)
	if typ == RTG_VOTE_CHANGEDIFFICULTY and not GAMEMODE.Modes[target] then
		hook.Run("SendVoteResult", ply, RTG_VOTERESULT_NOTARGET)
	elseif typ == RTG_VOTE_MAP and string.sub(target, 1, 6) ~= "rotgb_" then
		hook.Run("SendVoteResult", ply, RTG_VOTERESULT_NOTARGET)
	end
	local currentVote = hook.Run("GetCurrentVote")
	if (currentVote and currentVote.nextVoteAvailability > RealTime()) then
		hook.Run("SendVoteResult", ply, RTG_VOTERESULT_COOLDOWN)
	else
		hook.Run("SetCurrentVote", {
			typ=typ,
			initiator=ply,
			target=target,
			startTime=RealTime(),
			expiry=RealTime()+self.VoteTime,
			nextVoteAvailability=RealTime()+self.VoteTime+5,
			reason=reason,
			agrees=0,
			disagrees=0,
			votedPlayers={},
			metadata={}
		})
		hook.Run("SendNewVote")
	end
end

function GM:SendNewVote()
	local currentVote = hook.Run("GetCurrentVote")
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_VOTESTART, 4)
	net.WriteInt(currentVote.initiator:UserID(), 16)
	net.WriteFloat(currentVote.expiry)
	net.WriteFloat(currentVote.startTime)
	net.WriteUInt(currentVote.typ, 4)
	net.WriteString(currentVote.target)
	net.WriteString(currentVote.reason or "")
	net.Broadcast()
end

function GM:AddToCurrentVote(ply, agree)
	local currentVote = hook.Run("GetCurrentVote")
	local userID = ply:UserID()
	if currentVote.votedPlayers[userID] then
		if (currentVote.votedPlayers[userID]==1) ~= agree then
			if agree then
				currentVote.disagrees = currentVote.disagrees - 1
			else
				currentVote.agrees = currentVote.agrees - 1
			end
		else return false
		end
	end
	if agree then
		currentVote.agrees = currentVote.agrees + 1
	else
		currentVote.disagrees = currentVote.disagrees + 1
	end
	currentVote.votedPlayers[userID] = agree and 1 or 2
	
	return true
end

function GM:SyncCurrentVote()
	local currentVote = hook.Run("GetCurrentVote")
	net.Start("rotgb_statchanged")
	net.WriteUInt(RTG_STAT_VOTES, 4)
	net.WriteUInt(currentVote.agrees, 8)
	net.WriteUInt(currentVote.disagrees, 8)
	net.Broadcast()
end

function GM:CurrentVoteThink()
	local currentVote = hook.Run("GetCurrentVote")
	if currentVote then
		if currentVote.expiry<RealTime() or currentVote.agrees+currentVote.disagrees == player.GetCount() then
			hook.Run("ResolveCurrentVote")
		elseif currentVote.typ==RTG_VOTE_KICK then
			local ply = Player(tonumber(currentVote.target) or -1)
			if IsValid(ply) then
				if not currentVote.metadata.userName then
					currentVote.metadata.userName = ply:Nick()
				elseif currentVote.metadata.userName ~= ply:Nick() then -- the player is trying to dodge, kick the player immediately
					ply:Kick()
					hook.Run("ClearAndSendVoteResult", RTG_VOTERESULT_KICKBYCHANGEDNICK)
				end
			else
				hook.Run("ClearAndSendVoteResult", RTG_VOTERESULT_NOTARGET)
			end
		end
	end
end

function GM:ClearAndSendVoteResult(result)
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_VOTEEND, 4)
	net.WriteUInt(result, 4)
	net.Broadcast()
	
	hook.Run("SetCurrentVote")
end

function GM:ResolveCurrentVote()
	local currentVote = hook.Run("GetCurrentVote")
	
	if currentVote.agrees > currentVote.disagrees then
		local target = currentVote.target
		local typ = currentVote.typ
		if typ == RTG_VOTE_KICK then
			target = Player(tonumber(target) or -1)
			if IsValid(target) then
				timer.Simple(0.5,function()
					target:Kick("#rotgb_tg.voting.result.kick.recipient")
				end)
			else
				return hook.Run("ClearAndSendVoteResult", RTG_VOTERESULT_NOTARGET)
			end
		elseif typ == RTG_VOTE_CHANGEDIFFICULTY then
			timer.Simple(5, function()
				hook.Run("ChangeDifficulty", target)
			end)
		elseif typ == RTG_VOTE_RESTART then
			if target == "1" then
				timer.Simple(5, function()
					hook.Run("CleanUpMap")
				end)
			elseif target == "2" then
				timer.Simple(5, function()
					RunConsoleCommand("changelevel", game.GetMap())
				end)
			end
		elseif typ == RTG_VOTE_MAP then
			timer.Simple(5, function()
				RunConsoleCommand("changelevel", target)
			end)
		end
		
		hook.Run("ClearAndSendVoteResult", RTG_VOTERESULT_AGREED)
	else
		hook.Run("ClearAndSendVoteResult", RTG_VOTERESULT_DISAGREED)
	end
end

function GM:SendVoteResult(ply, result)
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_VOTEEND, 4)
	net.WriteUInt(result, 4)
	net.Send(ply)
end