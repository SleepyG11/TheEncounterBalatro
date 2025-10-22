TheEncounter = setmetatable({
	current_mod = SMODS.current_mod,

	UI = {},
}, {})

SMODS.Atlas({
	key = "enc_event_default",
	px = 34,
	py = 34,
	path = "default.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

assert(SMODS.load_file("objects/Choice.lua"))()
assert(SMODS.load_file("objects/Domain.lua"))()
assert(SMODS.load_file("objects/Step.lua"))()
assert(SMODS.load_file("objects/Scenario.lua"))()

assert(SMODS.load_file("ui/collection.lua"))()
assert(SMODS.load_file("ui/blind_select.lua"))()

assert(SMODS.load_file("logic/blind_select.lua"))()
