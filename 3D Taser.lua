--local variables for API. Automatically generated by https://github.com/simpleavaster/gslua/blob/master/authors/sapphyrus/generate_api.lua 
local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_gradient, client_set_event_callback, client_screen_size, client_eye_position, client_color_log = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_gradient, client.set_event_callback, client.screen_size, client.eye_position, client.color_log 
local client_draw_circle, client_draw_text, client_visible, client_exec, client_delay_call, client_trace_line, client_world_to_screen, client_draw_hitboxes = client.draw_circle, client.draw_text, client.visible, client.exec, client.delay_call, client.trace_line, client.world_to_screen, client.draw_hitboxes 
local client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_get_player_name, entity_get_all, entity_set_prop, entity_get_player_weapon, entity_hitbox_position, entity_get_prop, entity_get_players, entity_get_classname = entity.get_local_player, entity.is_enemy, entity.get_player_name, entity.get_all, entity.set_prop, entity.get_player_weapon, entity.hitbox_position, entity.get_prop, entity.get_players, entity.get_classname 
local globals_mapname, globals_tickcount, globals_realtime, globals_absoluteframetime, globals_tickinterval, globals_curtime, globals_frametime, globals_maxplayers = globals.mapname, globals.tickcount, globals.realtime, globals.absoluteframetime, globals.tickinterval, globals.curtime, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
local math_ceil, math_tan, math_correctRadians, math_fact, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt, math_deg, math_atan = math.ceil, math.tan, math.correctRadians, math.fact, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt, math.deg, math.atan 
local math_fmod, math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.fmod, math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad 
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert 
local string_find, string_format, string_rep, string_gsub, string_len, string_gmatch, string_dump, string_match, string_reverse, string_byte, string_char, string_upper, string_lower, string_sub = string.find, string.format, string.rep, string.gsub, string.len, string.gmatch, string.dump, string.match, string.reverse, string.byte, string.char, string.upper, string.lower, string.sub 
--end of local variables 

local function draw_circle_3d(ctx, x, y, z, radius, r, g, b, a, accuracy)
	local accuracy = accuracy or 3
	local screen_x_line_old, screen_y_line_old
	for rot=0, 360,accuracy do
		local rot_temp = math_rad(rot)
		local lineX, lineY, lineZ = radius * math_cos(rot_temp) + x, radius * math_sin(rot_temp) + y, z
		local screen_x_line, screen_y_line = client.world_to_screen(ctx, lineX, lineY, lineZ)
		if screen_x_line ~=nil and screen_x_line_old ~= nil then
			client_draw_line(ctx, screen_x_line, screen_y_line, screen_x_line_old, screen_y_line_old, r, g, b, a)
		end
		screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
	end
end

local function hsv_to_rgb(h, s, v, a)
  local r, g, b

  local i = math_floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255, a * 255
end

local enabled_reference = ui.new_checkbox("VISUALS", "Other ESP", "Visualize Taser range")

local had_taser = false
local weapon_name_prev = nil
local last_switch = 0
local accuracy = 2.5

local function on_paint(ctx)
	if not ui_get(enabled_reference) then
		return
	end

	local local_player = entity_get_local_player()
	local curtime = globals_curtime()

	local weapon = entity_get_player_weapon(local_player)
	local weapon_name = entity_get_classname(weapon)

	if weapon_name ~= weapon_name_prev then
		if weapon_name ~= "CWeaponTaser" and weapon_name_prev == "CWeaponTaser" then
			had_taser = true
		else
			had_taser = false
		end
		last_switch = curtime
	end

	local ranges
	local ranges_opacities
	if weapon_name == "CWeaponTaser" or had_taser then
		ranges = {183-16}
		ranges_opacities = {1}
	--elseif weapon_name == "CKnife" then
	--	ranges = {32, 48}
	--	ranges_opacities = {1, 0.2}
	end

	if ranges == nil then
		return
	end

	local local_x, local_y, local_z = entity_get_prop(local_player, "m_vecOrigin")
	local vo_z = entity_get_prop(local_player, "m_vecViewOffset[2]")-4

	local fade_multiplier
	if curtime - last_switch < 0.3 then
		fade_multiplier = (curtime - last_switch) * 1/0.3
	else
		fade_multiplier = 1
	end

	if weapon_name ~= "CWeaponTaser" and had_taser then
		fade_multiplier = 1 - fade_multiplier
	end

	for i=1, #ranges do
		local range = ranges[i]
		local opacity_multiplier = ranges_opacities[i] * fade_multiplier

		local previous_world_x, previous_world_y

		for rot=0, 360, accuracy do
			local rot_temp = math_rad(rot)
			local temp_x, temp_y, temp_z = local_x + range * math_cos(rot_temp), local_y + range * math_sin(rot_temp), local_z
			local fraction = client_trace_line(local_player, local_x, local_y, local_z+vo_z, temp_x, temp_y, local_z+vo_z)

			local fraction_x, fraction_y = local_x+(temp_x-local_x)*fraction, local_y+(temp_y-local_y)*fraction
			local world_x, world_y = client_world_to_screen(ctx, fraction_x, fraction_y, temp_z+vo_z)

			local hue_extra = globals_realtime() % 8 / 8
			local r, g, b = hsv_to_rgb(rot/360+hue_extra, 1, 1, 255)

			local fraction_multiplier = 1
			if fraction > 0.9 then
				fraction_multiplier = 0.6
			end

			if world_x ~= nil and previous_world_x ~= nil then
				client_draw_line(ctx, world_x, world_y, previous_world_x, previous_world_y, r, g, b, 255*opacity_multiplier*fraction_multiplier)
			end
			previous_world_x, previous_world_y = world_x, world_y
		end
	end

	weapon_name_prev = weapon_name
end

client.set_event_callback("paint", on_paint)