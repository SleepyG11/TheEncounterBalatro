TheEncounter.Scenarios = {}
TheEncounter.Scenario = SMODS.GameObject:extend({
	obj_table = TheEncounter.Scenarios,
	set = "enc_Scenario",
	obj_buffer = {},
	required_params = {
		"key",
		"starting_step_key",
	},
	process_loc_text = function(self)
		if not G.localization.descriptions.enc_Scenario then
			G.localization.descriptions.enc_Scenario = {}
		end
		SMODS.process_loc_text(G.localization.descriptions.enc_Scenario, self.key:lower(), self.loc_txt)
	end,

	config = {
		hide_hand = true,
		hide_deck = false,
		hide_text = false,
		hide_image = false,
		hide_buttons = false,

		extra = {},
	},

	domains = {},

	-- main text colour
	text_colour = nil,
	-- UI colour
	colour = nil,
	-- Shader colour
	background_colour = nil,

	can_repeat = false,
	in_pool = function(self)
		return true
	end,
	weight = 5,
	get_weight = function(self, domain)
		return self.weight
	end,

	loc_vars = function(self)
		return {}
	end,
	collection_loc_vars = function(self, info_queue)
		return {}
	end,

	inject = function(self)
		SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
	end,
	pre_inject_class = function(self)
		G.P_CENTER_POOLS[self.set] = {}
	end,

	no_collection = false,

	atlas = "enc_event_default",
	pos = { x = 0, y = 0 },
})

TheEncounter.Scenario({
	key = "nothing",
	starting_step_key = "enc_nothing",
	loc_txt = {
		name = "Test scenario",
		text = {
			"Ha, text",
		},
	},
	domains = {
		enc_occurence = true,
	},
})
TheEncounter.Scenario({
	key = "nothing_2",
	starting_step_key = "enc_nothing_2",
	loc_txt = {
		name = "Test scenario 2",
		text = {
			"Ha, text 2",
		},
	},
	domains = {
		enc_encounter = true,
	},
})
