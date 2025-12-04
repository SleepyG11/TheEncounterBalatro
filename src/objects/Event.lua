TheEncounter.Event = Object:extend()
function TheEncounter.Event:init(scenario, domain, save_table)
	self.domain = assert(TheEncounter.Domain.resolve(domain), "Cannot start event without Domain")
	self.scenario = assert(TheEncounter.Scenario.resolve(scenario), "Cannot start event without Scenario")

	self.previous_step = nil
	self.current_step = nil
	self.next_step =
		assert(TheEncounter.Step.resolve(self.scenario.starting_step_key), "Cannot start event without starting Step")

	self.ability = TheEncounter.table.merge({
		hide_hand = true,
		hide_deck = false,
		hide_text = false,
		hide_image = false,
		hide_choices = false,
		can_use = true,
		can_sell = true,
		extra = {},
	}, self.domain.config or {}, self.scenario.config or {})
	self.data = {}

	self.ui = {}

	self.STATES = {
		PREPARE = 1,
		SCENARIO_START = 2,
		SCENARIO_FINISH = 3,
		STEP_START = 4,
		STEP_FINISH = 5,
		STEP_IDLE = 6,
		END = 7,
	}
	self.STATE = self.STATES.PREPARE
	self.HIDE_AREAS_STATES = {
		[self.STATES.PREPARE] = true,
		[self.STATES.SCENARIO_START] = true,
		[self.STATES.SCENARIO_FINISH] = true,
		[self.STATES.END] = true,
	}
	self.NO_UPDATE_STATES = {
		[self.STATES.PREPARE] = true,
		[self.STATES.SCENARIO_START] = true,
		[self.STATES.SCENARIO_FINISH] = true,
		[self.STATES.END] = true,
	}
	self.REMOVED = false

	self.replaced_state = G.GAME.TheEncounter_replaced_state
	G.GAME.TheEncounter_replaced_state = nil

	if save_table then
		self.previous_step = TheEncounter.Step.resolve(save_table.previous_step) or self.previous_step
		self.current_step = TheEncounter.Step.resolve(save_table.current_step) or self.current_step
		self.next_step = TheEncounter.Step.resolve(save_table.next_step) or self.next_step

		self.ability = copy_table(save_table.ability or {})

		self.temp_save_table = save_table

		self.replaced_state = save_table.replaced_state or self.replaced_state
	end

	self.remove_callbacks = {}
end

function TheEncounter.Event:set_colours(first_load)
	local step_to_check = self.current_step or self.next_step

	local step_colours = TheEncounter.UI.get_colours(step_to_check, self)
	local scenario_colours = TheEncounter.UI.get_colours(self.scenario, self.domain, self)
	local domain_colours = TheEncounter.UI.get_colours(self.domain, self)

	local new_colour =
		copy_table(step_colours.colour or self.ui.colour or scenario_colours.colour or domain_colours.colour)
	local new_colour_palette = TheEncounter.UI.get_colour_palette(new_colour)
	if first_load or not self.ui.colour then
		self.ui.colour = new_colour_palette.colour
		self.ui.inactive_colour = new_colour_palette.inactive_colour
		self.ui.dark_colour = new_colour_palette.dark_colour
		self.ui.light_colour = new_colour_palette.light_colour
		self.ui.medium_colour = new_colour_palette.medium_colour
	else
		ease_colour(self.ui.colour, new_colour_palette.colour, 0.2)
		ease_colour(self.ui.inactive_colour, new_colour_palette.inactive_colour, 0.2)
		ease_colour(self.ui.dark_colour, new_colour_palette.dark_colour, 0.2)
		ease_colour(self.ui.light_colour, new_colour_palette.light_colour, 0.2)
		ease_colour(self.ui.medium_colour, new_colour_palette.medium_colour, 0.2)
	end

	local new_text_colour = copy_table(
		step_colours.text_colour or self.ui.text_colour or scenario_colours.text_colour or domain_colours.text_colour
	)
	if first_load or not self.ui.text_colour then
		self.ui.text_colour = new_text_colour
	else
		ease_colour(self.ui.text_colour, new_text_colour, 0.2)
	end

	local new_background_colour = copy_table(
		step_colours.background_colour
			or self.ui.background_colour
			or scenario_colours.background_colour
			or domain_colours.background_colour
	)
	if first_load or not self.ui.background_colour then
		self.ui.background_colour = new_background_colour
	else
		for i = 1, 4 do
			self.ui.background_colour[i] = new_background_colour[i]
		end
	end
	ease_background_colour({ new_colour = new_background_colour, contrast = 1 })
	G.GAME.blind:change_colour(new_colour)
