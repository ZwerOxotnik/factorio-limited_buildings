Entity_util = require("zk-lib/lualibs/control_stage/entity-util")


local M = {}


--#region Global data
---@class limited_buildings_mod_data
local __mod_data
---@type table<string, uint>
local __global_limitiations_by_names
---@type table<string, uint>
local __global_limitiations_by_types
---@type table<uint, table<string, uint>>
local __force_limit_by_types
---@type table<uint, table<string, uint>>
local __force_limit_by_names
---@type table<uint, table<string, integer>>
local __force_entities_by_types
---@type table<uint, table<string, integer>>
local __force_entities_by_names
---@type table<uint, true>
local __forces_blacklist
---@type table<uint, true>
local __forces_global_limit_blacklist
--#endregion


local ENTITY_TYPES = require("scenarios/limited_buildings/entity_types")
local DESTROY_PARAM = {raise_destroy = true}
local __warning_locale_text = {"limited_buildings.warning_limit", 0}
local __flying_text_param = {
	text = __warning_locale_text, create_at_cursor=true,
	color = {1, 0, 0}, time_to_live = 210,
	speed = 0.1
}
local draw_text = rendering.draw_text
local __render_text_position = {0, 0}
local __render_target_forces = {nil}
local __render_text_param = {
	text = __warning_locale_text,
	target = __render_text_position,
	surface = nil,
	forces = __render_target_forces,
	scale = 1,
	time_to_live = 210,
	color = {200, 0, 0}
}


