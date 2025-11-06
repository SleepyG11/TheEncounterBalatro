TheEncounter.UI.get_badges = function(scenario, domain, args, badges)
	domain = TheEncounter.Domain.resolve(domain)
	scenario = TheEncounter.Scenario.resolve(scenario)
	args = args or {}

	badges = badges or {}
	if scenario then
		scenario:set_badges(badges, domain)
	end
	domain:set_badges(badges)
	if not args.no_rarity then
		badges[#badges + 1] =
			create_badge(SMODS.Rarity:get_rarity_badge(domain.rarity), G.C.RARITY[domain.rarity], nil, 1.2)
	end
	if
		not args.no_mod
		or (scenario and (args.bypass_discovery_check or not scenario.discoverable or scenario.discovered))
	then
		SMODS.create_mod_badges(scenario or domain, badges)
		badges.mod_set = nil
	end
	return badges
end

TheEncounter.UI.set_element_object = function(container, object, no_remove)
	if container then
		if not no_remove then
			container.config.object:remove()
		end
		container.config.object = object
		if object then
			object.config.parent = container
		else
			container.config.object = Moveable()
		end
		container.UIBox:recalculate()
	end
end

TheEncounter.UI.get_colours = function(object, ...)
	if not object then
		return {}
	end
	local res = object.get_colours and type(object.get_colours) == "function" and object:get_colours(...) or {}
	return {
		colour = res.colour or object.colour,
		text_colour = res.text_colour or object.text_colour,
		background_colour = res.background_colour or object.background_colour,
		inactive_colour = res.inactive_colour or object.inactive_colour,
	}
end

TheEncounter.UI.get_reward = function(scenario, domain, blind_col, text_col, is_hud)
	domain = TheEncounter.Domain.resolve(domain)
	scenario = TheEncounter.Scenario.resolve(scenario)

	if not domain then
		return nil
	end

	local loc_reward
	local target_meta = {}
	local target_reward
	if scenario then
		target_meta = {}
		target_reward = scenario.reward
		if type(target_reward) == "function" then
			target_meta.is_from_function = true
			target_reward = target_reward(scenario, domain, is_hud)
		end
	end
	if not target_reward then
		target_meta = {}
		target_reward = domain.reward
		if type(target_reward) == "function" then
			target_meta.is_from_function = true
			target_reward = target_reward(domain, is_hud)
		end
	end

	if type(target_reward) == "table" then
		if target_reward.full_ui and target_meta.is_from_function then
			target_meta.is_full_custom_ui = true
			target_reward = target_reward.full_ui
		elseif target_reward.value_ui and target_meta.is_from_function then
			target_meta.is_custom_ui = true
			target_reward = target_reward.value_ui
		elseif target_reward.value then
			target_meta.colour = target_reward.colour
			target_meta.symbol = target_reward.symbol
			target_meta.font = target_reward.font
			target_meta.scale = target_reward.scale
			target_meta.limit = target_reward.limit
			target_meta.spacing = target_reward.spacing
			target_reward = target_reward.value
		else
			target_reward = "???"
		end
	end

	if target_meta.is_full_custom_ui or target_meta.is_custom_ui then
		-- Custom UI
		loc_reward = target_reward
	elseif type(target_reward) == "string" then
		loc_reward = target_reward
		-- No work for us
	elseif type(target_reward) == "number" then
		local symbol = target_meta.symbol or "$"
		local limit = target_meta.limit or 10
		-- Convert number in amount of dollars to display
		if to_big(target_reward) > to_big(limit) then
			loc_reward = target_reward .. symbol
		else
			loc_reward = ""
			for i = 1, target_reward do
				loc_reward = loc_reward .. symbol
			end
		end
	else
		loc_reward = "???"
	end

	local colours = TheEncounter.UI.get_colours_palette({
		colour = blind_col,
	})

	local reward_render
	if target_meta.is_full_custom_ui then
		reward_render = loc_reward
	else
		reward_render = {
			n = G.UIT.R,
			config = {
				align = "cm",
				r = 0.1,
				padding = 0.05,
				minw = 3.1,
				maxw = 3.1,
				colour = colours.dark_colour,
				emboss = 0.05,
			},
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", minh = 0.5, maxw = 3.1 },
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = localize("ph_blind_reward"),
								scale = 0.35,
								colour = text_col,
								shadow = not is_hud,
							},
						},
						target_meta.is_custom_ui and loc_reward or {
							n = G.UIT.O,
							config = {
								object = DynaText({
									string = { loc_reward },
									colours = {
										target_meta.colour or G.C.MONEY,
									},
									bump = is_hud,
									spacing = target_meta.spacing or 1.5,
									scale = target_meta.scale or 0.35,
									font = target_meta.font,
									shadow = true,
									maxw = 2.5,
								}),
							},
						},
					},
				},
			},
		}
	end

	return reward_render
end

TheEncounter.UI.get_colours_palette = function(colours)
	return {
		colour = colours.colour,
		inactive_colour = mix_colours(G.C.BLACK, colours.colour, 0.8),
		dark_colour = mix_colours(G.C.BLACK, colours.colour, 0.7),
		medium_colour = mix_colours(G.C.BLACK, colours.colour, 0.5),
		light_colour = mix_colours(G.C.BLACK, colours.colour, 0.3),
	}
end

TheEncounter.UI.get_atlas = function(scenario, domain)
	domain = TheEncounter.Domain.resolve(domain)
	scenario = TheEncounter.Scenario.resolve(scenario)

	if not domain then
		return nil
	end

	local function resolve_first_atlas(...)
		local list = { ... }
		for _, key in pairs(list) do
			if type(key) == "table" then
				return key
			elseif type(key) == "string" and G.ANIMATION_ATLAS[key] then
				return G.ANIMATION_ATLAS[key]
			end
		end
		return nil
	end

	local scenario_atlas, scenario_pos
	if scenario then
		scenario_atlas, scenario_pos = scenario:get_atlas(domain)
	end
	local domain_atlas, domain_pos = domain:get_atlas()

	local atlas = resolve_first_atlas(scenario_atlas, scenario and scenario.atlas, domain_atlas, domain.atlas)
	local pos = TheEncounter.table.first_not_nil(scenario_pos, scenario and scenario.pos, domain_pos, domain.pos)

	return atlas, pos
end
