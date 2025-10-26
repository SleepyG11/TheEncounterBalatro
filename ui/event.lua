local function create_UIBox_event_panel(event)
	local scenario = event.scenario
	local domain = event.domain

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

	if not scenario.hide_image_area then
		main_nodes[#main_nodes + 1] = {
			n = G.UIT.C,
			config = {
				minw = image_area_size,
				maxw = image_area_size,
				minh = image_area_size,
				maxh = image_area_size,
				colour = { 0, 0, 0, 0.1 },
				r = 0.1,
				id = "image_area",
			},
		}
	end
	main_nodes[#main_nodes + 1] = {
		n = G.UIT.C,
		config = {
			minw = 0.1,
			maxw = 0.1,
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
							id = "text_area",
							object = Moveable(),
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
											id = "choices_area",
											object = Moveable(),
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

	return {
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
end
local function create_choice_button(event, choice)
	-- TODO: correct localizing by using loc_vars key set etc
	local loc_txt = G.localization.descriptions.enc_Choice[choice.key].text[1]
	local localized = SMODS.localize_box(loc_parse_string(loc_txt), {
		default_col = event.ui.text_colour,
		vars = choice.loc_vars and type(choice.loc_vars) == "function" or choice:loc_vars(event) or {},
	})
	return {
		n = G.UIT.R,
		config = {
			align = "cm",
			padding = 0.08,
			r = 0.75,
			hover = true,
			colour = choice.colour or G.C.GREY,
			shadow = true,
			func = "enc_can_execute_choice",
			button = "enc_execute_choice",
			enc_event = event,
			enc_choice = choice,
			minh = 0.5,
			maxh = 0.5,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = { minw = 0.05 },
			},
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = localized,
			},
			{
				n = G.UIT.C,
				config = { minw = 0.05 },
			},
		},
	}
end

TheEncounter.UI.event_panel = function(event)
	local event_ui = UIBox({
		definition = create_UIBox_event_panel(event),
		config = {
			align = "br",
			major = G.ROOM_ATTACH,
			bond = "Weak",
			offset = {
				x = -15.3,
				y = G.ROOM.T.y + 21,
			},
		},
	})

	event.ui.panel = event_ui
	event.ui.image = event_ui:get_UIE_by_ID("image_area")
	event.ui.text = event_ui:get_UIE_by_ID("text_area")
	event.ui.choices = event_ui:get_UIE_by_ID("choices_area")

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

	local text_objects = {}
	-- Step text
	local event_text_content = {}
	localize({
		type = "descriptions",
		set = step.set,
		key = step.key,
		nodes = event_text_content,
		vars = step:loc_vars(event) or {},
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
					delay = no_delay and 0 or 0.75,
					func = function()
						play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
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
					play_sound("paper1", math.random() * 0.2 + 0.9, 0.75)
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
			local choice = TheEncounter.Choice.resolve(choices[k])
			if choice then
				table.insert(buttons_in_column, create_choice_button(event, choice))
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

function G.FUNCS.enc_can_execute_choice(e)
	if not e.config.old_colour then
		e.config.old_colour = e.config.colour
	end
	local choice = e.config.enc_choice
	local event = e.config.enc_event
	if
		(G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0))
		or event.STATE ~= event.STATES.STEP_IDLE
		or (choice.func and not choice:func(event))
	then
		e.config.button = nil
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
	else
		e.config.button = "enc_execute_choice"
		e.config.colour = e.config.old_colour
	end
end
function G.FUNCS.enc_execute_choice(e)
	local choice = e.config.enc_choice
	local event = e.config.enc_event

	choice:button(event)
end
