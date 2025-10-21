TheEncounter.Domains = {}
TheEncounter.Domain = SMODS.GameObject:extend({
	obj_table = TheEncounter.Domains,
	set = "enc_Domain",
	obj_buffer = {},

	required_params = {
		"key",
	},
	process_loc_text = function(self)
		if not G.localization.descriptions.enc_Domain then
			G.localization.descriptions.enc_Domain = {}
		end
		SMODS.process_loc_text(G.localization.descriptions.enc_Domain, self.key:lower(), self.loc_txt)
	end,

	config = {
		extra = {},
	},

	-- main text colour
	text_colour = G.C.UI.TEXT_LIGHT,
	-- UI colour
	colour = G.C.MULT,
	-- Shader colour
	background_colour = G.C.MULT,

	can_repeat = true,
	in_pool = function(self)
		return true
	end,
	weight = 5,
	get_weight = function(self)
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
