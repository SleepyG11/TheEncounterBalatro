TheEncounter.Steps = {}
TheEncounter.Step = SMODS.GameObject:extend({
	obj_table = TheEncounter.Steps,
	set = "enc_Step",
	obj_buffer = {},
	required_params = {
		"key",
	},
	process_loc_text = function(self)
		if not G.localization.descriptions.enc_Step then
			G.localization.descriptions.enc_Step = {}
		end
		if not G.localization.descriptions.enc_Choice then
			G.localization.descriptions.enc_Choice = {}
		end
		SMODS.process_loc_text(G.localization.descriptions.enc_Step, self.key:lower(), self.loc_txt)
		if self.loc_txt and self.loc_txt.choices then
			for k, _ in pairs(self.loc_txt.choices) do
				SMODS.process_loc_text(
					G.localization.descriptions.enc_Choice,
					self.key:lower() .. "_" .. k,
					self.loc_txt.choices[k]
				)
			end
		end
	end,

	config = {
		extra = {},
	},

	-- main text colour
	text_colour = nil,
	-- UI colour
	colour = nil,
	-- Shader colour
	background_colour = nil,

	get_choices = function(self, event)
		return {
			TheEncounter.Choices.enc_move_on,
		}
	end,

	start = function(self, event) end,
	finish = function(self, event) end,

	should_save = false,
	save = function(self, event) end,
	load = function(self, event, save_table) end,

	loc_vars = function(self, event)
		return {}
	end,
	inject = function() end,
})

TheEncounter.Step.resolve = function(step)
	if type(step) == "string" then
		return TheEncounter.Steps[step]
	else
		return step
	end
end
