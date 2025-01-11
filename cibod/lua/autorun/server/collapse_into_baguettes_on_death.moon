MsgC(
    Color(0, 255, 255),
    "Collapse Into Baguettes On Death ",
    Color(255, 255, 0),
    "1.0.0 (2024-12-28) ",
    color_white,
    "by Piengineer12\n"
)

ConVarE = CreateConVar "cibod_enabled", "1", FCVAR_ARCHIVE,
    "Enables Collapse Into Baguettes On Death."
ConVarF = CreateConVar "cibod_frozen", "0", FCVAR_ARCHIVE,
    "Baguettes are physically frozen."
ConVarN = CreateConVar "cibod_enabled_npc", "0", FCVAR_ARCHIVE,
    "Enables CIBOD for NPC deaths. The original NPC corpse will still remain visible unfortunately."
ConVarL = CreateConVar "cibod_minbonelength", "8", FCVAR_ARCHIVE,
    "Minimum bone length required to create a baguette. Lower numbers result in more baguettes."
ConVarT = CreateConVar "cibod_lifetime", "30", FCVAR_ARCHIVE,
    "Delay before baguettes are deleted."
ConVarM = CreateConVar "cibod_model", "models/weapons/c_models/c_bread/c_bread_baguette.mdl", FCVAR_ARCHIVE,
    "Baguette model to use."

makeBaguette = (ent) ->
    -- ent = ent\GetRagdollEntity!
    entPos = ent\GetPos!
    throwVel = ent\GetVelocity!
    minDist = ConVarL\GetFloat!
    lifeTime = ConVarT\GetFloat!

    for i = ent\GetBoneCount! - 1, 0, -1
        m = ent\GetBoneMatrix i
        pos = m\GetTranslation!

        if ent\BoneLength(i) >= minDist and pos ~= entPos
            parent = ent\GetBoneParent i
            iter = 0
            while parent > 0
                iter += 1
                break if iter > 1000
                m = ent\GetBoneMatrix parent
                parentPos = m\GetTranslation!
                -- print i, ent\GetBoneName(i), parent, pos, parentPos
                -- debugColor = ColorRand!
                -- debugoverlay.Cross pos, 2, 20, debugColor
                -- debugoverlay.Line pos, parentPos, 20, debugColor

                if minDist > parentPos\DistToSqr(pos)
                    parent = ent\GetBoneParent parent
                else
                    ang = (pos - parentPos)\Angle!
                    pos = (pos + parentPos) / 2

                    bread = ents.Create "prop_physics"
                    if IsValid bread
                        with bread
                            \SetModel ConVarM\GetString!
                            \SetPos pos
                            \SetAngles ang
                            \Spawn!
                            \SetCollisionGroup COLLISION_GROUP_DEBRIS
                        
                            phys = \GetPhysicsObject!
                            if IsValid phys
                                phys\SetVelocity throwVel
                                phys\EnableMotion false if ConVarF\GetBool!
                        
                        SafeRemoveEntityDelayed bread, lifeTime
                    break

-- concommand.Add "cibod", (ply) ->
--     makeBaguette ply

hook.Add "PostPlayerDeath", "cibod", (ply) ->
    if ConVarE\GetBool!
        effData = with EffectData!
            \SetOrigin ply\GetPos!
        util.Effect "Explosion", effData
        makeBaguette ply

        SafeRemoveEntity ply\GetRagdollEntity!
    return

hook.Add "OnNPCKilled", "cibod", (ply) ->
    if ConVarN\GetBool!
        effData = with EffectData!
            \SetOrigin ply\GetPos!
        util.Effect "Explosion", effData
        makeBaguette ply
    return