TheEncounter.em = {}

TheEncounter.em.after_callback = function(func, instant)
	if not func then
		return
	end
	if instant then
		return func()
	end
	G.E_MANAGER:add_event(Event({
		func = function()
			G.E_MANAGER:add_event(Event({
				func = function()
					func()
					return true
				end,
			}))
			return true
		end,
	}))
end
