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
		if not G.GAME.TheEncounter_choices then
			TheEncounter.poll_choices()
		end
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
						G.TheEncounter_blind_select = UIBox(TheEncounter.UI.blind_select(G.GAME.TheEncounter_choices))
						G.TheEncounter_prompt_box = UIBox(TheEncounter.UI.prompt_box())
						G.TheEncounter_blind_select.alignment.offset.y = 0
							- (G.hand.T.y - G.jokers.T.y)
							+ G.TheEncounter_blind_select.T.h
						G.ROOM.jiggle = G.ROOM.jiggle + 3
						G.TheEncounter_blind_select.alignment.offset.x = 0
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
	G.GAME.TheEncounter_choices_amount = G.GAME.TheEncounter_choices_amount or 2
	G.GAME.TheEncounter_choices_args = G.GAME.TheEncounter_choices_args
		or {
			increment_usage = true,
			using_fallback = true,
		}
	G.GAME.TheEncounter_choices = G.GAME.TheEncounter_choices or {}

	local duplicates_list = {}
	for _, item in ipairs(G.GAME.TheEncounter_choices) do
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

	G.GAME.TheEncounter_choices = result
end
TheEncounter.select_choice = function(scenario, domain)
	play_sound("timpani", 0.8)
	play_sound("generic1")

	if G.TheEncounter_blind_select then
		G.E_MANAGER:add_event(Event({
			trigger = "before",
			delay = 0.2,
			func = function()
				G.TheEncounter_blind_select.alignment.offset.y = 40
				G.TheEncounter_blind_select.alignment.offset.x = 0
				return true
			end,
		}))
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				G.TheEncounter_blind_select:remove()
				G.TheEncounter_blind_select = nil
				delay(0.2)
				return true
			end,
		}))
		TheEncounter.UI.remove_prompt_box()
	end
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
							domain = TheEncounter.Domain.resolve(domain)
							if not scenario then
								scenario = TheEncounter.POOL.poll_scenario(
									domain,
									{ increment_usage = true, with_fallback = true }
								)
							end
							scenario = TheEncounter.Scenario.resolve(scenario)
							G.GAME.TheEncounter_choice = {
								domain_key = domain.key,
								scenario_key = scenario.key,
							}
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