end
function TheEncounter.Event:clear_colours()
	G.GAME.blind:change_colour()
end
function TheEncounter.Event:set_ability()
	self.ability = TheEncounter.table.merge(self.ability, self.current_step.config or {})
end
function TheEncounter.Event:init_ui()
	self:set_colours(true)
	TheEncounter.UI.event_panel(self)
end

function TheEncounter.Event:move_forward()
	self.previous_step = self.current_step
	self.current_step = self.next_step
	self.next_step = nil
end

function TheEncounter.Event:start(func)
	self.STATE = self.STATES.SCENARIO_START
	local save_table = self.temp_save_table
	local after_load = not not save_table
	self.temp_save_table = nil

	if save_table then
		local data_object = save_table.data or {}
		data_object = self.scenario:load(self, data_object) or data_object
		data_object = self.current_step:load(self, data_object) or data_object
		self.data = data_object
	end
	self.scenario:setup(self, after_load)
	self:init_ui()

	stop_use()
	if not save_table then
		SMODS.calculate_context({ enc_scenario_start = true, event = self })
	end

	TheEncounter.em.after_callback(function()
		if not save_table then
			self:move_forward()
		end
		self:enter_step(after_load, func, true)
	end, save_table)
end
function TheEncounter.Event:enter_step(after_load, func, after_scenario_start)
	self.STATE = self.STATES.STEP_START
	stop_use()
	if not after_load then
		self:set_ability()
	end
	SMODS.calculate_context({ enc_step_start = true, event = self })
	TheEncounter.em.after_callback(function()
		self.current_step:setup(self, after_load)
		self:set_colours()
		TheEncounter.UI.event_text_lines(self)
		if after_scenario_start then
			self.scenario:start(self, after_load)
		end
		self.current_step:start(self, after_load)
		TheEncounter.em.after_callback(function()
			stop_use()
			if not after_load then
				if TheEncounter.table.first_not_nil(self.current_step.can_save, self.scenario.can_save) then
					G.GAME.TheEncounter_save_table = self:save()
					save_run()
				end
			end
			TheEncounter.UI.event_show_all_text_lines(self)
			TheEncounter.UI.event_choices(self)
			TheEncounter.em.after_callback(function()
				TheEncounter.em.after_callback(func, true)
				self.STATE = self.STATES.STEP_IDLE
			end)
		end)
	end, not after_load)
end
function TheEncounter.Event:leave_step(is_finish, func)
	self.STATE = self.STATES.STEP_FINISH
	stop_use()
	SMODS.calculate_context({ enc_step_finish = true, event = self })
	TheEncounter.em.after_callback(function()
		self.current_step:finish(self)
		TheEncounter.em.after_callback(function()
			TheEncounter.UI.event_cleanup(self, is_finish)
			TheEncounter.em.after_callback(func)
		end)
	end)
end
function TheEncounter.Event:finish(func)
	self:leave_step(true, function()
		self.STATE = self.STATES.SCENARIO_FINISH
		self:move_forward()
		stop_use()
		SMODS.calculate_context({ enc_scenario_finish = true, event = self })
		TheEncounter.em.after_callback(function()
			self.scenario:finish(self)
			TheEncounter.em.after_callback(function()
				G.FUNCS.draw_from_hand_to_deck()
				self:remove_all_images()
				stop_use()
				TheEncounter.em.after_callback(function()
					TheEncounter.UI.event_finish(self)
					self:clear_colours()
					TheEncounter.em.after_callback(function()
						for _, callback in ipairs(self.remove_callbacks) do
							callback()
						end
						TheEncounter.after_event_finish()
						stop_use()
						self.STATE = self.STATES.END
						TheEncounter.em.after_callback(func, true)
					end)
				end)
			end)
		end)
	end)
end

function TheEncounter.Event:save()
	if
		not self.current_step
		or not TheEncounter.table.first_not_nil(self.current_step.can_save, self.scenario.can_save)
	then
		return G.GAME.TheEncounter_save_table or nil
	end

	local data_object = self.current_step:save(self, self.data) or self.data or {}
	data_object = self.scenario:save(self, data_object) or data_object

	local save_table = {
		domain = self.domain.key,
		scenario = self.scenario.key,

		previous_step = self.previous_step and self.previous_step.key or nil,
		current_step = self.current_step and self.current_step.key or nil,
		next_step = self.next_step and self.next_step.key or nil,

		ability = self.ability,

		data = data_object,

		replaced_state = self.replaced_state,
	}
	return save_table
