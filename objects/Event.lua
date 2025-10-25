TheEncounter.Event = Object:extend()
function TheEncounter.Event:init(scenario, domain, save_table)
	self.domain = TheEncounter.Domain.resolve(domain)
	self.scenario = TheEncounter.Scenario.resolve(scenario)

	self.previous_step = nil
	self.current_step = nil
	self.next_step = TheEncounter.Step.resolve(self.scenario.starting_step_key)

	self.ability = copy_table(self.scenario.config)
	self.data = {}

	self.ui = {}

	if save_table then
		self.previous_step = TheEncounter.Step.resolve(save_table.previous_step) or self.previous_step
		self.current_step = TheEncounter.Step.resolve(save_table.current_step) or self.current_step
		self.next_step = TheEncounter.Step.resolve(save_table.next_step) or self.next_step

		self.ability = copy_table(save_table.ability or {})
	end

	self:init_ui(save_table)
end

function TheEncounter.Event:set_colours(first_load, from_save)
	local step_to_check = (first_load and not from_save and self.next_step) or self.current_step
	local new_colour = copy_table(
		step_to_check and step_to_check.colour or self.ui.colour or self.scenario.colour or self.domain.colour
	)
	if first_load or not self.ui.colour then
		self.ui.colour = new_colour
		self.ui.dark_colour = mix_colours(G.C.BLACK, new_colour, 0.6)
		self.ui.light_colour = mix_colours(G.C.BLACK, new_colour, 0.4)
	else
		ease_colour(self.ui.colour, new_colour, 0.2)
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
end
function TheEncounter.Event:set_ability()
	self.ability = TheEncounter.table.merge(self.ability, self.current_step.config or {})
end
function TheEncounter.Event:init_ui(save_table)
	self:set_colours(true, save_table)
	TheEncounter.UI.event_panel(self)
end

function TheEncounter.Event:move_forward()
	self.previous_step = self.current_step
	self.current_step = self.next_step
	self.next_step = nil
end

function TheEncounter.Event:start(save_table, func)
	if not save_table then
		SMODS.calculate_context({ enc_scenario_start = true, event = self })
	end
	local after_load = false
	TheEncounter.em.after_callback(function()
		if save_table then
			if self.current_step.should_save then
				self.data = self.current_step:load(self, save_table.data) or {}
				after_load = true
			end
		else
			self:move_forward()
		end
		self:enter_step(after_load, func)
	end, save_table)
end
function TheEncounter.Event:enter_step(after_load, func)
	SMODS.calculate_context({ enc_step_start = true, event = self })
	TheEncounter.em.after_callback(function()
		self:set_colours()
		if not after_load then
			self:set_ability()
		end
		TheEncounter.UI.event_text_lines(self)
		self.current_step:start(self, after_load)
		TheEncounter.em.after_callback(function()
			if not after_load then
				if self.current_step.should_save then
					G.GAME.TheEncounter_save_table = self:save()
					save_run()
				end
			end
			TheEncounter.UI.event_show_all_text_lines(self)
			TheEncounter.UI.event_choices(self)
			TheEncounter.em.after_callback(func)
		end)
	end, not after_load)
end
function TheEncounter.Event:leave_step(func)
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
		G.FUNCS.draw_from_hand_to_deck()
		TheEncounter.em.after_callback(function()
			self:move_forward()
			SMODS.calculate_context({ enc_scenario_end = true, event = self })
			TheEncounter.em.after_callback(function()
				TheEncounter.UI.event_finish(self)
				G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"] = G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"]
					or {}
				G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"][self.scenario.key] = true
				TheEncounter.em.after_callback(function()
					TheEncounter.em.after_callback(func, true)
					G.GAME.TheEncounter_save_table = nil
					G.GAME.TheEncounter_choice = nil
					G.TheEncounter_event = nil
				end)
			end)
		end)
	end)
end

function TheEncounter.Event:save()
	if not self.current_step or not self.current_step.should_save then
		return
	end
	local save_table = {
		domain = self.domain.key,
		scenario = self.scenario.key,

		previous_step = self.previous_step and self.previous_step.key or nil,
		current_step = self.current_step and self.current_step.key or nil,
		next_step = self.next_step and self.next_step.key or nil,

		ability = self.ability,

		data = self.current_step:save(self.data) or {},
	}
	return save_table
end
function TheEncounter.Event.load(save_table)
	return TheEncounter.Event(save_table.scenario, save_table.domain, save_table)
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
		G.STATE = G.STATES.BLIND_SELECT
		G.STATE_COMPLETE = false
	end)
end
