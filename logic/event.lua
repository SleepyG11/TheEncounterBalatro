G.STATES.ENC_EVENT = 292719887370

function Game:update_enc_event(dt)
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
						local event
						if G.GAME.TheEncounter_save_table then
							event = TheEncounter.Event.load(G.GAME.TheEncounter_save_table)
						else
							event = TheEncounter.Event(
								G.GAME.TheEncounter_choice.scenario_key,
								G.GAME.TheEncounter_choice.domain_key
							)
						end
						G.TheEncounter_event = event
						G.E_MANAGER:add_event(Event({
							trigger = "immediate",
							func = function()
								event:start(G.GAME.TheEncounter_save_table)
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
