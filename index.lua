TheEncounter = setmetatable({
	current_mod = SMODS.current_mod,
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
