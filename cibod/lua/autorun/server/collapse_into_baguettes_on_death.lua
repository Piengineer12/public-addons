MsgC(Color(0, 255, 255), "Collapse Into Baguettes On Death ", Color(255, 255, 0), "1.0.0 (2024-12-19) ", color_white, "by Piengineer12\n")
local ConVarE = CreateConVar("cibod_enabled", "1", FCVAR_ARCHIVE, "Enables Collapse Into Baguettes On Death.")
local ConVarF = CreateConVar("cibod_frozen", "0", FCVAR_ARCHIVE, "Baguettes are physically frozen.")
local ConVarN = CreateConVar("cibod_enabled_npc", "0", FCVAR_ARCHIVE, "Enables CIBOD for NPC deaths. The original NPC corpse will still remain visible unfortunately.")
local ConVarL = CreateConVar("cibod_minbonelength", "8", FCVAR_ARCHIVE, "Minimum bone length required to create a baguette. Lower numbers result in more baguettes.")
local ConVarT = CreateConVar("cibod_lifetime", "30", FCVAR_ARCHIVE, "Delay before baguettes are deleted.")
local ConVarM = CreateConVar("cibod_model", "models/weapons/c_models/c_bread/c_bread_baguette.mdl", FCVAR_ARCHIVE, "Baguette model to use.")
local makeBaguette
makeBaguette = function(ent)
  local entPos = ent:GetPos()
  local throwVel = ent:GetVelocity()
  local minDist = ConVarL:GetFloat()
  local lifeTime = ConVarT:GetFloat()
  for i = ent:GetBoneCount() - 1, 0, -1 do
    local m = ent:GetBoneMatrix(i)
    local pos = m:GetTranslation()
    if ent:BoneLength(i) >= minDist and pos ~= entPos then
      local parent = ent:GetBoneParent(i)
      local iter = 0
      while parent > 0 do
        iter = iter + 1
        if iter > 1000 then
          break
        end
        m = ent:GetBoneMatrix(parent)
        local parentPos = m:GetTranslation()
        if minDist > parentPos:DistToSqr(pos) then
          parent = ent:GetBoneParent(parent)
        else
          local ang = (pos - parentPos):Angle()
          pos = (pos + parentPos) / 2
          local bread = ents.Create("prop_physics")
          if IsValid(bread) then
            do
              bread:SetModel(ConVarM:GetString())
              bread:SetPos(pos)
              bread:SetAngles(ang)
              bread:Spawn()
              bread:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
              local phys = bread:GetPhysicsObject()
              if IsValid(phys) then
                phys:SetVelocity(throwVel)
                if ConVarF:GetBool() then
                  phys:EnableMotion(false)
                end
              end
            end
            SafeRemoveEntityDelayed(bread, lifeTime)
          end
          break
        end
      end
    end
  end
end
hook.Add("PostPlayerDeath", "cibod", function(ply)
  if ConVarE:GetBool() then
    local effData
    do
      local _with_0 = EffectData()
      _with_0:SetOrigin(ply:GetPos())
      effData = _with_0
    end
    util.Effect("Explosion", effData)
    makeBaguette(ply)
    SafeRemoveEntity(ply:GetRagdollEntity())
  end
end)
return hook.Add("OnNPCKilled", "cibod", function(ply)
  if ConVarN:GetBool() then
    local effData
    do
      local _with_0 = EffectData()
      _with_0:SetOrigin(ply:GetPos())
      effData = _with_0
    end
    util.Effect("Explosion", effData)
    makeBaguette(ply)
  end
end)