end
function TheEncounter.Event.load(save_table)
	return TheEncounter.Event(save_table.scenario, save_table.domain, save_table)
end

function TheEncounter.Event:show_lines(amount, instant)
	TheEncounter.UI.event_show_lines(self, amount, instant)
end
function TheEncounter.Event:start_step(key)
	self.next_step = TheEncounter.Step.resolve(key)
	assert(self.next_step, "Tried to start unknown TheEncounter.Step: " .. key)
	self:leave_step(false, function()
		self:move_forward()
		self:enter_step(false)
	end)
end
function TheEncounter.Event:finish_scenario(transition_func)
	self:finish(transition_func or function()
		G.STATE = self.replaced_state or G.STATES.BLIND_SELECT
		G.STATE_COMPLETE = false
	end)
end

function TheEncounter.Event:update(dt)
	if self.REMOVED or self.NO_UPDATE_STATES[self.STATE] then
		return
	end
	self.scenario:update(self, dt)
	self.current_step:update(self, dt)

	local containers = {
		{
			c = self.ui.text_container,
			o = self.ui.text,
			v = not self.ability.hide_text,
		},
		{
			c = self.ui.choices_container,
			o = self.ui.choices,
			v = not self.ability.hide_choices,
		},
		{
			c = self.ui.fullw_choices_container,
			o = self.ui.fullw_choices,
			v = not self.ability.hide_choices,
		},
	}
	local needs_recalculate = false
	for index, container in ipairs(containers) do
		container.c.states.visible = container.v
		container.o.states.visible = container.v
		if not container.c.config.enc_original_object then
			container.c.config.enc_original_object = container.c.config.object
		end
		container.c.config.enc_original_object.states.visible = container.v
		if container.o and container.o.config.object then
			container.o.config.object.states.visible = container.v
		end
		if container.c.config.object then
			container.c.config.object.states.visible = container.v
			if container.v and not container.c.config.object.enc_original_object then
				TheEncounter.UI.set_element_object(container.c, container.c.config.enc_original_object)
				needs_recalculate = true
			elseif not container.v and container.c.config.object.enc_original_object then
				TheEncounter.UI.set_element_object(container.c, Moveable(), true)
				needs_recalculate = true
			end
		end
	end
	if self.ui.hud then
		self.ui.hud.states.visible = not self.ability.hide_hud
	end
	if self.STATE == self.STATES.STEP_START or self.STATE == self.STATES.SCENARIO_START then
		if self.ui.image_container then
			self.ui.image_container.states.visible = not self.ability.hide_image
		end
	end
	if needs_recalculate then
		self.ui.panel:recalculate()
	end
end
function TheEncounter.Event:remove()
	if self.REMOVED then
		return
	end
	self.STATE = self.STATES.REMOVED
	self.REMOVED = true
	for key, value in pairs(self.ui) do
		if Node:is(value) then
			if value.config and value.config.enc_original_object then
				value.config.enc_original_object:remove()
			end
			value:remove()
		end
	end
end

function TheEncounter.Event:before_remove_callback(callback)
	if type(callback) == "function" then
		table.insert(self.remove_callbacks, callback)
	end
end

--

function TheEncounter.Event:image_character(args)
	args = args or {}
	local image_area_container = self.ui.image_container
	local image_area = self.ui.image
	if not image_area or not image_area_container then
		return
	end
	local scale = args.scale or 1
	local w = args.card_w or (G.CARD_W * 1.1 * scale)
	local h = args.card_h or (G.CARD_H * 1.1 * scale)
	local x = image_area.VT.x + image_area.VT.w / 2 - w / 2 + (args.dx or 0)
	local y = image_area.VT.y + image_area.VT.h / 2 - h / 2 + (args.dy or 0)
	local character = Card_Character({
		w = w,
		h = h,
		x = x,
		y = y,
		center = args.center,
	})
	character.children.card.VT.scale = args.scale or character.children.card.VT.scale
	character.children.card.T.scale = args.scale or character.children.card.T.scale
	if args.particles then
		character.children.particles.colours = args.particles
	else
		character.children.particles.colours = { G.C.CLEAR }
	end
	local key = args.container_key or "character"
	image_area.children[key] = character
	character:set_alignment({
		major = image_area,
		bond = "Weak",
		type = "cm",
		offset = {
			x = args.dx or 0,
			y = args.dy or 0,
		},
		draw_major = character,
	})
	local old_draw = character.draw
	function character:draw(...)
		local card = self.children.card
		if image_area_container.states.visible then
			card.states.visible = self.states.visible
		else
			card.states.visible = false
		end
		self.children.card = nil
		old_draw(self, ...)
		self.children.card = card
	end
	return character
