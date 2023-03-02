local actions = {
    {
        id = "BATTLESHOT",--战吼
        str = STRINGS.ACTIONS.BATTLESHOT,--战吼--Battle shout
        actiondata = {
            -- priority=0,rmb=true
        },
        fn = function(act)
            if act.doer ~= nil and act.invobject ~= nil then
                if act.doer.components.legend_pets and next(act.doer.components.legend_pets.pets) then
                    local pets=act.doer.components.legend_pets.pets
                    for i,v in pairs(pets)do
                        if v.FocusTarget then
                            v:FocusTarget(true)
                        end
                    end
                end
                if act.invobject.components.rechargeable then
                    act.invobject.components.rechargeable:StartRecharge()
                end
                return true
			end
        end,
        state = "battleshout"
    },
    {
        id = "LIGHTNING",--惊雷
        str = STRINGS.ACTIONS.LIGHTNING,--战吼--Battle shout
        actiondata = {
            -- priority=-1,rmb=true
        },
        fn = function(act)
            if act.doer ~= nil and act.invobject ~= nil then
                local fx=SpawnPrefab("lightning")
                local x,y,z=act.doer:GetPosition():Get()
                fx.Transform:SetPosition(x,y,z)
                fx:DoTaskInTime(2,fx.Remove)
                if act.doer.components.debuffable ~= nil and act.doer.components.debuffable:IsEnabled() and
                not (act.doer.components.health ~= nil and act.doer.components.health:IsDead()) and
                not act.doer:HasTag("playerghost") then
                    act.doer.components.debuffable:AddDebuff("buff_electricattack", "buff_electricattack")
                end
                if act.invobject.components.rechargeable then
                    act.invobject.components.rechargeable:StartRecharge()
                end
                if act.invobject.components.fueled then
                    local percent=act.invobject.components.fueled:GetPercent()-0.2
                    act.invobject.components.fueled:SetPercent(percent)
                end
                return true
			end
        end,
        state = "battleshout2"
    },
    {
        id = "CHANGEWORLD",--
        str = STRINGS.ACTIONS.CHANGEWORLD,--改天换地
        fn = function(act)
            if act.doer ~= nil and act.invobject ~= nil then
                if act.invobject.change_world then
                    if act.invobject.components.fueled then
                        local percent=act.invobject.components.fueled:GetPercent()-0.5
                        act.invobject.components.fueled:SetPercent(percent)
                    end

                    act.invobject:change_world()
                    if act.invobject.components.rechargeable then
                        act.invobject.components.rechargeable:StartRecharge()
                    end
                    if act.doer.components.sanity then
                        act.doer.components.sanity:SetPercent(0)--消耗所有
                    end
                end
                return true
			end
        end,
        state = "legend_castspell"
    },
    {
        id = "LEGEND_REPAIR",--
        str = STRINGS.ACTIONS.LEGEND_REPAIR,--修复的动作
        actiondata = {
            priority=0,rmb=true
        },
        fn = function(act)
            if act.doer ~= nil and act.invobject ~= nil then
                if act.invobject.components.legend_repair then
                    act.invobject.components.legend_repair:Repair(act.invobject,act.target,act.doer)
                end
                return true
			end
        end,
        state = "doshortaction"
    },
}
local component_actions = {
    {
        type = "INVENTORY",
        component = "inventoryitem",
        tests = {
            {
                action = "BATTLESHOT",
                testfn = function(inst, doer, target, actions, right)
                    if inst and inst.prefab~="qedge" then return end
                    local recharge = inst.replica.inventoryitem and inst.replica.inventoryitem.classified and
                    inst.replica.inventoryitem.classified.recharge and
                    inst.replica.inventoryitem.classified.recharge:value() or 0
                    local fueled=inst.replica.inventoryitem and inst.replica.inventoryitem.classified and
                    inst.replica.inventoryitem.classified.percentused and
                    inst.replica.inventoryitem.classified.percentused:value() or 100
                    return doer:HasTag("player") and (recharge==180) and fueled>0
                end
            }
        }
    },
    {
        type = "INVENTORY",
        component = "legend_trident",
        tests = {
            {
                action = "LIGHTNING",
                testfn = function(inst, doer, target, actions, right)
                    if inst and inst.prefab~="legend_trident"and not inst:HasTag("bm_trident") then return end
                    local recharge = inst.replica.inventoryitem and inst.replica.inventoryitem.classified and
                    inst.replica.inventoryitem.classified.recharge and
                    inst.replica.inventoryitem.classified.recharge:value() or 0
                    local fueled=inst.replica.inventoryitem and inst.replica.inventoryitem.classified and
                    inst.replica.inventoryitem.classified.percentused and
                    inst.replica.inventoryitem.classified.percentused:value() or 100
                    return doer:HasTag("player") and (recharge==180) and fueled>19
                end
            }
        }
    },
    {
        type = "INVENTORY",
        component = "legend_rechargeable",
        tests = {
            {
                action = "CHANGEWORLD",
                testfn = function(inst, doer, target, actions, right)
                    if inst and inst.prefab~="glass_sword" then return end
                    local recharge = inst.replica.inventoryitem and inst.replica.inventoryitem.classified and
                    inst.replica.inventoryitem.classified.recharge and
                    inst.replica.inventoryitem.classified.recharge:value() or 0
                    local fueled=inst.replica.inventoryitem and inst.replica.inventoryitem.classified and
                    inst.replica.inventoryitem.classified.percentused and
                    inst.replica.inventoryitem.classified.percentused:value() or 100
                    return doer:HasTag("player") and (recharge==180) and fueled>49
                end
            }
        }
    },
    {
        type = "USEITEM",
        component = "legend_repair",
        tests = {
            {
                action = "LEGEND_REPAIR",
                testfn = function(inst, doer, target, actions, right)
                    if inst and inst.prefab~="iridium" then return end
                    return doer:HasTag("player")
                end
            }
        }
    },
}

return {actions = actions, component_actions = component_actions}