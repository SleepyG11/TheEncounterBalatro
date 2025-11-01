TheEncounter.Scenarios = {}
TheEncounter.Scenario = SMODS.GameObject:extend({
	obj_table = TheEncounter.Scenarios,
	set = "enc_Scenario",
	obj_buffer = {},
	class_prefix = "sc",
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
		hide_choices = false,
		can_use = true,
		can_sell = true,
		extra = {},
	},

	domains = {},

	reward = nil,

	-- main text colour
	text_colour = nil,
	-- UI colour
	colour = nil,
	-- Shader colour
	background_colour = nil,

	once_per_run = false,
	can_repeat = false,
	in_pool = function(self, domain)
		return true
	end,
	default_weight = 5,
	get_weight = function(self, weight, domain)
		return self.weight
	end,

	can_save = false,
	save = function(self, event, data) end,
	load = function(self, event, save_table) end,

	loc_vars = function(self, info_queue, domain)
		return {}
	end,
	collection_loc_vars = function(self, info_queue, domain)
		return {}
	end,

	inject = function(self)
		SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
		self.alerted = false
		if
			G.PROFILES[G.SETTINGS.profile]["enc_alerted_scenarios"]
			and G.PROFILES[G.SETTINGS.profile]["enc_alerted_scenarios"][self.key]
		then
			self.alerted = true
		end
	end,
	pre_inject_class = function(self)
		G.P_CENTER_POOLS[self.set] = {}
	end,

	no_collection = false,
	unlocked = true,
	discoverable = true,
	discovered = false,

	get_atlas = function(self, domain)
		local domain_atlas, domain_pos = domain:get_atlas()
		local atlas = (self.atlas and G.ANIMATION_ATLAS[self.atlas]) or domain_atlas
		return atlas, self.pos or domain_pos
	end,
	set_badges = function(self, badges, domain) end,

	update = function(self, event, dt) end,
})

TheEncounter.Scenario.resolve = function(scenario)
	if type(scenario) == "string" then
		return TheEncounter.Scenarios[scenario]
	else
		return scenario
	end
end

--------------

local set_profile_progress_ref = set_profile_progress
function set_profile_progress(...)
	local result = set_profile_progress_ref(...)
	G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"] = G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"]
		or {}
	for key, scenario in pairs(TheEncounter.Scenarios) do
		if scenario.discoverable and G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"][key] then
			scenario.discovered = true
		end
	end
	return result
end

local old_unlock_all = G.FUNCS.unlock_all
function G.FUNCS.unlock_all(...)
	local result = old_unlock_all(...)
	G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"] = G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"]
		or {}
	G.PROFILES[G.SETTINGS.profile]["enc_alerted_scenarios"] = G.PROFILES[G.SETTINGS.profile]["enc_alerted_scenarios"]
		or {}

	for key, scenario in pairs(TheEncounter.Scenarios) do
		if scenario.discoverable then
			G.PROFILES[G.SETTINGS.profile]["enc_discovered_scenarios"][key] = true
			G.PROFILES[G.SETTINGS.profile]["enc_alerted_scenarios"][key] = true
			scenario.alerted = true
			scenario.discovered = true
		end
	end
	return result
end
