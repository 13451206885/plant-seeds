GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
PrefabFiles={

}--添加预制物文件
Assets={

}--载入资源

TUNING.SEED_BM=GetModConfigData("seeds")
local upvaluehelper = require "components/upvaluehelper"
AddPrefabPostInit("birdcage", function (birdcage)
    if not TheWorld.ismastersim then
        return birdcage
    end
    local fn=birdcage.components.trader.onaccept
    local DigestFood = upvaluehelper.Get(fn,"DigestFood")
    if DigestFood then
        local DigestFood_new=function (inst, food)
            DigestFood(inst,food)
            if food.components.edible.foodtype ~= FOODTYPE.MEAT then
                if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
                    -- inst.components.lootdropper:SpawnLootPrefab("spoiled_food")
                else
                    local seed_name = string.lower(food.prefab .. "_seeds")
                    if math.random()<=TUNING.SEED_BM then
                        inst.components.lootdropper:SpawnLootPrefab(seed_name)
                    end
                    inst.components.lootdropper:SpawnLootPrefab("seeds")
                end
            end
        end
        upvaluehelper.Set(fn,"DigestFood",DigestFood_new)
    end
end)
