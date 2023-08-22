local ENTITY_TYPES = require("scenarios/limited_buildings/entity_types")
local settings = {}


for _, type_name in ipairs(ENTITY_TYPES) do
	settings[#settings+1] = {
		type = "int-setting",
        name = "LBZO_" .. type_name .. "_limit",
		minimum_value = -1,
		default_value =  -1,
        setting_type = "runtime-global",
		localised_name = {"", type_name .. " ", {"limited_buildings.limit"}}
	}
end


data:extend(settings)
