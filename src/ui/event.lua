function TheEncounter.UI.event_panel_sizes(event)
	local container_H = 5.6
	local container_W = G.hand.T.w + 0.225
	local container_padding = 0.2

	local header_H = 0.6
	local header_W = container_W - container_padding * 2
	local header_padding = 0.1

	local content_H = container_H - container_padding * 2 - header_H
	local content_W = container_W - container_padding * 2
	local content_padding = 0.2

	local image_area_size = (container_H - container_padding * 2 - header_H - content_padding * 2) / 1.25
	local choices_H = 2.4
	local text_H = (image_area_size * 1.25 - content_padding * 2 - choices_H)
	local text_W = content_W - content_padding * 2
	if not event.ability.hide_image then
		text_W = text_W - image_area_size
	end

	return {
		container_H = container_H,
		container_W = container_W,
		container_padding = container_padding,
		header_H = header_H,
		header_W = header_W,
		header_padding = header_padding,
		content_H = content_H,
		content_W = content_W,
		content_padding = content_padding,
		image_area_size = image_area_size,
		choices_H = choices_H,
		choices_W = text_W,
		text_H = text_H,
		text_W = text_W,
	}
end

-- TODO: cleanup this
function TheEncounter.UI.event_panel_render(event)
	local scenario = event.scenario
	local domain = event.domain

	local sizes = TheEncounter.UI.event_panel_sizes(event)

	local container_H = sizes.container_H
	local container_W = sizes.container_W
	local container_padding = sizes.container_padding

	local header_H = sizes.header_H
	local header_W = sizes.header_W
	local header_padding = sizes.header_padding

	local content_H = sizes.content_H
	local content_W = sizes.content_W
	local content_padding = sizes.container_padding

	local image_area_size = sizes.image_area_size
	local choices_H = sizes.choices_H
	local choices_W = sizes.choices_W
	local text_H = sizes.text_H
	local text_W = sizes.text_W

	local event_text_name = {}
	local t = { key = scenario.key, set = "enc_Scenario" }
	local res = {}
	if scenario.loc_vars and type(scenario.loc_vars) == "function" then
		res = scenario:loc_vars({}, domain) or {}
		t.vars = res.vars or {}
		t.key = res.key or t.key
		t.set = res.set or t.set
		if res.variant then
			t.key = t.key .. "_" .. res.variant
		end
	end
	localize({
		type = "name",
		set = t.set,
		key = t.key,
		nodes = event_text_name,
		vars = t.vars or {},
		default_col = event.ui.text_colour,
	})
	local event_name_lines = {}
	for _, line in ipairs(event_text_name) do
		table.insert(event_name_lines, {
			n = G.UIT.R,
			config = { minh = 0.3 },
			nodes = line,
		})
	end

	local blind_col = event.ui.colour
	local blind_dark_col = event.ui.dark_colour
	local blind_medium_col = event.ui.medium_colour
	local blind_light_col = event.ui.light_colour

	local text_container = UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
			nodes = {
				{
					n = G.UIT.R,
					config = {
						minh = text_H,
						maxw = text_W,
						padding = 0.1,
					},
					nodes = {
						{
							n = G.UIT.O,
							config = {
								id = "text_area",
								object = Moveable(),
							},
						},
					},
				},
			},
		},
		config = {},
	})
	text_container.enc_original_object = true

	local image_area_container = UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
			nodes = {
				{
					n = G.UIT.R,
					nodes = {
						{
							n = G.UIT.C,
							nodes = {
								{
									n = G.UIT.O,
									config = {
										id = "image_area",
										object = UIBox(TheEncounter.UI.image_area_render(event)),
									},
								},
							},
						},
					},
				},
			},
		},
		config = {},
	})
	image_area_container.enc_original_object = true

	local choices_area_container = UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
			nodes = {
				{
					n = G.UIT.R,
					config = {},
					nodes = {
						{
							n = G.UIT.O,
							config = {
								id = "choices_area",
								object = Moveable(),
							},
						},
					},
				},
			},
		},
		config = {},
	})
	choices_area_container.enc_original_object = true

	local fullw_choices_area_container = UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
			nodes = {
				{
					n = G.UIT.R,
					config = {},
					nodes = {
						{
							n = G.UIT.O,
							config = {
								id = "fullw_choices_area",
								object = Moveable(),
							},
						},
					},
				},
			},
		},
		config = {},
	})
	fullw_choices_area_container.enc_original_object = true

	local main_nodes = {
		{
			n = G.UIT.R,
			config = { padding = 0.15 },
			nodes = {
				{
					n = G.UIT.C,
					config = {
						minw = choices_W + 0.2,
					},
					nodes = {
						{
							n = G.UIT.R,
							config = {},
							nodes = {
								{
									n = G.UIT.O,
									config = {
										id = "text_area_container",
										object = text_container,
									},
								},
							},
						},
						{
							n = G.UIT.R,
							nodes = {
								{
									n = G.UIT.O,
									config = {
										id = "choices_area_container",
										object = choices_area_container,
									},
								},
							},
						},
					},
				},
				{
					n = G.UIT.C,
					nodes = {
						{
							n = G.UIT.O,
							config = {
								id = "image_area_container",
								object = image_area_container,
							},
						},
					},
				},
			},
		},
		{
			n = G.UIT.R,
			config = { padding = 0.15 },
			nodes = {
				{
					n = G.UIT.O,
					config = {
						id = "fullw_choices_area_container",
						object = fullw_choices_area_container,
					},
				},
			},
		},
	}

	local definition = {
		n = G.UIT.ROOT,
		config = {
			colour = G.C.CLEAR,
			minw = container_W,
			maxw = container_W,
			minh = container_H,
			maxh = container_H,
		},
		nodes = {
			UIBox_dyn_container({
				{
					n = G.UIT.R,
					config = {
						padding = 0.05,
					},
					nodes = {
						{
							n = G.UIT.R,
							config = {
								maxw = content_W,
								minw = content_W,
								colour = blind_medium_col,
								outline = 1,
								outline_colour = blind_light_col,
								r = 0.1,
								minh = 8.3,
							},
							nodes = main_nodes,
						},
					},
				},
			}, nil, blind_col, blind_dark_col, nil),
		},
	}
	return {
		definition = definition,
		config = {
			align = "br",
			major = G.ROOM_ATTACH,
			bond = "Weak",
			offset = {
				x = -15.39,
				y = G.ROOM.T.y + 21,
			},
		},
	}
