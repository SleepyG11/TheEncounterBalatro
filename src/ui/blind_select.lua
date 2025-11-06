-- Blind select
function TheEncounter.UI.event_choice_render(index, total, scenario, domain, start_from_bottom)
	domain = assert(TheEncounter.Domain.resolve(domain), "Cannot render choice without Domain")
	scenario = TheEncounter.Scenario.resolve(scenario)

	local disabled = false
	local run_info = false

	local target = scenario or domain

	local domain_colours = TheEncounter.UI.get_colours(domain)
	local scenario_colours = TheEncounter.UI.get_colours(scenario, domain)

	-- Colour
	local blind_col = (scenario and scenario_colours.colour) or domain_colours.colour or G.C.MULT
	local text_col = (scenario and scenario_colours.text_colour) or domain_colours.text_colour or G.C.UI.TEXT_LIGHT

	-- Sprite
	local atlas, pos = TheEncounter.UI.get_atlas(scenario, domain)
	local animation = AnimatedSprite(0, 0, 1.4, 1.4, atlas, pos)
	animation:define_draw_steps({
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
		if res.variant then
			t.key = t.key .. "_" .. res.variant
		end
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
		maxw = 2.7,
	})

	local blind_text = {}
	local raw_blind_text = loc_object.blind_text or loc_object.text
	for _, line in ipairs(raw_blind_text) do
		table.insert(blind_text, {
			n = G.UIT.R,
			config = { align = "cm", minh = 0.1, maxw = 3 },
			nodes = SMODS.localize_box(loc_parse_string(line), {
				colour = text_col,
				default_colour = text_col,
				default_col = text_col,
				vars = t.vars or {},
			}),
		})
	end

	local reward_render = TheEncounter.UI.get_reward(scenario, domain, blind_col, text_col)
	local badges = TheEncounter.UI.get_badges(scenario, domain, {
		bypass_discovery_check = true,
	})

	local colours = TheEncounter.UI.get_colours_palette({
		colour = blind_col,
	})

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
					colour = colours.medium_colour,
					r = 0.1,
					outline = 1,
					outline_colour = colours.light_colour,
					minw = 3.3,
					maxw = 3.3,
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
									func = "enc_can_start_event",
									button = "enc_start_event",
									enc_domain = domain,
									enc_scenario = scenario,
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
									outline_colour = colours.colour,
									colour = colours.light_colour,
									minw = 2.9,
									maxw = 2.9,
									minh = 0.6,
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
													{ n = G.UIT.O, config = { object = animation } },
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
									{
										n = G.UIT.R,
										config = { align = "cm", padding = 0.03 },
										nodes = badges,
									},
								},
							},
						},
					},
				},
			},
		},
	}
	return {
		definition = {
			n = G.UIT.ROOT,
			config = { align = "cm", colour = G.C.CLEAR },
			nodes = {
				UIBox_dyn_container({ t }, false, colours.colour, colours.dark_colour),
			},
		},
		config = { align = "bmi", offset = { x = 0, y = start_from_bottom and 20 or 0 }, xy_bond = "Weak" },
	}
end
function TheEncounter.UI.event_choices_render(choices)
	choices = choices or {}
	local choice_nodes = {}
	local choice_elements = {}
	local total_items = #choices
	for i, choice in ipairs(choices) do
		local element = UIBox(
			TheEncounter.UI.event_choice_render(
				i,
				total_items,
				TheEncounter.Scenarios[choice.scenario_key] or nil,
				TheEncounter.Domains[choice.domain_key]
			)
		)
		table.insert(choice_nodes, {
			n = G.UIT.O,
			config = {
				align = "cm",
				id = "enc_event_choice_" .. i,
				object = element,
			},
		})
		table.insert(choice_elements, element)
	end
	return {
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
			nodes = {
				{
					n = G.UIT.R,
					config = { padding = 0.5 },
					nodes = choice_nodes,
				},
			},
		},
		config = {
			align = "bmi",
			offset = { x = 0, y = G.ROOM.T.y + 29 },
			major = G.hand,
			xy_bond = "Weak",
			enc_choice_elements = choice_elements,
		},
	}
end
function TheEncounter.UI.event_replace_choice(index, choice)
	local choices_el = G.TheEncounter_blind_choices
	if not choices_el then
		return
	end

	local choice_el = choices_el.config.enc_choice_elements[index]
	if not choice_el and choice then
		local new_object = UIBox(
			TheEncounter.UI.event_choice_render(
				index,
				#choices_el.config.enc_choice_elements + 1,
				choice.scenario_key,
				choice.domain_key,
				true
			)
		)
		new_object.states.visible = false
		local new_container = {
			n = G.UIT.O,
			config = {
				align = "cm",
				id = "enc_event_choice_" .. index,
				object = new_object,
			},
		}
		choices_el.UIRoot.children[1].UIBox:add_child(new_container, choices_el.UIRoot.children[1])
		choices_el:recalculate()
		choices_el.config.enc_choice_elements[index] = new_object
		new_object:set_role({ xy_bond = "Weak" })
		new_object.alignment.offset.y = 0
		new_object.states.visible = true
	else
		table.remove(choices_el.config.enc_choice_elements, index)
		choice_el:set_role({ xy_bond = "Weak" })
		choice_el.alignment.offset.y = 20
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.5,
			func = function()
				if choice then
					local new_object = UIBox(
						TheEncounter.UI.event_choice_render(
							index,
							#choices_el.config.enc_choice_elements + 1,
							choice.scenario_key,
							choice.domain_key,
							true
						)
					)
					new_object.parent = choice_el.parent
					new_object.states.visible = false
					TheEncounter.UI.set_element_object(choice_el.parent, new_object)
					choice_el:remove()
					choices_el.config.enc_choice_elements[index] = new_object
					new_object.states.visible = true
					new_object:set_role({ xy_bond = "Weak" })
					new_object.alignment.offset.y = 0
				else
					choices_el.UIRoot.children[1].children[index]:remove()
					table.remove(choices_el.UIRoot.children[1].children, index)
					choices_el:recalculate()
				end
				return true
			end,
		}))
	end
