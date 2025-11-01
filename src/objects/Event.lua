TheEncounter.Event = Object:extend()
function TheEncounter.Event:init(scenario, domain, save_table)
	self.domain = TheEncounter.Domain.resolve(domain)
	self.scenario = TheEncounter.Scenario.resolve(scenario)

	self.previous_step = nil
	self.current_step = nil
	self.next_step = TheEncounter.Step.resolve(self.scenario.starting_step_key)

	self.ability = TheEncounter.table.merge({
		hide_hand = true,
		hide_deck = false,
		hide_text = false,
		hide_image = false,
		hide_choices = false,
		can_use = true,
		can_sell = true,
		extra = {},
	}, self.domain.config, self.scenario.config)
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

	self:init_ui()
end

function TheEncounter.Event:set_colours(first_load)
	local step_to_check = (first_load and not self.temp_save_table and self.next_step) or self.current_step
	local new_colour = copy_table(
		step_to_check and step_to_check.colour or self.ui.colour or self.scenario.colour or self.domain.colour
	)
	if first_load or not self.ui.colour then
		self.ui.colour = new_colour
		self.ui.inactive_colour = mix_colours(G.C.BLACK, new_colour, 0.8)
		self.ui.dark_colour = mix_colours(G.C.BLACK, new_colour, 0.6)
		self.ui.light_colour = mix_colours(G.C.BLACK, new_colour, 0.4)
	else
		ease_colour(self.ui.colour, new_colour, 0.2)
		ease_colour(self.ui.inactive_colour, mix_colours(G.C.BLACK, new_colour, 0.8), 0.2)
		ease_colour(self.ui.dark_colour, mix_colours(G.C.BLACK, new_colour, 0.6), 0.2)
		ease_colour(self.ui.light_colour, mix_colours(G.C.BLACK, new_colour, 0.4), 0.2)
	end

	local new_text_colour = copy_table(
		step_to_check and step_to_check.text_colour
			or self.ui.text_colour
			or self.scenario.text_colour
			or self.domain.text_colour
	)
	if first_load or not self.ui.text_colour then
		self.ui.text_colour = new_text_colour
	else
		ease_colour(self.ui.text_colour, new_text_colour, 0.2)
	end

	local new_background_colour = copy_table(
		step_to_check and step_to_check.background_colour
			or self.ui.background_colour
			or self.scenario.background_colour
			or self.domain.background_colour
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
	self.temp_save_table = nil
	if not save_table then
		SMODS.calculate_context({ enc_scenario_start = true, event = self })
	end
	local after_load = false
	TheEncounter.em.after_callback(function()
		if save_table then
			local data_object = save_table.data or {}
			data_object = self.scenario:load(self, data_object) or data_object
			data_object = self.current_step:load(self, data_object) or data_object
			self.data = data_object
			after_load = true
		else
			self:move_forward()
		end
		self:enter_step(after_load, func)
	end, save_table)
end
function TheEncounter.Event:enter_step(after_load, func)
	self.STATE = self.STATES.STEP_START
	if not after_load then
		self:set_ability()
	end
	SMODS.calculate_context({ enc_step_start = true, event = self })
	TheEncounter.em.after_callback(function()
		self:set_colours()
		TheEncounter.UI.event_text_lines(self)
		self.current_step:start(self, after_load)
		TheEncounter.em.after_callback(function()
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
function TheEncounter.Event:leave_step(func)
	self.STATE = self.STATES.STEP_FINISH
	SMODS.calculate_context({ enc_step_finish = true, event = self })
	TheEncounter.em.after_callback(function()
		self.current_step:finish(self)
		TheEncounter.em.after_callback(function()
			TheEncounter.UI.event_cleanup(self)
			TheEncounter.em.after_callback(func)
		end)
	end)
end
function TheEncounter.Event:finish(func)
	self:leave_step(function()
		self.STATE = self.STATES.SCENARIO_FINISH
		G.FUNCS.draw_from_hand_to_deck()
		TheEncounter.em.after_callback(function()
			self:move_forward()
			SMODS.calculate_context({ enc_scenario_end = true, event = self })
			TheEncounter.em.after_callback(function()
				TheEncounter.UI.event_finish(self)
				self:clear_colours()
				TheEncounter.em.after_callback(function()
					TheEncounter.after_event_finish()
					TheEncounter.em.after_callback(func, true)
					self.STATE = self.STATES.END
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
	self:leave_step(function()
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
	}
	if self.STATE == self.STATES.STEP_START then
		table.insert(containers, {
			c = self.ui.image_container,
			o = self.ui.image,
			v = not self.ability.hide_image,
		})
	end
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

--

local old_draw = CardArea.draw
function CardArea:draw(...)
	if G.STATE == G.STATES.ENC_EVENT then
		local event = G.TheEncounter_event
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