end
function TheEncounter.UI.image_area_render(event)
	local sizes = TheEncounter.UI.event_panel_sizes(event)
	local image_area_size = sizes.image_area_size

	return {
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
			nodes = {
				{
					n = G.UIT.C,
					config = {
						minw = image_area_size,
						maxw = image_area_size,
						minh = image_area_size,
						maxh = image_area_size,
						colour = { 0, 0, 0, 0.1 },
						r = 0.1,
					},
				},
			},
		},
		config = {},
	}
end
function TheEncounter.UI.choice_button_UIBox(event, choice, ability)
	local choice_colours = TheEncounter.UI.get_colours(choice, event, ability)
	local t = { key = choice.key, set = "enc_Choice" }
	local res = {}
	if choice.loc_vars and type(choice.loc_vars) == "function" then
		res = choice:loc_vars({}, event, ability) or {}
		t.vars = res.vars or {}
		t.key = res.key or t.key
		t.set = res.set or t.set
		if res.variant then
			t.key = t.key .. "_" .. res.variant
		end
	elseif choice.loc_vars and type(choice.loc_vars) == "table" then
		t.vars = choice.loc_vars.vars or {}
		t.key = choice.loc_vars.key or t.key
		t.set = choice.loc_vars.set or t.set
		if choice.loc_vars.variant then
			t.key = t.key .. "_" .. choice.loc_vars.variant
		end
	end

	local button_text = {}
	localize({
		type = "name",
		set = t.set,
		key = t.key,
		vars = t.vars or {},
		nodes = button_text,
		default_col = choice_colours.text_colour or event.ui.text_colour,
		no_spacing = true,
		fixed_scale = 0.32 / 0.55,
		no_bump = true,
		maxw = 3.5,
	})

	local button_lines = {}
	for _, line in ipairs(button_text) do
		table.insert(button_lines, {
			n = G.UIT.R,
			config = {
				align = "cm",
				padding = 0.01,
			},
			nodes = line,
		})
	end

	return {
		n = G.UIT.R,
		config = {
			align = "cm",
			padding = 0.08,
			r = 0.75,
			hover = true,
			colour = choice_colours.colour or event.ui.light_colour,
			inactive_colour = choice_colours.inactive_colour or event.ui.inactive_colour,
			shadow = true,
			func = "enc_event_choice_tooltip",
			button = "enc_execute_choice",
			enc_event = event,
			enc_choice = choice,
			enc_choice_ability = ability,
			minh = 0.5,
			maxw = 4,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = { minw = 0.05 },
			},
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = button_lines,
			},
			{
				n = G.UIT.C,
				config = { minw = 0.05 },
			},
		},
	}
