local function create_UIBox_choice(index, total, domain, scenario)
	local disabled = false
	local run_info = false

	local target = scenario or domain

	-- Colour
	local blind_col = (scenario and scenario.colour) or domain.colour or G.C.MULT
	local text_col = (scenario and scenario.text_colour) or domain.text_colour or G.C.UI.TEXT_LIGHT

	-- Sprite
	local blind_choice = {
		config = G.P_BLINDS[G.GAME.round_resets.blind_choices["Big"]],
	}
	local atlas, pos = (scenario and scenario:get_atlas(domain)) or domain:get_atlas()
	blind_choice.animation = AnimatedSprite(0, 0, 1.4, 1.4, atlas, pos)
	blind_choice.animation:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
	})

	-- Text
	local set = target.set
	local key = target.key

	local t = { key = key, set = set }
	local res = {}
	if target.loc_vars and type(target.loc_vars) == "function" then
		res = target:loc_vars({}, target == scenario and domain or nil) or {}
		t.vars = res.vars or {}
		t.key = res.key or t.key
		t.set = res.set or t.set
	end

	local loc_object = G.localization.descriptions[t.set][t.key]

	local blind_name = {}
	blind_name = localize({
		type = "name",
		set = t.set,
		key = t.key,
		nodes = blind_name,
		vars = t.vars or {},
		no_spacing = true,
		fixed_scale = 0.45 / 0.55,
	})

	local blind_text = {}
	local raw_blind_text = loc_object.blind_text or loc_object.text
	for _, line in ipairs(raw_blind_text) do
		table.insert(blind_text, {
			n = G.UIT.R,
			config = { align = "cm", minh = 0.1 },
			nodes = SMODS.localize_box(loc_parse_string(line), {
				colour = text_col,
				default_colour = text_col,
				default_col = text_col,
				vars = t.vars or {},
			}),
		})
	end

	-- Reward
	local loc_reward
	local target_meta = {}
	local target_reward
	if scenario then
		target_meta = {}
		target_reward = scenario.reward
		if type(target_reward) == "function" then
			target_meta.is_from_function = true
			target_reward = target_reward(scenario, domain)
		end
	end
	if not target_reward then
		target_meta = {}
		target_reward = domain.reward
		if type(target_reward) == "function" then
			target_meta.is_from_function = true
			target_reward = target_reward(domain)
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
				colour = mix_colours(G.C.BLACK, blind_col, 0.75),
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
								colour = disabled and G.C.UI.TEXT_INACTIVE or text_col,
								shadow = not disabled,
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
									float = true,
									spacing = target_meta.spacing or 1.5,
									scale = target_meta.scale or 0.35,
									font = target_meta.font,
									maxw = 2.5,
								}),
							},
						},
					},
				},
			},
		}
	end

	-- Render
	local t = {
		n = G.UIT.R,
		config = {
			align = "tm",
			minh = not run_info and 10 or nil,
			r = 0.1,
			padding = 0.05,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					colour = mix_colours(G.C.BLACK, blind_col, 0.55),
					r = 0.1,
					outline = 1,
					outline_colour = mix_colours(G.C.BLACK, blind_col, 0.25),
					minw = 3.3,
				},
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.2 },
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									colour = disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE,
									minh = 0.6,
									minw = 2.7,
									padding = 0.07,
									r = 0.1,
									shadow = true,
									hover = true,
									one_press = true,
									button = "enc_noop",
								},
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = localize("Select", "blind_states"),
											scale = 0.45,
											colour = G.C.UI.TEXT_LIGHT,
											shadow = not disabled,
										},
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { id = "blind_name", align = "cm", padding = 0.07 },
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "cm",
									r = 0.1,
									outline = 1,
									outline_colour = blind_col,
									colour = darken(blind_col, 0.3),
									minw = 2.9,
									emboss = 0.1,
									padding = 0.07,
									line_emboss = 1,
								},
								nodes = {
									{
										n = G.UIT.C,
										config = { align = "cm" },
										nodes = blind_name,
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.05 },
						nodes = {
							{
								n = G.UIT.R,
								config = { id = "blind_desc", align = "cm", padding = 0.05 },
								nodes = {
									{
										n = G.UIT.R,
										config = { align = "cm" },
										nodes = {
											{
												n = G.UIT.R,
												config = { align = "cm", minh = 1.5 },
												nodes = {
													{ n = G.UIT.O, config = { object = blind_choice.animation } },
												},
											},
											{
												n = G.UIT.R,
												config = {
													align = "cm",
													minh = 0.7,
													padding = 0.05,
													minw = 2.9,
													maxw = 2.9,
												},
												nodes = blind_text,
											},
										},
									},
									{
										n = G.UIT.R,
										config = {
											align = "cm",
										},
										nodes = {
											reward_render,
										},
									},
								},
							},
						},
					},
				},
			},
		},
	}
	return t
end

local function get_blind_choice(index, total, domain, scenario)
	local blind_col = (scenario and scenario.colour) or domain.colour or G.C.MULT
	return {
		n = G.UIT.O,
		config = {
			align = "cm",
			object = UIBox({
				definition = {
					n = G.UIT.ROOT,
					config = { align = "cm", colour = G.C.CLEAR },
					nodes = {
						UIBox_dyn_container(
							{ create_UIBox_choice(index, total, domain, scenario) },
							false,
							blind_col,
							mix_colours(G.C.BLACK, blind_col, 0.8)
						),
					},
				},
				config = { align = "bmi", offset = { x = 0, y = 0 } },
			}),
		},
	}
end

function TheEncounter.UI.blind_choices(choices)
	local choice_nodes = {}
	local total_items = #choices
	for i, choice in ipairs(choices) do
		table.insert(
			choice_nodes,
			get_blind_choice(
				i,
				total_items,
				TheEncounter.Domains[choice.domain_key],
				TheEncounter.Scenarios[choice.scenario_key] or nil
			)
		)
	end
	return choice_nodes
end

function G.FUNCS.enc_noop() end
