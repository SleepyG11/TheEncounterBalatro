TheEncounter.Choices = {}
TheEncounter.Choice = SMODS.GameObject:extend({
	obj_table = TheEncounter.Choices,
	set = "enc_Choice",
	obj_buffer = {},
	class_prefix = "ch",
	required_params = {
		"key",
	},
	process_loc_text = function(self)
		if not G.localization.descriptions.enc_Choice then
			G.localization.descriptions.enc_Choice = {}
		end
		SMODS.process_loc_text(G.localization.descriptions.enc_Choice, self.key:lower(), self.loc_txt)
	end,

	config = {
		extra = {},
	},

	button = function(self, event, ability)
		event:finish_scenario()
	end,
	func = function(self, event, ability)
		return true
	end,

	loc_vars = function(self, info_queue, event, ability)
		return {}
	end,
	inject = function() end,
})

TheEncounter.Choice.resolve = function(choice)
	if type(choice) == "string" then
		return TheEncounter.Choices[choice]
	else
		return choice
	end
end