remote.add_interface("limited_buildings", {
	getSource = function()
		local mod_name = script.mod_name
		rcon.print(mod_name) -- Returns "level" if it's a scenario, otherwise "entities_drop_content" as a mod.
		return mod_name
	end,
	get_mod_data = function() -- Please don't use because it can cause lags
		return __mod_data
	end,
	set_global_limitiations_by_name = function(name, count)
		__global_limitiations_by_names[name] = count
	end,
	set_global_limitiations_by_type = function(name, count)
		__global_limitiations_by_types[name] = count

		local setting_name = "LBZO_" .. name .. "_limit"
		local setting = settings.global[setting_name]
		if setting then
			setting = {
				value = count or -1
			}
		end
	end,
	set_force_limit_by_type = function(force_index, name, count)
		if count == nil then
			__force_limit_by_types[force_index] = nil
			return
		end

		local force_data = __force_limit_by_types[force_index]
		if force_data then
			force_data[name] = count
		else
			__force_limit_by_types[force_index] = {[name] = count}
		end
	end,
	set_force_limit_by_name = function(force_index, name, count)
		if count == nil then
			__force_limit_by_names[force_index] = nil
			return
		end

		local force_data = __force_limit_by_names[force_index]
		if force_data then
			force_data[name] = count
		else
			__force_limit_by_names[force_index] = {[name] = count}
		end
	end,
	set_force_entities_by_type = function(force_index, name, count)
		if count == nil then
			__force_entities_by_types[force_index] = nil
			return
		end

		local force_data = __force_entities_by_types[force_index]
		if force_data then
			force_data[name] = count
		else
			__force_entities_by_types[force_index] = {[name] = count}
		end
	end,
	set_force_entities_by_name = function(force_index, name, count)
		if count == nil then
			__force_entities_by_names[force_index] = nil
			return
		end

		local force_data = __force_entities_by_names[force_index]
		if force_data then
			force_data[name] = count
		else
			__force_entities_by_names[force_index] = {[name] = count}
		end
	end,
	get_global_limitiations_by_name = function(name)
		return __global_limitiations_by_names[name]
	end,
	get_global_limitiations_by_type = function(name)
		return __global_limitiations_by_types[name]
	end,
	get_force_limit_by_type = function(force_index, name)
		local force_data = __force_limit_by_types[force_index]
		if force_data then
			return force_data[name]
		end
	end,
	get_force_limit_by_name = function(force_index, name)
		local force_data = __force_limit_by_names[force_index]
		if force_data then
			return force_data[name]
		end
	end,
	get_force_entities_by_type = function(force_index, name)
		local force_data = __force_entities_by_types[force_index]
		if force_data then
			return force_data[name]
		end
	end,
	get_force_entities_by_name = function(force_index, name)
		local force_data = __force_entities_by_names[force_index]
		if force_data then
			return force_data[name]
		end
	end,
	get_force_limit_by_types_data = function(force_index)
		return __force_limit_by_types[force_index]
	end,
	get_force_limit_by_names_data = function(force_index)
		return __force_limit_by_names[force_index]
	end,
	get_force_entities_by_types_data = function(force_index)
		return __force_entities_by_types[force_index]
	end,
	get_force_entities_by_name_data = function(force_index)
		return __force_entities_by_names[force_index]
	end,
	add_global_limitiations_by_name = function(name, count)
		local result = (__global_limitiations_by_names[name] or 0) + count
		__global_limitiations_by_names[name] = result
	end,
	add_global_limitiations_by_type = function(name, count)
		local result = (__global_limitiations_by_types[name] or 0) + count
		if result < 0 then
			__global_limitiations_by_types[name] = nil
			result = nil
		else
			__global_limitiations_by_types[name] = result
		end

		local setting_name = "LBZO_" .. name .. "_limit"
		local setting = settings.global[setting_name]
		if setting then
			setting = {
				value = result or -1
			}
		end
	end,
	add_force_limit_by_type = function(force_index, name, count)
		local force_data = __force_limit_by_types[force_index]
		if force_data then
			local result = force_data[name] + count
			if result >= 0 then
				force_data[name] = force_data[name] + count
			else
				force_data[name] = nil
			end
		elseif count > 0 then
			__force_limit_by_types[force_index] = {[name] = count}
		end
	end,
	add_force_limit_by_name = function(force_index, name, count)
		local force_data = __force_limit_by_names[force_index]
		if force_data then
			local result = force_data[name] + count
			if result >= 0 then
				force_data[name] = force_data[name] + count
			else
				force_data[name] = nil
			end
		elseif count > 0 then
			__force_limit_by_names[force_index] = {[name] = count}
		end
	end,
	add_force_entities_by_type = function(force_index, name, count)
		local force_data = __force_entities_by_types[force_index]
		if force_data then
			force_data[name] = force_data[name] + count
		elseif count > 0 then
			__force_entities_by_types[force_index] = {[name] = count}
		end
	end,
	add_force_entities_by_name = function(force_index, name, count)
		local force_data = __force_entities_by_names[force_index]
		if force_data then
			force_data[name] = force_data[name] + count
		elseif count > 0 then
			__force_entities_by_names[force_index] = {[name] = count}
		end
	end,
	add_force_to_blacklist = function(force_index)
		__forces_blacklist[force_index] = true
		__force_limit_by_types[force_index] = nil
		__force_limit_by_names[force_index] = nil
		__force_entities_by_types[force_index] = nil
		__force_entities_by_names[force_index] = nil
	end,
	remove_force_from_blacklist = function(force_index)
		__forces_blacklist[force_index] = nil
		M.init_force(force_index)
	end,
	add_force_to_global_limit_blacklist = function(force_index)
		__forces_global_limit_blacklist[force_index] = true
	end,
	remove_force_from_global_limit_blacklist = function(force_index)
		__forces_global_limit_blacklist[force_index] = nil
	end,
	set_default_force_limit_by_type = function(name, count)
		__mod_data.default_force_limit_by_types[name] = count
	end,
	set_default_force_limit_by_name = function(name, count)
		__mod_data.default_force_limit_by_names[name] = count
	end,
	get_default_force_limit_by_type = function(name)
		return __mod_data.default_force_limit_by_types[name]
	end,
	get_default_force_limit_by_name = function(name)
		return __mod_data.default_force_limit_by_names[name]
	end,
	add_default_force_limit_by_type = function(name, count)
		local init_count = __mod_data.default_force_limit_by_types[name]
		local result = (init_count or 0) + count
		if result < 0 then
			__mod_data.default_force_limit_by_types[name] = nil
		else
			__mod_data.default_force_limit_by_types[name] = result
		end
	end,
	add_default_force_limit_by_name = function(name, count)
		local init_count = __mod_data.default_force_limit_by_names[name]
		local result = (init_count or 0) + count
		if result < 0 then
			__mod_data.default_force_limit_by_names[name] = nil
		else
			__mod_data.default_force_limit_by_names[name] = result
		end
	end,
})


local _render_tick = -1
---@param entity LuaEntity
---@param max_count integer
---@param player LuaPlayer?
local function remove_entity(entity, max_count, player, is_ghost)
	__warning_locale_text[2] = max_count

	if player and player.valid then
		if game.tick ~= _render_tick then
			player.create_local_flying_text(__flying_text_param)
			_render_tick = game.tick
		end
		if is_ghost then
			entity.destroy(DESTROY_PARAM)
		else
			player.mine_entity(entity, true) -- forced mining
		end
		return
	end

	-- Show warning text
	__render_target_forces[1] = entity.force
	__render_text_param.surface = entity.surface
	local ent_pos = entity.position
	__render_text_position[1] = ent_pos.x
	__render_text_position[2] = ent_pos.y
	draw_text(__render_text_param)

	entity.destroy(DESTROY_PARAM)