end

--

function TheEncounter.UI.event_panel(event)
	local event_ui = UIBox(TheEncounter.UI.event_panel_render(event))

	event.ui.panel = event_ui
	event.ui.image_container = event_ui:get_UIE_by_ID("image_area_container")
	event.ui.image = event.ui.image_container.config.object:get_UIE_by_ID("image_area")
	event.ui.text_container = event_ui:get_UIE_by_ID("text_area_container")
	event.ui.text = event.ui.text_container.config.object:get_UIE_by_ID("text_area")
	event.ui.choices_container = event_ui:get_UIE_by_ID("choices_area_container")
	event.ui.choices = event.ui.choices_container.config.object:get_UIE_by_ID("choices_area")
	event.ui.fullw_choices_container = event_ui:get_UIE_by_ID("fullw_choices_area_container")
	event.ui.fullw_choices = event.ui.fullw_choices_container.config.object:get_UIE_by_ID("fullw_choices_area")
	event.ui.hud = UIBox(TheEncounter.UI.event_hud_render(event))

	G.E_MANAGER:add_event(Event({
		func = function()
			event_ui.alignment.offset.y = -8.5
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.75,
		func = function()
			event.ui.hud.alignment.offset.y = 0
			play_sound("cardFan2")
			return true
		end,
	}))

	return event
end
function TheEncounter.UI.event_text_lines(event)
	local sizes = TheEncounter.UI.event_panel_sizes(event)
	local step = event.current_step

	local t = { key = step.key, set = "enc_Step" }
	local res = {}
	if step.loc_vars and type(step.loc_vars) == "function" then
		res = step:loc_vars({}, event) or {}
		t.vars = res.vars or {}
		t.key = res.key or t.key
		t.set = res.set or t.set
		if res.variant then
			t.key = t.key .. "_" .. res.variant
		end
	end

	local text_objects = {}
	local event_text_content = {}
	localize({
		type = "descriptions",
		set = t.set,
		key = t.key,
		nodes = event_text_content,
		vars = t.vars or {},
		default_col = event.ui.text_colour,
	})
	local event_text_lines = {}
	for _, line in ipairs(event_text_content) do
		local text_object = UIBox({
			definition = {
				n = G.UIT.ROOT,
				config = {
					colour = G.C.CLEAR,
				},
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "c", minh = 0.35, maxw = sizes.text_W },
						nodes = line,
					},
				},
			},
			config = {},
		})
		if
			#line == 1
			and line[1].n == G.UIT.T
			and line[1].config.text
			and string.match(line[1].config.text, "^%s*$") ~= nil
		then
			text_object.enc_line_silent = true
		end
		text_object.states.visible = false
		table.insert(text_objects, text_object)
		table.insert(event_text_lines, {
			n = G.UIT.R,
			nodes = {
				{
					n = G.UIT.O,
					config = {
						object = text_object,
					},
				},
			},
		})
	end

	TheEncounter.UI.set_element_object(
		event.ui.text,
		UIBox({
			definition = {
				n = G.UIT.ROOT,
				config = { colour = G.C.CLEAR },
				nodes = {
					{
						n = G.UIT.C,
						config = {
							align = "cm",
						},
						nodes = event_text_lines,
					},
				},
			},
			config = {},
		})
	)

	event.ui.text_objects = text_objects
	event.ui.next_text_object = 1
