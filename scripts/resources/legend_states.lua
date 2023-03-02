local function OnRemoveCleanupTargetFX(inst)
    if inst.sg.statemem.targetfx.KillFX ~= nil then
        inst.sg.statemem.targetfx:RemoveEventCallback("onremove", OnRemoveCleanupTargetFX, inst)
        inst.sg.statemem.targetfx:KillFX()
    else
        inst.sg.statemem.targetfx:Remove()
    end
end
local states = {
    State{
        name = "battleshout",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local songdata = buffaction and buffaction.invobject.songdata or nil

            if songdata ~= nil then
                inst.AnimState:PlayAnimation("sing_pre", false)
                inst.AnimState:PushAnimation(songdata.INSTANT and "quote" or "sing", false)
                if songdata.INSTANT then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_" .. string.upper(songdata.NAME)), nil, true)
                end
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                local buffaction = inst:GetBufferedAction()
                local songdata = buffaction and buffaction.invobject.songdata or nil
                if songdata then
                    inst.SoundEmitter:PlaySound(songdata.SOUND or ("dontstarve_DLC001/characters/wathgrithr/"..(songdata.INSTANT and "quote" or "sing")))
                end
            end),

            TimeEvent(24 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(34 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nointerrupt")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "legend_castspell",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()
--[[
                local x,y,z=inst:GetPosition():Get()
            fx.Transform:SetPosition(x,y+1,z)
            fx:DoTaskInTime(0.3,fx.Remove)
            
]]
            --Spawn an effect on the player's location
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local colour = staff ~= nil and staff.fxcolour or { 1, 1, 1 }

            -- inst.sg.statemem.stafffx = SpawnPrefab(inst.components.rider:IsRiding() and "staffcastfx_mount" or "staffcastfx")
            -- inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            -- inst.sg.statemem.stafffx:SetUp(colour)


            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)

            if staff ~= nil and staff.components.aoetargeting ~= nil and staff.components.aoetargeting.targetprefab ~= nil then
                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst.sg.statemem.targetfx = SpawnPrefab(staff.components.aoetargeting.targetprefab)
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx.Transform:SetPosition(buffaction:GetActionPoint():Get())
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end

            inst.sg.statemem.castsound = staff ~= nil and staff.castsound or "dontstarve/wilson/use_gemstaff"
        end,
        --SpawnPrefab("positronbeam_front")
        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                local fx=SpawnPrefab("positronbeam_front")
                local x,y,z=inst:GetPosition():Get()
                fx.Transform:SetPosition(x,y+2,z)
                fx:DoTaskInTime(2,fx.Remove)
            end),
            TimeEvent(6 * FRAMES, function(inst)
                local fx=SpawnPrefab("positronbeam_back")
                local x,y,z=inst:GetPosition():Get()
                fx.Transform:SetPosition(x,y+2,z)
                fx:DoTaskInTime(2,fx.Remove)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(53 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        OnRemoveCleanupTargetFX(inst)
                    end
                    inst.sg.statemem.targetfx = nil
                end
                inst.sg.statemem.stafffx = nil --Can't be cancelled anymore
                inst.sg.statemem.stafflight = nil --Can't be cancelled anymore
                --V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },
    State{
        name = "battleshout2",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("sing_pre", false)
            inst.AnimState:PushAnimation("quote", false)
            inst.components.talker:Say(STRINGS.ACTIONS.LIGHTNING_SAYS, nil, true)
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                local buffaction = inst:GetBufferedAction()
                -- local songdata = buffaction and buffaction.invobject.songdata or nil
                -- if songdata then
                --     inst.SoundEmitter:PlaySound(songdata.SOUND or ("dontstarve_DLC001/characters/wathgrithr/"..(songdata.INSTANT and "quote" or "sing")))
                -- end
            end),

            TimeEvent(24 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(34 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nointerrupt")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

local TIMEOUT = 2

local states_client = {
    State{
        name = "battleshout",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("sing_pre", false)
            inst.AnimState:PushAnimation("sing_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst:HasTag("busy") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },
    State{
        name = "battleshout2",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("sing_pre", false)
            inst.AnimState:PushAnimation("sing_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst:HasTag("busy") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },
    State{
        name = "legend_castspell",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },
}

return {
    states = states,
    states_client = states_client,
}