end
M.remove_entity = remove_entity


M.check_entities = function()
	---@type LuaSurface.count_entities_filtered_param
	local filter_param = {force = 0, type = ""}
	for force_index, entities_by_types in pairs(__force_entities_by_types) do
		filter_param.force = force_index
		for type_name in pairs(entities_by_types) do
			filter_param.type = type_name
			entities_by_types[type_name] = Entity_util.count_entities(filter_param)
		end
	end

	filter_param.type = nil
	for force_index, entities_by_types in pairs(__force_entities_by_names) do
		filter_param.force = force_index
		for type_name in pairs(entities_by_types) do
			filter_param.name = type_name
			entities_by_types[type_name] = Entity_util.count_entities(filter_param)
		end
	end
end


---@param force_index uint
M.init_force = function(force_index)
	if __forces_blacklist[force_index] then return end

	__force_limit_by_types[force_index] = __force_limit_by_types[force_index] or {}
	__force_limit_by_names[force_index] = __force_limit_by_names[force_index] or {}
	__force_entities_by_types[force_index] = __force_entities_by_types[force_index] or {}
	__force_entities_by_names[force_index] = __force_entities_by_names[force_index] or {}

	local force_data = __force_limit_by_types[force_index]
	for type_name, max_count in pairs(__mod_data.default_force_limit_by_types) do
		force_data[type_name] = max_count
	end
	force_data = __force_limit_by_names[force_index]
	for type_name, max_count in pairs(__mod_data.default_force_limit_by_names) do
		force_data[type_name] = max_count
	end

	local force_data = __force_entities_by_types[force_index]
	for _, type_name in ipairs(ENTITY_TYPES) do
		force_data[type_name] = force_data[type_name] or 0
	end
end


---@param event on_entity_died | script_raised_destroy | on_robot_mined_entity | on_player_mined_entity
M.on_entity_died = function(event)
	local entity = event.entity
	if not entity.valid then return end
	local force_index = entity.force.index
	if __forces_blacklist[force_index] then return end

	local _type = entity.type
	local force_data = __force_entities_by_types[force_index]
	local count_by_types = force_data[_type]
	if count_by_types then
		force_data[_type] = count_by_types - 1
	end
	-- game.print("- count_by_types: " .. (force_data[_type] or "nil"))

	local name = entity.name
	force_data = __force_entities_by_names[force_index]
	local count_by_names = force_data[name]
	if count_by_names then
		force_data[name] = count_by_names - 1
	end
	-- game.print("- count_by_names: " .. (force_data[name] or "nil"))
end


---@param event on_robot_built_entity | script_raised_built
M.on_robot_built_entity = function(event)
	local entity = event.entity or event.entity
	if not entity.valid then return end
	if __forces_blacklist[entity.force.index] then return end

	local is_removed = false
	local force_index = entity.force.index
	local _type = entity.type
	local name = entity.name

	local entities_by_types = __force_entities_by_types[force_index]
	local count_by_type = entities_by_types[_type] or 0
	count_by_type = count_by_type + 1
	local limit_force_data = __force_limit_by_types[force_index]
	local limit = limit_force_data[_type]
	if limit then
		if count_by_type > limit then
			count_by_type = count_by_type - 1
			remove_entity(entity, limit, player, is_ghost)
			is_removed = true
		end
	elseif not __forces_global_limit_blacklist[force_index] then
		limit = __global_limitiations_by_types[_type]
		if limit and count_by_type > limit then
			count_by_type = count_by_type - 1
			remove_entity(entity, limit, player, is_ghost)
			is_removed = true
		end
	end

	local entities_by_names = __force_entities_by_names[force_index]
	local count_by_name = entities_by_names[name] or 0
	count_by_name = count_by_name + 1
	if not is_removed then
		local limit_force_data = __force_limit_by_names[force_index]
		local limit = limit_force_data[_type]
		if limit then
			if count_by_name > limit then
				count_by_name = count_by_name - 1
				remove_entity(entity, limit, player, is_ghost)
				is_removed = true
			end
		elseif not __forces_global_limit_blacklist[force_index] then
			limit = __global_limitiations_by_names[_type]
			if limit and count_by_name > limit then
				count_by_name = count_by_name - 1
				remove_entity(entity, limit, player, is_ghost)
				is_removed = true
			end
		end
	end

	-- game.print("+ count_by_type: " .. count_by_type)
	-- game.print("+ count_by_name: " .. count_by_name)
	entities_by_types[_type] = count_by_type
	entities_by_names[name]  = count_by_name