end
function TheEncounter.UI.event_show_lines(event, amount, instant)
	amount = amount or 1
	local text_objects = event.ui.text_objects
	if text_objects and event.ui.next_text_object then
		for i = event.ui.next_text_object, math.min(event.ui.next_text_object + amount - 1, #text_objects) do
			local object = text_objects[i]
			if object then
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = instant and 0 or 0.75,
					func = function()
						if not object.enc_line_silent and not event.ability.hide_text then
							play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
						end
						object.states.visible = true
						return true
					end,
				}))
			end
		end
	end
	event.ui.next_text_object = event.ui.next_text_object + amount
end
function TheEncounter.UI.event_show_all_text_lines(event)
	local text_objects = event.ui.text_objects
	for i = event.ui.next_text_object, #text_objects do
		local object = text_objects[i]
		if object then
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.75,
				func = function()
					if not object.enc_line_silent and not event.ability.hide_text then
						play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
					end
					object.states.visible = true
					return true
				end,
			}))
		end
	end
end
function TheEncounter.UI.event_choices(event)
	local step = event.current_step
	-- Step buttons
	local event_buttons_content = {}
	local choices = step:get_choices(event)
	local column_data = choices.columns or { 4, 4, 4 }
	local current_index = 1
	for i = 1, #column_data do
		local items_in_column = column_data[i]
		local buttons_in_column = {}
		if items_in_column > 0 then
			for k = current_index, current_index + items_in_column - 1 do
				local choice = choices[k]
				if choice then
					local result_choice, result_ability
					if TheEncounter.Choice:is(choice) then
						result_choice = choice
					elseif type(choice) == "string" then
						result_choice = TheEncounter.Choice.resolve(choice)
					elseif type(choice) == "table" then
						if choice.value then
							result_choice = TheEncounter.Choice.resolve(choice.value)
							result_ability = choice.ability
						else
							result_choice = TheEncounter.Choice.from_object(choice)
							result_choice.key = result_choice.full_key
								or (TheEncounter.Choice.class_prefix .. "_" .. step.key .. "_" .. result_choice.key)
						end
					end
					if result_choice then
						table.insert(
							buttons_in_column,
							TheEncounter.UI.choice_button_UIBox(
								event,
								result_choice,
								TheEncounter.table.merge({}, result_choice.config or {}, result_ability or {})
							)
						)
					end
				end
			end
		end
		current_index = current_index + items_in_column
		if #buttons_in_column > 0 then
			table.insert(event_buttons_content, {
				n = G.UIT.C,
				config = {
					padding = 0.075,
				},
				nodes = buttons_in_column,
			})
		end
	end

	event_buttons_content = {
		{
			n = G.UIT.R,
			config = {
				minh = 0.15,
			},
		},
		{
			n = G.UIT.R,
			config = {
				padding = 0.075,
			},
			nodes = event_buttons_content,
		},
	}

	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 1,
		func = function()
			play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
			local object = UIBox({
				definition = {
					n = G.UIT.ROOT,
					config = { colour = G.C.CLEAR },
					nodes = event_buttons_content,
				},
				config = {},
			})
			TheEncounter.UI.set_element_object(
				event.ability.full_width_choices and event.ui.fullw_choices or event.ui.choices,
				object
			)
			object.states.visible = false
			event.ui.panel:recalculate()
			G.E_MANAGER:add_event(Event({
				blocking = false,
				blockable = false,
				no_delete = true,
				func = function()
					object.states.visible = true
					return true
				end,
			}))
			return true
		end,
	}))
