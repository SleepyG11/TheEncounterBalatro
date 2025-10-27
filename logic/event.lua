G.STATES.ENC_EVENT = 292719887370

function Game:update_enc_event(dt)
	if G.TheEncounter_event then
		G.TheEncounter_event:update(dt)
	end
	if not G.STATE_COMPLETE then
		stop_use()
		ease_background_colour_blind(G.STATES.BLIND_SELECT)
		G.E_MANAGER:add_event(Event({
			func = function()
				save_run()
				return true
			end,
		}))
		G.STATE_COMPLETE = true
		G.CONTROLLER.interrupt.focus = true
		G.E_MANAGER:add_event(Event({
			func = function()
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						local event = TheEncounter.before_event_start()
						G.E_MANAGER:add_event(Event({
							trigger = "immediate",
							func = function()
								event:start()
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
end

function TheEncounter.before_event_start()
	local event
	if G.GAME.TheEncounter_save_table then
		event = TheEncounter.Event.load(G.GAME.TheEncounter_save_table)
	else
		event = TheEncounter.Event(G.GAME.TheEncounter_choice.scenario_key, G.GAME.TheEncounter_choice.domain_key)
	end
	G.TheEncounter_event = event
	return event
end

function TheEncounter.after_event_finish(event)
	G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"] = G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"]
		or {}
	G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"][event.scenario.key] = true
	G.GAME.TheEncounter_save_table = nil
	G.GAME.TheEncounter_choices = nil
	G.GAME.TheEncounter_choice = nil
	G.TheEncounter_event:remove()
	G.TheEncounter_event = nil
end

local old_game_delete_run = Game.delete_run
function Game:delete_run(...)
	local result = old_game_delete_run(self, ...)
	if self.TheEncounter_event then
		self.TheEncounter_event:remove()
		self.TheEncounter_event = nil
	end
	if self.ROOM then
		if self.TheEncounter_blind_choices then
			self.TheEncounter_blind_choices:remove()
			self.TheEncounter_blind_choices = nil
		end
		if self.TheEncounter_prompt_box then
			self.TheEncounter_prompt_box:remove()
			self.TheEncounter_prompt_box = nil
		end
	end
	return result
end