end


---@param cmd CustomCommandData
M.check_limited_buildings_command = function(cmd)
	if cmd.player_index == 0 then -- command from server/rcon
		M.check_entities()
		print("Checked enttities in \"limited buildings\" mod")
		return
	end

	local player = game.get_player(cmd.player_index)
	if not (player and player.valid) then return end
	if not player.admin then
		player.print({"command-output.parameters-require-admin"})
		return
	end

	M.check_entities()
end


---@param event on_built_entity
M.on_built_entity = function(event)
	local entity = event.entity
	if not entity.valid then return end
	local force_index = entity.force.index
	if __forces_blacklist[force_index] then return end

	local is_removed = false
	local _type
	local is_ghost = false --- (entity.type == "entity-ghost")
	if is_ghost then
		_type = entity.ghost_type
	else
		_type = entity.type
	end
	local name
	if is_ghost then
		name = entity.ghost_name
	else
		name = entity.name
	end

	local entities_by_types = __force_entities_by_types[force_index]
	local count_by_type = entities_by_types[_type] or 0
	count_by_type = count_by_type + 1
	local limit_force_data = __force_limit_by_types[force_index]
	local limit = limit_force_data[_type]
	if limit then
		if count_by_type > limit then
			count_by_type = count_by_type - 1
			local player = game.get_player(event.player_index)
			remove_entity(entity, limit, player, is_ghost)
			is_removed = true
		end
	elseif not __forces_global_limit_blacklist[force_index] then
		limit = __global_limitiations_by_types[_type]
		if limit and count_by_type > limit then
			count_by_type = count_by_type - 1
			local player = game.get_player(event.player_index)
			remove_entity(entity, limit, player, is_ghost)
			is_removed = true
		end
	end

	local entities_by_names = __force_entities_by_names[force_index]
	local count_by_name = entities_by_names[name] or 0
	count_by_name = count_by_name + 1
	if not is_removed then
		local limit_force_data = __force_limit_by_names[force_index]
		local limit = limit_force_data[_type]
		if limit then
			if count_by_name > limit then
				count_by_name = count_by_name - 1
				local player = game.get_player(event.player_index)
				remove_entity(entity, limit, player, is_ghost)
				is_removed = true
			end
		elseif not __forces_global_limit_blacklist[force_index] then
			limit = __global_limitiations_by_names[_type]
			if limit and count_by_name > limit then
				count_by_name = count_by_name - 1
				local player = game.get_player(event.player_index)
				remove_entity(entity, limit, player, is_ghost)
				is_removed = true
			end
		end
	end

	if is_ghost then return end

	-- game.print("+ count_by_type: " .. count_by_type)
	-- game.print("+ count_by_name: " .. count_by_name)
	entities_by_types[_type] = count_by_type
	entities_by_names[name]  = count_by_name
end


---@param event script_raised_revive | script_raised_built | on_entity_cloned
M.script_raised_built = function(event)
	local entity = event.entity or event.destination
	if not entity.valid then return end
	if __forces_blacklist[entity.force.index] then return end

	local _type = entity.type
	local count_by_types = __force_entities_by_types[_type]
	if count_by_types then
		__force_entities_by_types[_type] = count_by_types + 1
	end

	local name = entity.name
	local count_by_names = __force_entities_by_names[name]
	if count_by_names then
		__force_entities_by_names[name] = count_by_names + 1
	end
end


---@param event on_force_created
M.on_force_created = function(event)
	local force = event.force
	if not force.valid then return end
	M.init_force(force.index)
end


---@param event on_forces_merging
M.on_forces_merging = function(event)
	local source = event.source
	if not source.valid then return end
	local source_id = source.index
	if __forces_blacklist[source_id] then return end

	local destination = event.destination
	if not destination.valid and not __forces_blacklist[destination.index] then
		local destination_id = destination.index

		-- Merge entitites count
		local source_force_data = __force_entities_by_types[source_id]
		local destination_force_data = __force_entities_by_types[destination_id]
		for k, count in pairs(source_force_data) do
			destination_force_data[k] = (destination_force_data[k] or 0) + count
		end
		source_force_data = __force_entities_by_names[source_id]
		destination_force_data = __force_entities_by_names[destination_id]
		for k, count in pairs(source_force_data) do
			destination_force_data[k] = (destination_force_data[k] or 0) + count
		end
	end

	-- Delete source force data
	__force_limit_by_types[source_id] = nil
	__force_limit_by_names[source_id] = nil
	__force_entities_by_types[source_id] = nil
	__force_entities_by_names[source_id] = nil
