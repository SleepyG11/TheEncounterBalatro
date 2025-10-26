TheEncounter.Choice({
	key = "move_on",
	loc_txt = {
		text = {
			"Move on",
		},
	},
})
TheEncounter.Choice({
	key = "look_inside",
	loc_txt = {
		text = {
			"Look inside...",
		},
	},
	button = function(self, event)
		event:start_step("st_enc_nothing_inside")
	end,
})
TheEncounter.Step({
	key = "nothing_1",
	loc_txt = {
		text = {
			"Looks like there's nothing here...",
			" ",
			"Maybe I should look better?",
		},
	},
	get_choices = function(self, event)
		return {
			"ch_enc_move_on",
			"ch_enc_look_inside",
		}
	end,
	config = {
		extra = {
			var_3 = 3,
		},
	},
	colour = HEX("BF009D"),
	background_colour = HEX("9A007F"),
	should_save = true,
})
TheEncounter.Step({
	key = "nothing_inside",
	loc_txt = {
		text = {
			"You looked inside, but there's also nothing...",
			" ",
			"Looks like you're unlucky today.",
		},
	},
	config = {
		extra = {
			var_2 = 2,
		},
	},
	colour = HEX("6900CA"),
	background_colour = HEX("5700A9"),
	should_save = true,
})
TheEncounter.Scenario({
	key = "nothing",
	loc_txt = {
		name = "Nothing",
		text = {
			"You found nothing... Unfortunate!",
		},
	},
	config = {
		extra = {
			var_1 = 1,
		},
	},
	starting_step_key = "st_enc_nothing_1",
	no_collection = true,
	in_pool = function(self, domain)
		return false
	end,
})