end
function TheEncounter.UI.event_cleanup(event, is_finish)
	G.E_MANAGER:add_event(Event({
		func = function()
			TheEncounter.UI.set_element_object(event.ui.text, Moveable())
			return true
		end,
	}))
	if not is_finish then
		delay(0.5)
	end
	G.E_MANAGER:add_event(Event({
		func = function()
			TheEncounter.UI.set_element_object(event.ui.choices, Moveable())
			TheEncounter.UI.set_element_object(event.ui.fullw_choices, Moveable())
			return true
		end,
	}))
end
function TheEncounter.UI.event_finish(event)
	G.E_MANAGER:add_event(Event({
		func = function()
			event.ui.panel.alignment.offset.y = G.ROOM.T.y + 21
			event.ui.hud.alignment.offset.y = -15
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.75,
		func = function()
			event.ui.panel:remove()
			event.ui.hud:remove()
			play_sound("cardFan2")
			return true
		end,
	}))
	delay(0.5)
end

--

function TheEncounter.UI.event_hud_render(event)
	local scenario = event.scenario
	local domain = event.domain
	local reward = TheEncounter.UI.get_reward(scenario, domain, event.ui.colour, event.ui.text_colour, true)

	local atlas, pos = TheEncounter.UI.get_atlas(scenario, domain)
	local animation = AnimatedSprite(0, 0, 1.2, 1.2, atlas, pos)
	animation:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
	})
	animation.states.collide.can = true
	animation.states.drag.can = true

	local old_update = animation.update
	function animation:update(...)
		if self.role.role_type == "Minor" then
			animation:set_role({ role_type = "Major" })
		end
		old_update(self, ...)
		if not self.states.drag.is and self.parent then
			self.T.r = 0.02 * math.sin(2 * G.TIMERS.REAL + self.parent.T.x)
			self.T.y = self.parent.T.y + 0.03 * math.sin(0.666 * G.TIMERS.REAL + self.parent.T.x)
			self.shadow_height = 0.1 - (0.04 + 0.03 * math.sin(0.666 * G.TIMERS.REAL + self.parent.T.x))
			self.T.x = self.parent.T.x + 0.03 * math.sin(0.436 * G.TIMERS.REAL + self.parent.T.x)
		end
		if self.states.hover.is then
			if not self.hovering then
				self.hovering = true
				self.hover_tilt = 2
				animation:juice_up(0.05, 0.02)
				play_sound("chips1", math.random() * 0.1 + 0.55, 0.12)
			end
		else
			self.hovering = false
			self.hover_tilt = 0
		end
	end

	local t = { key = scenario.key, set = "enc_Scenario" }
	local res = {}
	if scenario.loc_vars and type(scenario.loc_vars) == "function" then
		res = scenario:loc_vars({}, domain) or {}
		t.vars = res.vars or {}
		t.key = res.key or t.key
		t.set = res.set or t.set
		if res.variant then
			t.key = t.key .. "_" .. res.variant
		end
	end

	local blind_name = {}
	blind_name = localize({
		type = "name",
		set = t.set,
		key = t.key,
		nodes = blind_name,
		vars = t.vars or {},
		fixed_scale = 0.5 / 0.32,
		maxw = 4.5,
	})

	local loc_object = G.localization.descriptions[t.set][t.key]

	local blind_text = {}
	local raw_blind_text = loc_object.blind_text or loc_object.text
	for _, line in ipairs(raw_blind_text) do
		table.insert(blind_text, {
			n = G.UIT.R,
			config = { align = "cm", minh = 0.1, maxw = 4.5 },
			nodes = SMODS.localize_box(loc_parse_string(line), {
				colour = event.ui.text_colour,
				default_colour = event.ui.text_colour,
				default_col = event.ui.text_colour,
				vars = t.vars or {},
				scale = 0.24 / 0.2,
			}),
		})
	end

	return {
		definition = {
			n = G.UIT.ROOT,
			config = {
				align = "cm",
				minw = 4.5,
				r = 0.1,
				colour = G.C.BLACK,
				emboss = 0.05,
				padding = 0.05,
			},
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", minh = 0.7, r = 0.1, emboss = 0.05, colour = event.ui.colour },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm", minw = 3 },
							nodes = blind_name,
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm", minh = 2.74, r = 0.1, colour = event.ui.medium_colour },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0.05, minh = 0.75 },
							nodes = blind_text,
						},
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0.15 },
							nodes = {
								{ n = G.UIT.O, config = { object = animation, draw_layer = 1 } },
								{
									n = G.UIT.C,
									config = {
										align = "cm",
										r = 0.1,
										padding = 0.05,
										minw = 2.9,
									},
									nodes = {
										{
											n = G.UIT.R,
											config = { align = "cm", minh = 0.45, maxw = 2.8 },
											nodes = {
												reward,
											},
										},
									},
								},
							},
						},
					},
				},
			},
		},
		config = { major = G.HUD:get_UIE_by_ID("row_blind"), align = "cm", offset = { x = 0, y = -15 }, bond = "Weak" },
	}