end


---@param event on_runtime_mod_setting_changed
M.on_runtime_mod_setting_changed = function(event)
	if event.setting_type ~= "runtime-global" then return end
	local setting_name = event.setting
	local type_name = setting_name:match("^LBZO_(.+)_limit$")
	if not type_name then return end

	local value = settings.global[setting_name].value
	---@cast value uint
	if value < 0 then
		__global_limitiations_by_types[type_name] = nil
	else
		__global_limitiations_by_types[type_name] = value
	end
end

--#region Pre-game stage

M.validate_global_data = function()
	local forces = game.forces
	local entity_prototypes = prototypes.entity

	for force_id in pairs(__forces_blacklist) do
		if forces[force_id] == nil then
			__forces_blacklist[force_id] = nil
			__force_limit_by_types[force_id] = nil
			__force_limit_by_names[force_id] = nil
			__force_entities_by_types[force_id] = nil
			__force_entities_by_names[force_id] = nil
		end
	end

	for entity_name in pairs(__global_limitiations_by_names) do
		if entity_prototypes[entity_name] == nil then
			__global_limitiations_by_names[entity_name] = nil
		end
	end

	for entity_name in pairs(__mod_data.default_force_limit_by_types) do
		if entity_prototypes[entity_name] == nil then
			__mod_data.default_force_limit_by_types[entity_name] = nil
		end
	end

	for entity_name in pairs(__mod_data.default_force_limit_by_names) do
		if entity_prototypes[entity_name] == nil then
			__mod_data.default_force_limit_by_names[entity_name] = nil
		end
	end

	for force_id in pairs(__force_limit_by_types) do
		if forces[force_id] == nil then
			__force_limit_by_types[force_id] = nil
			__force_limit_by_names[force_id] = nil
			__force_entities_by_types[force_id] = nil
			__force_entities_by_names[force_id] = nil
		end
	end

	for force_id in pairs(__force_entities_by_types) do
		if forces[force_id] == nil then
			__force_limit_by_types[force_id] = nil
			__force_limit_by_names[force_id] = nil
			__force_entities_by_types[force_id] = nil
			__force_entities_by_names[force_id] = nil
		end
	end

	for force_id, data in pairs(__force_limit_by_names) do
		if forces[force_id] == nil then
			__force_limit_by_types[force_id] = nil
			__force_limit_by_names[force_id] = nil
			__force_entities_by_types[force_id] = nil
			__force_entities_by_names[force_id] = nil
			goto continue
		end
		for entity_name in pairs(data) do
			if entity_prototypes[entity_name] == nil then
				data[entity_name] = nil
			end
		end
	    ::continue::
	end

	for force_id, data in pairs(__force_entities_by_names) do
		if forces[force_id] == nil then
			__force_limit_by_types[force_id] = nil
			__force_limit_by_names[force_id] = nil
			__force_entities_by_types[force_id] = nil
			__force_entities_by_names[force_id] = nil
			goto continue
		end
		for entity_name in pairs(data) do
			if entity_prototypes[entity_name] == nil then
				data[entity_name] = nil
			end
		end
	    ::continue::
	end

	for _, force in pairs(forces) do
		if force.valid and not __forces_blacklist[force.index] and __force_entities_by_types[force.index] == nil then
			M.init_force(force.index)
		end
	end
end

M.check_settings = function()
	if not script.active_mods["limited_buildings"] then return end

	for _, type_name in ipairs(ENTITY_TYPES) do
		local value = settings.global["LBZO_" .. type_name .. "_limit"].value
		---@cast value uint
		if value == -1 then
			__global_limitiations_by_types[type_name] = nil
		else
			__global_limitiations_by_types[type_name] = value
		end
	end
end