end
function TheEncounter.UI.event_replace_all_choices(with_prompt)
	TheEncounter.UI.remove_event_choices()
	if with_prompt then
		TheEncounter.UI.remove_prompt_box()
	end
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.3,
		func = function()
			G.TheEncounter_blind_choices = UIBox(TheEncounter.UI.event_choices_render(G.GAME.TheEncounter_choices))
			if with_prompt then
				G.TheEncounter_prompt_box = UIBox(TheEncounter.UI.prompt_box_render())
			end
			TheEncounter.UI.set_event_choices()
			if with_prompt then
				TheEncounter.UI.set_prompt_box()
			end
			return true
		end,
	}))
end

function TheEncounter.UI.set_event_choices()
	if G.TheEncounter_blind_choices then
		G.TheEncounter_blind_choices.alignment.offset.y = 0
			- (G.hand.T.y - G.jokers.T.y)
			+ G.TheEncounter_blind_choices.T.h
		G.ROOM.jiggle = G.ROOM.jiggle + 3
		G.TheEncounter_blind_choices.alignment.offset.x = 0
	end
end
function TheEncounter.UI.remove_event_choices()
	if G.TheEncounter_blind_choices then
		G.TheEncounter_blind_choices.alignment.offset.y = 40
		G.TheEncounter_blind_choices.alignment.offset.x = 0
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				G.TheEncounter_blind_choices:remove()
				G.TheEncounter_blind_choices = nil
				return true
			end,
		}))
	end
end

-- Prompt box
function TheEncounter.UI.prompt_box_render()
	local initial_lines = {}
	localize({
		type = "name",
		set = "Other",
		key = "enc_choose_destiny",
		vars = {},
		nodes = initial_lines,
		no_spacing = true,
		pop_in = 0.5,
		fixed_scale = 0.4 / 0.32,
		maxw = 4.5,
		no_silent = true,
	})

	local desc_lines = {}
	for _, line in ipairs(initial_lines) do
		table.insert(desc_lines, {
			n = G.UIT.R,
			config = {
				align = "cm",
				padding = 0.01,
			},
			nodes = line,
		})
	end

	return {
		definition = {
			n = G.UIT.ROOT,
			config = { align = "cm", colour = G.C.CLEAR, padding = 0.2 },
			nodes = {
				{
					n = G.UIT.C,
					config = { align = "cm" },
					nodes = desc_lines,
				},
			},
		},
		config = { align = "cm", offset = { x = 0, y = -15 }, major = G.HUD:get_UIE_by_ID("row_blind"), bond = "Weak" },
	}
end
function TheEncounter.UI.set_prompt_box()
	if G.TheEncounter_prompt_box then
		G.TheEncounter_prompt_box.alignment.offset.y = 0
	end
end
function TheEncounter.UI.remove_prompt_box()
	if G.TheEncounter_prompt_box then
		G.TheEncounter_prompt_box.alignment.offset.y = -10
		G.E_MANAGER:add_event(Event({
			trigger = "before",
			delay = 0.5,
			blocking = false,
			func = function()
				G.TheEncounter_prompt_box:remove()
				return true
			end,
		}))
	end
end

function G.FUNCS.enc_can_start_event(e)
	if not e.config.old_colour then
		e.config.old_colour = e.config.colour
	end
	if
		G.CONTROLLER.locked
		or G.CONTROLLER.locks.frame
		or (G.GAME and (G.GAME.STOP_USE or 0) > 0)
		or G.STATE ~= G.STATES.ENC_EVENT_SELECT
	then
		e.config.button = nil
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
	else
		e.config.button = "enc_start_event"
		e.config.colour = e.config.old_colour
	end
end
function G.FUNCS.enc_start_event(e)
	G.GAME.TheEncounter_choice = TheEncounter.select_choice(
		TheEncounter.Scenario.resolve(e.config.enc_scenario),
		TheEncounter.Domain.resolve(e.config.enc_domain)
	)
	play_sound("timpani", 0.8)
	play_sound("generic1")

	TheEncounter.UI.remove_event_choices()
	TheEncounter.UI.remove_prompt_box()

	stop_use()
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			G.RESET_JIGGLES = nil
			G.E_MANAGER:add_event(Event({
				trigger = "immediate",
				func = function()
					G.E_MANAGER:add_event(Event({
						trigger = "immediate",
						func = function()
							G.STATE = G.STATES.ENC_EVENT
							G.STATE_COMPLETE = false
							return true
						end,
					}))
					return true
				end,
			}))
			return true
		end,
	}))
end
