function GM:StartVote(ply, typ, target)
	if (self.CurrentVote and self.CurrentVote.nextVoteAvailability > CurTime()) then
		hook.Run("SendVoteResult", ply, RTG_VOTERESULT_COOLDOWN)
	else
		self.CurrentVote = {typ=typ, target=target, expiry=CurTime()+20, nextVoteAvailability=CurTime()+25}
		hook.Run("SendVoteStatus")
	end
end

function GM:SendVoteStatus()
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_VOTESTATUS, 8)
	net.WriteFloat(self.CurrentVote.expiry)
	net.WriteUInt(self.CurrentVote.typ, 8)
	net.WriteInt(self.CurrentVote.target, 16)
	net.Broadcast()
end

function GM:SendVoteResult(ply, result)
	net.Start("rotgb_gamemode")
	net.WriteUInt(RTG_OPERATION_VOTE, 8)
	net.WriteUInt(RTG_VOTERESULT_COOLDOWN, 8)
	net.Send(ply)
end