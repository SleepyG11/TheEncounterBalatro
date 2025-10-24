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
						G.enc_event_blind_select = UIBox({
							definition = {
								n = G.UIT.ROOT,
								config = { colour = G.C.CLEAR },
								nodes = TheEncounter.UI.blind_choices({
									{
										domain_key = "do_enc_occurrence",
									},
									{
										domain_key = "do_enc_u_occurrence",
									},
									{
										domain_key = "do_enc_r_occurrence",
									},
								}),
							},
							config = {
								align = "bmi",
								offset = { x = 0, y = G.ROOM.T.y + 29 },
								major = G.hand,
								bond = "Weak",
							},
						})
						G.enc_event_blind_select.alignment.offset.y = 0
							- (G.hand.T.y - G.jokers.T.y)
							+ G.enc_event_blind_select.T.h
						G.ROOM.jiggle = G.ROOM.jiggle + 3
						G.enc_event_blind_select.alignment.offset.x = 0
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
	if G.STATE == G.STATES.ENC_EVENT_SELECT and self == G.hand then
		return
	end
	return old_draw(self, ...)
end