M.link_data = function()
    __mod_data = storage.LBZO
	__global_limitiations_by_names = __mod_data.global_limitiations_by_names
	__global_limitiations_by_types = __mod_data.global_limitiations_by_types
	__force_limit_by_types = __mod_data.force_limit_by_types
	__force_limit_by_names = __mod_data.force_limit_by_names
	__force_entities_by_types = __mod_data.entities_by_types
	__force_entities_by_names = __mod_data.entities_by_names
	__forces_global_limit_blacklist = __mod_data.forces_global_limit_blacklist
	__forces_blacklist = __mod_data.forces_blacklist
end


M.update_global_data = function()
    storage.LBZO = storage.LBZO or {}
    __mod_data = storage.LBZO

	__mod_data.global_limitiations_by_names = __mod_data.global_limitiations_by_names or {}
	__mod_data.global_limitiations_by_types = __mod_data.global_limitiations_by_types or {}
	__mod_data.force_limit_by_types = __mod_data.force_limit_by_types or {}
	__mod_data.force_limit_by_names = __mod_data.force_limit_by_names or {}
	__mod_data.entities_by_types = __mod_data.entities_by_types or {}
	__mod_data.entities_by_names = __mod_data.entities_by_names or {}
	---@type table<string, uint>
	__mod_data.default_force_limit_by_types = __mod_data.default_force_limit_by_types or {}
	---@type table<string, uint>
	__mod_data.default_force_limit_by_names = __mod_data.default_force_limit_by_names or {}
	__mod_data.forces_global_limit_blacklist = __mod_data.forces_global_limit_blacklist or {}
	if __mod_data.forces_blacklist == nil then
		__mod_data.forces_blacklist = {[2] = true, [3] = true}
	end

    M.link_data()

	for _, force_data in pairs(__force_entities_by_types) do
		for _, type_name in ipairs(ENTITY_TYPES) do
			force_data[type_name] = force_data[type_name] or {}
		end
	end

	if game then
		M.validate_global_data()
		M.check_settings()
	end
end


M.handle_events = function()
	local filter_param_for_build = {
		-- { filter = "type", type = "entity-ghost", mode = "or"}
	}
	local filter_param = {}

	for _, type_name in ipairs(ENTITY_TYPES) do
		local param = { filter = "type", type = type_name, mode = "or"}
		filter_param[#filter_param+1] = param
		filter_param_for_build[#filter_param_for_build+1] = param
	end

	script.set_event_filter(defines.events.on_player_mined_entity, filter_param)
	script.set_event_filter(defines.events.on_robot_mined_entity, filter_param)
	script.set_event_filter(defines.events.on_entity_died, filter_param)
	script.set_event_filter(defines.events.script_raised_destroy, filter_param)
	script.set_event_filter(defines.events.on_built_entity, filter_param_for_build)
	script.set_event_filter(defines.events.on_robot_built_entity, filter_param)
	script.set_event_filter(defines.events.script_raised_built, filter_param)
	script.set_event_filter(defines.events.script_raised_revive, filter_param)
	script.set_event_filter(defines.events.on_entity_cloned, filter_param)
end


M.on_init = function()
	M.update_global_data()

	if game then
		M.init_force(game.forces.player.index)
	end

	M.handle_events()
end
M.on_load = function()
	M.link_data()
	M.handle_events()
end


local is_entities_checked = false
---@param event table
M.on_configuration_changed = function(event)
	M.update_global_data()

	if is_entities_checked == false then
		M.check_entities() -- not reliable still
	end

	-- local mod_changes = event.mod_changes["diplomacy"]
	-- if not (mod_changes and mod_changes.old_version) then return end

	-- local version = tonumber(string.gmatch(mod_changes.old_version, "%d+.%d+")())
end

--#endregion


M.events = {
	[defines.events.on_player_mined_entity] = M.on_entity_died,
	[defines.events.on_robot_mined_entity] = M.on_entity_died,
	[defines.events.on_entity_died] = M.on_entity_died,
	[defines.events.script_raised_destroy] = M.on_entity_died,
	[defines.events.on_built_entity] = M.on_built_entity,
	[defines.events.on_robot_built_entity] = M.on_robot_built_entity,
	[defines.events.script_raised_built] = M.script_raised_built,
	[defines.events.script_raised_revive] = M.script_raised_built,
	[defines.events.on_entity_cloned] = M.script_raised_built,
	[defines.events.on_force_created] = M.on_force_created,
	[defines.events.on_forces_merging] = M.on_forces_merging,
	[defines.events.on_runtime_mod_setting_changed] = M.on_runtime_mod_setting_changed,
}


commands.add_command("check_limited_buildings", {"limited_buildings-commands.check_limited_buildings"}, M.check_limited_buildings_command)


return M
