TheEncounter.Steps = {}
TheEncounter.Step = SMODS.GameObject:extend({
	obj_table = TheEncounter.Steps,
	set = "enc_Step",
	obj_buffer = {},
	class_prefix = "st",
	required_params = {
		"key",
	},
	process_loc_text = function(self)
		if not G.localization.descriptions.enc_Step then
			G.localization.descriptions.enc_Step = {}
		end
		SMODS.process_loc_text(G.localization.descriptions.enc_Step, self.key:lower(), self.loc_txt)
		local current_loc_txt = G.localization.descriptions.enc_Step[self.key:lower()]

		if current_loc_txt and current_loc_txt.variants then
			for key, variant in pairs(current_loc_txt.variants) do
				SMODS.process_loc_text(G.localization.descriptions.enc_Step, self.key:lower() .. "_" .. key, variant)
			end
		end

		if not G.localization.descriptions.enc_Choice then
			G.localization.descriptions.enc_Choice = {}
		end
		if current_loc_txt and current_loc_txt.choices then
			for key, choice in pairs(current_loc_txt.choices) do
				local choice_key = TheEncounter.Choice.class_prefix .. "_" .. self.key:lower() .. "_" .. key
				SMODS.process_loc_text(G.localization.descriptions.enc_Choice, choice_key, choice)
				if choice.variants then
					for vkey, vvariant in pairs(choice.variants) do
						SMODS.process_loc_text(
							G.localization.descriptions.enc_Choice,
							choice_key .. "_" .. vkey,
							vvariant
						)
					end
				end
			end
		end
	end,

	config = {
		hide_hand = nil,
		hide_deck = nil,
		hide_text = nil,
		hide_image = nil,
		hide_choices = nil,
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
			"ch_enc_move_on",
		}
	end,

	start = function(self, event, after_load) end,
	finish = function(self, event) end,

	can_save = nil,
	save = function(self, event, data) end,
	load = function(self, event, save_table) end,

	loc_vars = function(self, info_queue, event)
		return {}
	end,
	inject = function() end,

	update = function(self, event, dt) end,
})

TheEncounter.Step.resolve = function(step)
	if type(step) == "string" then
		return TheEncounter.Steps[step]
	else
		return step
	end
end