end

--

function G.FUNCS.enc_can_execute_choice(e)
	if not e.config.old_colour then
		e.config.old_colour = e.config.colour
	end
	local choice = e.config.enc_choice
	local event = e.config.enc_event
	if
		(G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0))
		or G.STATE ~= G.STATES.ENC_EVENT
		or not event
		or not choice
		or event.STATE ~= event.STATES.STEP_IDLE
		or (choice.func and not choice:func(event, e.config.enc_choice_ability))
	then
		e.config.button = nil
		e.config.colour = e.config.inactive_colour
	else
		e.config.button = "enc_execute_choice"
		e.config.colour = e.config.old_colour
	end
end
function G.FUNCS.enc_execute_choice(e)
	local choice = e.config.enc_choice
	local event = e.config.enc_event

	stop_use()
	choice:button(event, e.config.enc_choice_ability)
end

function G.FUNCS.enc_event_choice_tooltip(e)
	if e.enc_event_choice_tooltip then
		return
	end
	local choice = e.config.enc_choice
	local ability = e.config.enc_choice_ability
	local event = e.config.enc_event
	e.config.func = "enc_can_execute_choice"
	e.enc_event_choice_tooltip = true

	local popup_hover = function(self)
		if not self.config.button then
			return Node.hover(self)
		end
		local t = { key = choice.key, set = "enc_Choice" }
		local res = {}
		if choice.loc_vars and type(choice.loc_vars) == "function" then
			res = choice:loc_vars({}, event, ability) or {}
			t.vars = res.vars or {}
			t.key = res.key or t.key
			t.set = res.set or t.set
			if res.variant then
				t.key = t.key .. "_" .. res.variant
			end
		end

		local loc_entry = G.localization.descriptions[t.set][t.key]
		if not (loc_entry and loc_entry.text and #loc_entry.text > 0) then
			Node.hover(self)
			return
		end

		local popup_content = {}
		localize({
			type = "descriptions",
			set = t.set,
			key = t.key,
			nodes = popup_content,
			vars = t.vars or {},
		})
		local desc_lines = {}
		for _, line in ipairs(popup_content) do
			table.insert(desc_lines, {
				n = G.UIT.R,
				config = {
					align = "cm",
					padding = 0.01,
				},
				nodes = line,
			})
		end

		self.config.h_popup_config = { align = "mt", offset = { x = 0, y = -0.1 }, major = e }
		self.config.h_popup = {
			n = G.UIT.ROOT,
			config = { align = "cm", colour = G.C.CLEAR },
			nodes = {
				{
					n = G.UIT.C,
					config = {
						align = "cm",
					},
					nodes = {
						{
							n = G.UIT.R,
							config = {
								padding = 0.05,
								r = 0.12,
								colour = lighten(G.C.JOKER_GREY, 0.5),
								emboss = 0.07,
							},
							nodes = {
								{
									n = G.UIT.R,
									config = {
										align = "cm",
										padding = 0.07,
										r = 0.1,
										colour = adjust_alpha(darken(G.C.BLACK, 0.1), 0.8),
									},
									nodes = {
										desc_from_rows({ desc_lines }),
									},
								},
							},
						},
					},
				},
			},
		}
		Node.hover(self)
	end

	e.hover = popup_hover
end
