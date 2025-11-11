TheEncounter.Scenario({
	key = "buzzfeed_quiz",
	loc_txt = {
		name = { "Personality Quiz" },
		text = {
			"Click here and find out",
			"which Joker you are!",
		},
	},
	domains = { do_enc_occurrence = true },
	config = {
		hide_hand = false,
	},
	starting_step_key = "st_enc_buzzfeed_quiz_start",
	in_pool = function(self)
		return true
		-- return not next(SMODS.find_card("j_hpot_diy", true))
	end,

	-- Prevent save-scumming
	can_save = true,

	-- ha, piss colours
	colour = HEX("D60000"),
	background_colour = HEX("A50000"),

	start = function(self, event, after_load)
		event:image_character({
			center = "j_joker",
			scale = 0.75,
		})
	end,
})

-- Start
TheEncounter.Step({
	key = "buzzfeed_quiz_start",
	loc_txt = {
		text = {
			"You accidentally clicked one of the ads on the screen. The page reads and reads:",
			" ",
			'{s:1.2}"Which {s:1.2,C:attention}Balatro{s:1.2} Joker are you?"',
			" ",
			"No harm in trying it out, right?",
		},
		choices = {
			take_quiz = {
				name = {
					"Take the quiz",
				},
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				key = "take_quiz",
				button = function(self, event, ability)
					event:start_step("st_enc_buzzfeed_quiz_1")
				end,
			},
			"ch_enc_move_on",
		}
	end,
})

-- First effect
TheEncounter.Choice({
	key = "buzzfeed_quiz_trigger",
	loc_txt = {
		name = {
			"I don't know",
		},
		variants = {
			park = {
				name = { "To the park" },
			},
			carnival = {
				name = { "To the town fair" },
			},
			casino = {
				name = { "To the casino" },
			},
			no_date = {
				name = { "Nowhere, because nothing ever happens" },
			},
		},
	},
	config = {
		extra = {
			effects = {
				park = 1,
				carnival = 2,
				casino = 3,
				no_date = 4,
			},
		},
	},
	button = function(self, event, ability)
		event.ability.extra.trigger_value = ability.extra.effects[ability.extra.chosen]
		event.ability.extra.trigger = ability.extra.chosen
		event:start_step("st_enc_buzzfeed_quiz_1_result")
	end,
	loc_vars = function(self, info_queue, event, ability)
		return {
			variant = ability.extra.chosen,
		}
	end,
	get_colours = function(self, event, ability)
		if ability.extra.chosen == "no_date" then
			return {
				colour = G.C.MULT,
			}
		end
	end,
})
TheEncounter.Step({
	key = "buzzfeed_quiz_1",
	loc_txt = {
		text = {
			'"Where would you like to go on a first date?"',
		},
	},
	config = {
		full_width_choices = true,
	},
	get_choices = function(self, event)
		local result = {}
		for _, variant in ipairs({ "park", "carnival", "casino", "no_date" }) do
			table.insert(result, {
				value = "ch_enc_buzzfeed_quiz_trigger",
				ability = {
					extra = {
						chosen = variant,
					},
				},
			})
		end
		result.columns = { 2, 2 }
		return result
	end,
})

-- First result
TheEncounter.Step({
	key = "buzzfeed_quiz_1_result",
	loc_txt = {
		text = {
			"You did not pick anything...",
		},
		choices = {
			continue = {
				name = { "Read the next question" },
			},
		},
		variants = {
			park = {
				text = { "You would like to go on a nice handholding date", "to the local park, you thought." },
			},
			carnival = {
				text = {
					"You would like to enjoy the attractions",
					"together at the local town fair, you thought.",
				},
			},
			casino = {
				text = {
					"They are not going out with me if they can't",
					"enjoy a little Plinko gambling, you thought.",
				},
			},
			no_date = {
				text = { "Dates? Those are woke nonsense.", "I'm going to be by my lonesome, you thought." },
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				key = "continue",
				button = function()
					event:start_step("st_enc_buzzfeed_quiz_2")
				end,
			},
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			variant = event.ability.extra.trigger,
		}
	end,
})

-- Second effect
TheEncounter.Choice({
	key = "buzzfeed_quiz_effect",
	loc_txt = {
		name = {
			"I don't know",
		},
		variants = {
			wait = {
				name = { "Wait patiently" },
			},
			forgive = {
				name = { "Forgive the debt" },
			},
			move = {
				name = { "Move out" },
			},
			sell = {
				name = { "Sell their possessions on the Black Market" },
			},
		},
	},
	config = {
		extra = {
			effects = {
				wait = 3,
				forgive = 6,
				move = 1,
				sell = 5,
			},
		},
	},
	button = function(self, event, ability)
		event.ability.extra.effect_value = ability.extra.effects[ability.extra.chosen]
		event.ability.extra.effect = ability.extra.chosen
		event:start_step("st_enc_buzzfeed_quiz_2_result")
	end,
	loc_vars = function(self, info_queue, event, ability)
		return {
			variant = ability.extra.chosen,
		}
	end,
	get_colours = function(self, event, ability)
		if ability.extra.chosen == "sell" then
			return {
				colour = G.C.MULT,
				text_colour = G.C.UI.TEXT_DARK,
			}
		end
	end,
})
TheEncounter.Step({
	key = "buzzfeed_quiz_2",
	loc_txt = {
		text = {
			'"Your roommate owes you 500 credits.',
			"They say they can pay you back if you just give them a",
			"little bit more time.",
			" ",
			'What do you do?"',
		},
	},
	get_choices = function(self, event)
		local result = {}
		for _, variant in ipairs({ "wait", "forgive", "move", "sell" }) do
			table.insert(result, {
				value = "ch_enc_buzzfeed_quiz_effect",
				ability = {
					extra = {
						chosen = variant,
					},
				},
			})
		end
		result.columns = { 2, 2 }
		return result
	end,
})

-- Second result
TheEncounter.Step({
	key = "buzzfeed_quiz_2_result",
	loc_txt = {
		text = {
			"You did not pick anything...",
		},
		choices = {
			continue = {
				name = { "See results" },
			},
		},
		variants = {
			wait = {
				text = {
					"I'm patient. I can wait for them, you thought.",
					" ",
					"You may be betrayed by those words some day.",
				},
			},
			forgive = {
				text = {
					"No relationship should be shackled to such things as",
					"money, you thought.",
					" ",
					"Maybe you're too forgiving.",
				},
			},
			move = {
				text = {
					"I can't be living with a leech! You thought.",
					" ",
					"Are credits this important to you?",
				},
			},
			sell = {
				text = {
					"Hey, at least I can make some of it back, you thought.",
					" ",
					"Maybe you should stop and think about what you would do after that.",
				},
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				key = "continue",
				button = function()
					event:start_step("st_enc_buzzfeed_quiz_finish")
				end,
			},
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			variant = event.ability.extra.effect,
		}
	end,
})

-- Finish
TheEncounter.Step({
	key = "buzzfeed_quiz_finish",
	loc_txt = {
		text = {
			'{s:1.2}"This is who you are!"',
			" ",
			"A picture of yourself appears on the screen.",
			" ",
			"...",
			"I thought this was about Balatro? Boring.",
		},
	},
	start = function(self, event, after_load)
		event:show_lines(3)
		if not after_load then
			if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
				G.E_MANAGER:add_event(Event({
					func = function()
						G.GAME.hotpot_diy = {
							trigger = event.ability.extra.trigger_value,
							effect = event.ability.extra.effect_value,
						}
						print(G.GAME.hotpot_diy)
						SMODS.add_card({ key = "j_joker" })
						return true
					end,
				}))
			end
		end
		delay(1)
	end,
})
