-- name, ingredients, tab, level, placer, min_spacing, nounlock,numtogive, builder_tag, atlas, image, testfn
--     {--铱矿
--         name="iridium",
--         ingredients={
--             Ingredient("iridium_break", 3,"images/inventoryimages/iridium_break.xml"),--铱矿碎片3
--         },
--         tab=CUSTOM_RECIPETABS["TAB_LEGEND"],
--         level=TECH.MAGIC_THREE,
--         placer={no_deconstruction = true},
--         atlas = "images/inventoryimages/iridium.xml",
--     },
-- name, ingredients, tab, level, placer, min_spacing, nounlock,numtogive, builder_tag, atlas, image, testfn
--env.AddRecipe2 = function(name, ingredients, tech, config, filters)
local Recipes = {
    {--寺庙
        name="temple",
        ingredients={
            Ingredient("boards", 5),--木板
            Ingredient("meat", 2)--肉
        },
        tech=TECH.SCIENCE_TWO,
        config={
            placer="temple_placer",
            atlas = "images/temple.xml",
            image="temple.tex"
        },
        filters={"福"},--参数过滤器
    },
}

local IngredientValues = {
    -- {
    --     names = {"seeds"}, -- prefab名，可以设置多个
    --     tags = {seeds = 1}, -- 属性值，可以设置多个
    --     cancook = true, -- 是否可以烹饪
    --     candry = false -- 是否可以晾干
    -- },
    -- {
    --     names = {"beardhair"}, -- prefab名，可以设置多个
    --     tags = {beardhair = 1}, -- 属性值，可以设置多个
    --     cancook = true, -- 是否可以烹饪
    --     candry = false -- 是否可以晾干
    -- },
}
return {Recipes = Recipes, IngredientValues = IngredientValues}
