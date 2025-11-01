G.STATES.ENC_EVENT_SELECT = 292719887369

function Game:update_enc_event_select(dt)
	if self.buttons then
		self.buttons:remove()
		self.buttons = nil
	end
	if self.shop then
		self.shop:remove()
		self.shop = nil
	end

	if not G.STATE_COMPLETE then
		stop_use()
		ease_background_colour_blind(G.STATES.BLIND_SELECT)
		G.GAME.TheEncounter_choices_amount = G.GAME.TheEncounter_choices_amount or 2
		G.GAME.TheEncounter_choices_args = G.GAME.TheEncounter_choices_args or {
			increment_usage = true,
		}
		G.GAME.TheEncounter_choices = G.GAME.TheEncounter_choices or TheEncounter.poll_choices()
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
						play_sound("cancel")
						G.TheEncounter_blind_choices =
							UIBox(TheEncounter.UI.event_choices_render(G.GAME.TheEncounter_choices))
						G.TheEncounter_prompt_box = UIBox(TheEncounter.UI.prompt_box_render())

						TheEncounter.UI.set_event_choices()
						TheEncounter.UI.set_prompt_box()
						G.CONTROLLER.lock_input = false
						return true
					end,
				}))
				return true
			end,
		}))
	end
end

local old_draw = CardArea.draw
function CardArea:draw(...)
	if
		(
			G.STATE == G.STATES.ENC_EVENT_SELECT
			or G.TAROT_INTERRUPT == G.STATES.ENC_EVENT_SELECT
			or G.PACK_INTERRUPT == G.STATES.ENC_EVENT_SELECT
		) and self == G.hand
	then
		return
	end
	return old_draw(self, ...)
end

TheEncounter.poll_choices = function()
	local duplicates_list = {}
	for _, item in ipairs(G.GAME.TheEncounter_choices or {}) do
		if item.scenario_key then
			duplicates_list[item.scenario_key] = true
		end
		duplicates_list[item.domain_key] = true
	end

	local result = {}
	local poll_result = TheEncounter.POOL.poll_domains(
		G.GAME.TheEncounter_choices_amount,
		G.GAME.TheEncounter_choices_args,
		duplicates_list
	)
	for _, item in ipairs(poll_result) do
		table.insert(result, {
			domain_key = item,
		})
	end

	return result
end
TheEncounter.select_choice = function(scenario, domain)
	domain = TheEncounter.Domain.resolve(domain)
	if not scenario then
		scenario = TheEncounter.POOL.poll_scenario(domain, G.GAME.TheEncounter_choices_args)
	end
	scenario = TheEncounter.Scenario.resolve(scenario)

	return {
		domain_key = domain.key,
		scenario_key = scenario.key,
	}
end
TheEncounter.should_encounter = function()
	return true
end
