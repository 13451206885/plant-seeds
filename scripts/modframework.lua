local pcall = GLOBAL.pcall
local require = GLOBAL.require
-- 导入各种杂项，必须写在最前面
local things_status,things_data = pcall(require,"resources/fu_things")
if things_status then
    -- 导入自定义制作栏图标
    --	env.AddRecipeFilter = function(filter_def, index)
    if things_data.Recipetabs then
        for _,data in pairs(things_data.Recipetabs) do
            AddRecipeFilter(data.filter_def, data.index)
        end
    end
end

-- filters = {"TOOLS", "LIGHT"}
-- env.AddRecipe2 = function(name, ingredients, tech, config, filters)

-- name, ingredients, tab, level, placer, min_spacing, nounlock,numtogive, builder_tag, atlas, image, testfn
-- 导入可制作物品/烹饪品/食物值
local recipes_status,recipes_data = pcall(require,"resources/fu_recipes")
if recipes_status then
    -- 导入自定义可制作物品
    if recipes_data.Recipes then
        for _,data in pairs(recipes_data.Recipes) do
            AddRecipe2(data.name, data.ingredients, data.level, data.config,data.filters)
        end
    end
    -- 导入自定义食物值
    if recipes_data.IngredientValues then
        for _,data in pairs(recipes_data.IngredientValues) do
            AddIngredientValues(data.names, data.tags, data.cancook, data.candry)
        end
    end
end

-- -- 导入新state
local states_status,states_data = pcall(require,"resources/fu_states")
if states_status then
    -- 导入state
    if states_data.states then
        for _,state in pairs(states_data.states) do
            AddStategraphState("wilson", state)
        end
    end
    -- 导入客机state
    if states_data.states_client then
        for _,state in pairs(states_data.states_client) do
            AddStategraphState("wilson_client", state)
        end
    end
end

local actions_status,actions_data = pcall(require,"resources/fu_actions")
if actions_status then
    -- 导入自定义动作
    if actions_data.actions then
        for _,act in pairs(actions_data.actions) do
            local action = AddAction(act.id,act.str,act.fn)
            if act.actiondata then
                for k,data in pairs(act.actiondata) do
                    action[k] = data
                end
            end
            AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(action, act.state))
            AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(action,act.state))
        end
    end
    -- 导入动作与组件的绑定
    if actions_data.component_actions then
        for _,v in pairs(actions_data.component_actions) do
            local testfn = function(...)
                local actions = GLOBAL.select (-2,...)
                for _,data in pairs(v.tests) do
                    if data and data.testfn and data.testfn(...) then
                        data.action = string.upper( data.action )
                        table.insert( actions, GLOBAL.ACTIONS[data.action] )
                    end
                end
            end
            AddComponentAction(v.type, v.component, testfn)
        end
    end
end
