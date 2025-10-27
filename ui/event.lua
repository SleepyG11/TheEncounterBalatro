function TheEncounter.UI.event_panel_sizes(event)
	local container_H = 5.6
	local container_W = G.hand.T.w + 0.15
	local container_padding = 0.1

	local header_H = 0.6
	local header_W = container_W - container_padding * 2
	local header_padding = 0.1

	local content_H = container_H - container_padding * 2 - header_H
	local content_W = container_W - container_padding * 2
	local content_padding = 0.1

	local image_area_size = (container_H - container_padding * 2 - header_H - content_padding * 2) / 1.25
	local choices_H = 2.4
	local text_H = (image_area_size * 1.25 - content_padding * 2 - choices_H)

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
		text_H = text_H,
	}
end

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
	local text_H = sizes.text_H

	local event_text_name = {}
	localize({
		type = "name",
		set = "enc_Scenario",
		key = scenario.key,
		nodes = event_text_name,
		vars = scenario:loc_vars({}, domain),
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
	local blind_light_col = event.ui.light_colour

	local main_nodes = {}

	local text_container = UIBox({
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
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
					config = {
						padding = 0.1,
					},
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
						{
							n = G.UIT.C,
							config = {
								minw = 0.1,
								maxw = 0.1,
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
					n = G.UIT.O,
					config = {
						id = "choices_area",
						object = Moveable(),
					},
				},
			},
		},
		config = {},
	})
	choices_area_container.enc_original_object = true

	main_nodes[#main_nodes + 1] = {
		n = G.UIT.O,
		config = {
			id = "image_area_container",
			object = image_area_container,
		},
	}
	main_nodes[#main_nodes + 1] = {
		n = G.UIT.C,
		nodes = {
			{
				n = G.UIT.R,
				config = {
					minh = text_H,
					maxh = text_H,
					align = "c",
					padding = 0.1,
				},
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
				config = { minh = 0.1 },
			},
			{
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.C,
						config = {
							minw = 0.23,
							maxw = 0.23,
						},
					},
					{
						n = G.UIT.C,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									align = "c",
									minh = choices_H,
									maxh = choices_H,
								},
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
			UIBox_dyn_container(
				{
					{
						n = G.UIT.R,
						config = {
							padding = 0.05,
						},
						nodes = {
							{
								n = G.UIT.R,
								config = {
									minw = header_W,
									maxw = header_W,
									colour = blind_light_col,
									outline = 1,
									outline_colour = blind_col,
									r = 0.1,
									emboss = 0.05,
									minh = header_H,
									maxh = header_H,
									padding = header_padding,
									align = "cm",
								},
								nodes = {
									{
										n = G.UIT.C,
										config = { align = "cm" },
										nodes = event_name_lines,
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = {
							r = 0.1,
							minh = content_H,
							maxh = content_H,
							minw = content_W,
							maxw = content_W,
							align = "c",
						},
						nodes = main_nodes,
					},
				},
				nil,
				blind_col,
				blind_dark_col,
				--blind_col and mix_colours(G.C.BLACK, blind_col, 0.8) or nil
				nil
			),
		},
	}
	return {
		definition = definition,
		config = {
			align = "br",
			major = G.ROOM_ATTACH,
			bond = "Weak",
			offset = {
				x = -15.3,
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
	local t = { key = choice.key, set = "enc_Choice" }
	local res = {}
	if choice.loc_vars and type(choice.loc_vars) == "function" then
		res = choice:loc_vars({}, event, ability) or {}
		t.vars = res.vars or {}
		t.key = res.key or t.key
		t.set = res.set or t.set
	end

	local button_text = {}
	localize({
		type = "descriptions",
		set = t.set,
		key = t.key,
		nodes = button_text,
		vars = t.vars or {},
		default_col = event.ui.text_colour,
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
			colour = choice.colour or event.ui.light_colour,
			inactive_colour = choice.inactive_colour or event.ui.inactive_colour,
			shadow = true,
			func = "enc_can_execute_choice",
			button = "enc_execute_choice",
			enc_event = event,
			enc_choice = choice,
			enc_choice_ability = ability,
			minh = 0.5,
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

TheEncounter.UI.event_panel = function(event)
	local event_ui = UIBox(TheEncounter.UI.event_panel_render(event))

	event.ui.panel = event_ui
	event.ui.image_container = event_ui:get_UIE_by_ID("image_area_container")
	event.ui.image = event.ui.image_container.config.object:get_UIE_by_ID("image_area")
	event.ui.text_container = event_ui:get_UIE_by_ID("text_area_container")
	event.ui.text = event.ui.text_container.config.object:get_UIE_by_ID("text_area")
	event.ui.choices_container = event_ui:get_UIE_by_ID("choices_area_container")
	event.ui.choices = event.ui.choices_container.config.object:get_UIE_by_ID("choices_area")

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
			play_sound("cardFan2")
			return true
		end,
	}))

	return event
end
TheEncounter.UI.event_text_lines = function(event)
	local step = event.current_step

	local t = { key = step.key, set = "enc_Step" }
	local res = {}
	if step.loc_vars and type(step.loc_vars) == "function" then
		res = step:loc_vars({}, event) or {}
		t.vars = res.vars or {}
		t.key = res.key or t.key
		t.set = res.set or t.set
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
						config = { align = "c", minh = 0.35 },
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
TheEncounter.UI.event_show_lines = function(event, amount, instant)
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
TheEncounter.UI.event_show_all_text_lines = function(event)
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
TheEncounter.UI.event_choices = function(event)
	local step = event.current_step
	-- Step buttons
	local event_buttons_content = {}
	local choices = step:get_choices(event)
	for i = 1, math.ceil(#choices / 4) do
		local buttons_in_column = {}
		local j = i - 1
		for k = j * 4 + 1, i * 4 do
			local choice = choices[k]
			local result_choice, result_ability
			if TheEncounter.Choice:is(choice) then
				result_choice = choice
			elseif type(choice) == "string" then
				result_choice = TheEncounter.Choice.resolve(choice)
			elseif type(choice) == "table" then
				if choice.key or choice.choice_key then
					result_choice = TheEncounter.Choice.resolve(choice.key or choice.choice_key)
					result_ability = choice.ability
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
		table.insert(event_buttons_content, {
			n = G.UIT.C,
			config = {
				padding = 0.075,
			},
			nodes = buttons_in_column,
		})
	end

	event_buttons_content =
		{ {
			n = G.UIT.R,
			config = {
				padding = 0.075,
			},
			nodes = event_buttons_content,
		} }

	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 1,
		func = function()
			play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
			TheEncounter.UI.set_element_object(
				event.ui.choices,
				UIBox({
					definition = {
						n = G.UIT.ROOT,
						config = { colour = G.C.CLEAR },
						nodes = event_buttons_content,
					},
					config = {},
				})
			)
			return true
		end,
	}))
end
TheEncounter.UI.event_cleanup = function(event)
	G.E_MANAGER:add_event(Event({
		func = function()
			TheEncounter.UI.set_element_object(event.ui.text, Moveable())
			return true
		end,
	}))
	delay(0.5)
	G.E_MANAGER:add_event(Event({
		func = function()
			TheEncounter.UI.set_element_object(event.ui.choices, Moveable())
			return true
		end,
	}))
end
TheEncounter.UI.event_finish = function(event)
	G.E_MANAGER:add_event(Event({
		func = function()
			event.ui.panel.alignment.offset.y = G.ROOM.T.y + 21
			return true
		end,
	}))
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 0.75,
		func = function()
			event.ui.panel:remove()
			play_sound("cardFan2")
			return true
		end,
	}))
	delay(0.5)
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

	choice:button(event, e.config.enc_choice_ability)
end
