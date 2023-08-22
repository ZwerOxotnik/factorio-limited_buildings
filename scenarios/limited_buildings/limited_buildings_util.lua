local limited_buildings_util = {build = 2}


local call = remote.call


--- Please don't use because it can cause lags
---@return table<string, table>
function limited_buildings_util.get_mod_data()
	return call("limited_buildings", "get_mod_data")
end


---@param name string
---@param count uint|nil
function limited_buildings_util.set_global_limitiations_by_name(name, count)
	call("limited_buildings", "set_global_limitiations_by_name", name, count)
end


---@param name string
---@param count uint|nil
function limited_buildings_util.set_global_limitiations_by_type(name, count)
	call("limited_buildings", "set_global_limitiations_by_type", name, count)
end


---@param force_index uint
---@param name string
---@param count uint|nil
function limited_buildings_util.set_force_limit_by_type(force_index, name, count)
	call("limited_buildings", "set_force_limit_by_type", force_index, name, count)
end


---@param force_index uint
---@param name string
---@param count uint|nil
function limited_buildings_util.set_force_limit_by_name(force_index, name, count)
	call("limited_buildings", "set_force_limit_by_name", force_index, name, count)
end


---@param force_index uint
---@param name string
---@param count uint|nil
function limited_buildings_util.set_force_entities_by_type(force_index, name, count)
	call("limited_buildings", "set_force_entities_by_type", force_index, name, count)
end


---@param force_index uint
---@param name string
---@param count uint|nil
function limited_buildings_util.set_force_entities_by_name(force_index, name, count)
	call("limited_buildings", "set_force_entities_by_name", force_index, name, count)
end


---@param name string
---@return uint?
function limited_buildings_util.get_global_limitiations_by_name(name)
	return call("limited_buildings", "get_global_limitiations_by_name", name)
end


---@param name string
---@return uint?
function limited_buildings_util.get_global_limitiations_by_type(name)
	return call("limited_buildings", "get_global_limitiations_by_type", name)
end


---@param force_index uint
---@param name string
---@return uint?
function limited_buildings_util.get_force_limit_by_type(force_index, name)
	return call("limited_buildings", "get_force_limit_by_type", force_index, name)
end


---@param force_index uint
---@param name string
---@return uint?
function limited_buildings_util.get_force_limit_by_name(force_index, name)
	return call("limited_buildings", "get_force_limit_by_name", force_index, name)
end


---@param force_index uint
---@param name string
---@return uint?
function limited_buildings_util.get_force_entities_by_type(force_index, name)
	return call("limited_buildings", "get_force_entities_by_type", force_index, name)
end


---@param force_index uint
---@param name string
---@return uint?
function limited_buildings_util.get_force_entities_by_name(force_index, name)
	return call("limited_buildings", "get_force_entities_by_name", force_index, name)
end


---@param force_index uint
---@return table<string, uint>
function limited_buildings_util.get_force_limit_by_types_data(force_index)
	return call("limited_buildings", "get_force_limit_by_types_data", force_index)
end


---@param force_index uint
---@return table<string, uint>
function limited_buildings_util.get_force_limit_by_names_data(force_index)
	return call("limited_buildings", "get_force_limit_by_names_data", force_index)
end


---@param force_index uint
---@return table<string, integer>
function limited_buildings_util.get_force_entities_by_types_data(force_index)
	return call("limited_buildings", "get_force_entities_by_types_data", force_index)
end


---@param force_index uint
---@return table<string, integer>
function limited_buildings_util.get_force_entities_by_name_data(force_index)
	return call("limited_buildings", "get_force_entities_by_name_data", force_index)
end


---@param name string
---@param count integer
function limited_buildings_util.add_global_limitiations_by_name(name, count)
	call("limited_buildings", "add_global_limitiations_by_name", name, count)
end


---@param name string
---@param count integer
function limited_buildings_util.add_global_limitiations_by_type(name, count)
	call("limited_buildings", "add_global_limitiations_by_type", name, count)
end


---@param force_index uint
---@param name string
---@param count integer
function limited_buildings_util.add_force_limit_by_type(force_index, name, count)
	call("limited_buildings", "add_force_limit_by_type", force_index, name, count)
end


---@param force_index uint
---@param name string
---@param count integer
function limited_buildings_util.add_force_limit_by_name(force_index, name, count)
	call("limited_buildings", "add_force_limit_by_name", force_index, name, count)
end


---@param force_index uint
---@param name string
---@param count integer
function limited_buildings_util.add_force_entities_by_type(force_index, name, count)
	call("limited_buildings", "add_force_entities_by_type", force_index, name, count)
end


---@param force_index uint
---@param name string
---@param count integer
function limited_buildings_util.add_force_entities_by_name(force_index, name, count)
	call("limited_buildings", "add_force_entities_by_name", force_index, name, count)
end


---@param force_index uint
function limited_buildings_util.add_force_to_blacklist(force_index)
	call("limited_buildings", "add_force_to_blacklist", force_index)
end


---@param force_index uint
function limited_buildings_util.remove_force_from_blacklist(force_index)
	call("limited_buildings", "remove_force_from_blacklist", force_index)
end


---@param force_index uint
function limited_buildings_util.add_force_to_global_limit_blacklist(force_index)
	call("limited_buildings", "add_force_to_global_limit_blacklist", force_index)
end


---@param force_index uint
function limited_buildings_util.remove_force_from_global_limit_blacklist(force_index)
	call("limited_buildings", "remove_force_from_global_limit_blacklist", force_index)
end


---@param name string
---@param count uint|nil
function limited_buildings_util.set_default_force_limit_by_type(name, count)
	call("limited_buildings", "set_default_force_limit_by_type", name, count)
end


---@param name string
---@param count uint|nil
function limited_buildings_util.set_default_force_limit_by_name(name, count)
	call("limited_buildings", "set_default_force_limit_by_name", name, count)
end


---@param name string
function limited_buildings_util.get_default_force_limit_by_type(name)
	call("limited_buildings", "get_default_force_limit_by_type", name)
end


---@param name string
function limited_buildings_util.get_default_force_limit_by_name(name)
	call("limited_buildings", "get_default_force_limit_by_name", name)
end


---@param name string
---@param count integer
function limited_buildings_util.add_default_force_limit_by_type(name, count)
	call("limited_buildings", "add_default_force_limit_by_type", name, count)
end


---@param name string
---@param count integer
function limited_buildings_util.add_default_force_limit_by_name(name, count)
	call("limited_buildings", "add_default_force_limit_by_name", name, count)
end


return limited_buildings_util
