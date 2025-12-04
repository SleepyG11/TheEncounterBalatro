-- Custom music during this specific event
if false then
	SMODS.Sound({
		key = "music_man",
		path = "music_man.ogg",
		pitch = 1,
		select_music_track = function(self)
			if TheEncounter.is_in_active_event_state() and TheEncounter.is_in_scenario("sc_enc_man_ogg") then
				return 1666
			end
		end,
	})
end

TheEncounter.Domain({
	key = "aroombetween",

	loc_txt = {
		name = "The Room Between",
		text = {
			"There is a room between...",
		},
	},

	-- This is rare event, which behave like The Soul and can be encountered only once per run
	hidden = true,
	soul_rate = 0.066666667,
	once_per_run = true,

	colour = HEX("DE2041"),

	no_collection = true,
})

TheEncounter.Scenario({
	key = "man_ogg",
	loc_txt = {
		name = "The Room Between",
		text = {
			"Well, there is a man here.",
		},
	},
	domains = {
		do_enc_aroombetween = true,
	},
	starting_step_key = "st_enc_egg_room_start",
})

TheEncounter.Step({
	key = "egg_room_start",
	loc_txt = {
		text = {
			"Well, there is a man here.",
		},
		choices = {
			egg = {
				name = { "Yes" },
			},
			eggnt = {
				name = { "No" },
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				key = "egg",
				button = function()
					SMODS.add_card({ key = "j_egg", edition = "e_negative" })
					event:finish_scenario()
				end,
			},
			{
				key = "eggnt",
			},
		}
	end,
	background_colour = function(self, event)
		-- custom vortex
		ease_background_colour({
			new_colour = darken(HEX("DE2041"), 0.2),
			special_colour = G.C.BLACK,
			contrast = 5,
		})
	end,
})
