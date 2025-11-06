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
		local current_loc_txt = G.localization.descriptions.enc_Domain[self.key:lower()]
		if current_loc_txt and current_loc_txt.variants then
			for key, variant in pairs(current_loc_txt.variants) do
				SMODS.process_loc_text(G.localization.descriptions.enc_Domain, self.key:lower() .. "_" .. key, variant)
			end
		end
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

	get_colours = function(self, event) end,

	once_per_run = false,
	can_repeat = true,
	in_pool = function(self)
		return true
	end,
	default_weight = 5,
	get_weight = function(self, weight)
		return self.weight
	end,

	loc_vars = function(self, info_queue)
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

	get_atlas = function(self) end,
	set_badges = function(self, badges) end,
})

TheEncounter.Domain.resolve = function(domain)
	if type(domain) == "string" then
		return TheEncounter.Domains[domain]
	else
		return domain
	end
end

SMODS.ObjectType({
	key = "enc_Domain",
})
