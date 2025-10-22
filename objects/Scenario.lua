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

	loc_vars = function(self, info_queue, domain)
		return {}
	end,
	collection_loc_vars = function(self, info_queue, domain)
		return {}
	end,

	inject = function(self)
		SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
	end,
	pre_inject_class = function(self)
		G.P_CENTER_POOLS[self.set] = {}
	end,

	no_collection = false,

	get_atlas = function(self, domain)
		local domain_atlas, domain_pos = domain:get_atlas()
		local atlas = (self.atlas and G.ANIMATION_ATLAS[self.atlas]) or domain_atlas
		return atlas, self.pos or domain_pos
	end,
})

TheEncounter.Scenario({
	key = "nothing",
	starting_step_key = "enc_nothing",
	loc_txt = {
		name = "Next {C:attention}scenario{}",
		text = {
			"Ha, {C:attention}text{}!",
		},
	},
	domains = {
		enc_occurence = true,
	},
	loc_vars = function(self, info_queue, domain)
		return { vars = { "NEXT" } }
	end,
	collection_loc_vars = function(self, info_queue, domain)
		return { vars = { "NEXT" } }
	end,

	reward = "Unknown",
})
TheEncounter.Scenario({
	key = "nothing_2",
	starting_step_key = "enc_nothing_2",
	loc_txt = {
		name = "Test scenario 2",
		text = {
			"Ha, {C:mult}text{} 2",
		},
	},
	colour = HEX("FFFFFF"),
	-- text_colour = HEX("000000"),
	domains = {
		enc_encounter = true,
	},
})
