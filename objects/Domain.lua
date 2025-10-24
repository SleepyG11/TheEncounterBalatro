TheEncounter.Domains = {}
TheEncounter.Domain = SMODS.GameObject:extend({
	obj_table = TheEncounter.Domains,
	set = "enc_Domain",
	obj_buffer = {},
	class_prefix = "do",
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

	rarity = 1,

	reward = 1,

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
	default_weight = 5,
	get_weight = function(self, weight)
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

	get_atlas = function(self)
		return G.ANIMATION_ATLAS[self.atlas], self.pos
	end,
	set_badges = function(self, badges) end,
})

SMODS.ObjectType({
	key = "enc_Domain",
})

TheEncounter.Domain.resolve = function(domain)
	if type(domain) == "string" then
		return TheEncounter.Domains[domain]
	else
		return domain
	end
end

--------------

TheEncounter.Domain({
	key = "occurrence",
	loc_txt = {
		name = "Occurrence",
		text = {
			"Regular events",
		},
	},

	colour = HEX("0093ff"),

	reward = 1,
	rarity = 1,
})

TheEncounter.Domain({
	key = "u_occurrence",
	loc_txt = {
		name = "Uncommon Occurrence",
		text = {
			"Uncommon events",
		},
	},

	colour = HEX("35bd86"),

	reward = 1,
	rarity = 2,
})

TheEncounter.Domain({
	key = "r_occurrence",
	loc_txt = {
		name = "Rare Occurrence",
		text = {
			"Rare events",
		},
	},

	colour = HEX("F30808"),

	reward = 1,
	rarity = 3,
})

for i = 1, 10 do
	TheEncounter.Domain({
		key = "noth_" .. i,
		loc_txt = {
			name = "Noth " .. i,
			text = {
				"Domain " .. i,
			},
		},

		colour = HEX("AB00D6"),

		reward = 1,
	})
end