end
function TheEncounter.Event:image_sprite(args)
	args = args or {}
	local image_area = self.ui.image
	local atlas = args.atlas
	if type(atlas) == "string" then
		atlas = args.animated and G.ANIMATION_ATLAS[atlas] or G.ASSET_ATLAS[atlas]
	end
	if not image_area or not atlas then
		return
	end
	local maxw = image_area.VT.w - 0.2
	local maxh = image_area.VT.h - 0.2
	local temp_scale = math.min(1, maxw / atlas.px, maxh / atlas.py)
	local scale = args.scale or 1

	local w = args.w or atlas.px * temp_scale * scale
	local h = args.h or atlas.py * temp_scale * scale
	local x = image_area.VT.x + image_area.VT.w / 2 - w / 2 + (args.dx or 0)
	local y = image_area.VT.y + image_area.VT.h / 2 - h / 2 + (args.dy or 0)

	local pos = args.pos or {}
	local sprite
	if args.animated then
		sprite = AnimatedSprite(x, y, w, h, atlas, { x = pos.x or 0, y = pos.y or 0 })
	else
		sprite = Sprite(x, y, w, h, atlas, { x = pos.x or 0, y = pos.y or 0 })
	end
	-- TODO: apply dissolve shader properly
	-- if args.animated then
	-- 	sprite:define_draw_steps({ { shader = "dissolve", shadow_height = 0.05 }, { shader = "dissolve" } })
	-- 	sprite.dissolve_colours = { G.C.MULT }
	-- 	sprite.dissolve = 1
	-- 	ease_value(sprite, "dissolve", -1, nil, nil, nil, 0.5)
	-- else
	-- 	sprite:define_draw_steps({ { shader = "dissolve", shadow_height = 0.05 }, { shader = "dissolve" } })
	-- 	sprite.dissolve_colours = { G.C.MULT }
	-- 	sprite.dissolve = 1
	-- 	ease_value(sprite, "dissolve", -1, nil, nil, nil, 0.5)
	-- end

	local key = args.container_key or "sprite"
	image_area.children[key] = sprite
	sprite:set_alignment({
		major = image_area,
		bond = "Weak",
		type = "cm",
		offset = {
			x = args.dx or 0,
			y = args.dy or 0,
		},
	})
	return sprite
end

function TheEncounter.Event:remove_image(container_key)
	local image_area = self.ui.image
	if not image_area or not container_key then
		return
	end
	local child = image_area.children[container_key]
	if not child then
		return
	end
	if child.children and child.children.card and child.children.card.jimbo == child then
		child.children.card:start_dissolve(nil, true)
		image_area.children[container_key] = nil
	elseif Card:is(child) or Sprite:is(child) or AnimatedSprite:is(child) then
		child:start_dissolve(nil, true)
		image_area.children[container_key] = nil
	elseif child.remove then
		child:remove()
		image_area.children[container_key] = nil
	end
end
function TheEncounter.Event:remove_all_images()
	local image_area = self.ui.image
	if not image_area then
		return
	end
	for container_key, _ in pairs(image_area.children) do
		self:remove_image(container_key)
	end
end
function TheEncounter.Event:get_image(container_key)
	local image_area = self.ui.image
	return image_area and image_area.children[container_key] or nil
end

--

local old_draw = CardArea.draw
function CardArea:draw(...)
	local event = G.TheEncounter_event
	if G.STATE == G.STATES.ENC_EVENT or event then
		if not event or event.REMOVED or event.HIDE_AREAS_STATES[event.STATE] then
			if self == G.hand then
				return
			elseif self == G.deck then
				if event and event.ability.hide_deck then
					return
				end
			end
		else
			if self == G.hand then
				if event.ability.hide_hand then
					return
				end
			elseif self == G.deck then
				if event.ability.hide_deck then
					return
				end
			end
		end
	end
	return old_draw(self, ...)
end

local old_can_use = Card.can_use_consumeable
function Card:can_use_consumeable(...)
	if G.TheEncounter_event and not G.TheEncounter_event.ability.can_use then
		return false
	end
	return old_can_use(self, ...)
end

local old_can_sell = Card.can_sell_card
function Card:can_sell_card(...)
	if G.TheEncounter_event and not G.TheEncounter_event.ability.can_sell then
		return false
	end
	return old_can_sell(self, ...)
end
