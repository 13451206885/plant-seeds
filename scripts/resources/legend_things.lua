local Recipetabs = {
-- filter_def.name: This is the filter's id and will need the string added to STRINGS.UI.CRAFTING_FILTERS[name]
-- filter_def.atlas: atlas for the icon,  can be a string or function
-- filter_def.image: icon to show in the crafting menu, can be a string or function
-- filter_def.image_size: (optional) custom image sizing 
-- filter_def.custom_pos: (optional) This will not be added to the grid of filters
-- filter_def.recipes: !This is not supported! Create the filter and then pass in the filter to AddRecipe2() or AddRecipeToFilter()

{
    filter_def={
        name = "福",
        atlas = "images/tech_tab/Item_list.xml",
        image = "Item_list.tex",
        image_size=64,
        custom_pos=nil,
        recipes=nil,
    },
    -- index = 23,
},
}

return {
    Recipetabs = Recipetabs,
}