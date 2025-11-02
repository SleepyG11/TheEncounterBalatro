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
		local current_loc_txt = G.localization.descriptions.enc_Choice[self.key:lower()]
		if current_loc_txt and current_loc_txt.variants then
			for key, variant in pairs(current_loc_txt.variants) do
				SMODS.process_loc_text(G.localization.descriptions.enc_Choice, self.key:lower() .. "_" .. key, variant)
			end
		end
	end,

	config = {
		extra = {},
	},

	-- Active button colour
	colour = nil,
	-- Inactive button colour
	inactive_colour = nil,
	-- Button text colour
	text_colour = nil,

	get_colours = function(self, event, ability) end,

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

TheEncounter.Choice.from_object = function(object)
	return {
		enc_is_choice_object = true,

		key = object.key or nil,
		full_key = object.full_key or nil,

		loc_vars = object.loc_vars or {},
		config = object.ability or object.config or {},

		colour = object.colour or nil,
		text_color = object.text_colour or nil,
		inactive_colour = object.inactive_colour or nil,

		button = object.button or function(self, event, ability)
			event:finish_scenario()
		end,
		func = object.func or function(self, event, ability)
			return true
		end,
	}
end

TheEncounter.Choice.resolve = function(choice)
	if type(choice) == "string" then
		return TheEncounter.Choices[choice]
	else
		return choice
	end
end
