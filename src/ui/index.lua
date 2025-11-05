TheEncounter.UI = {}

SMODS.Atlas({
	key = "enc_event_default",
	px = 34,
	py = 34,
	path = "default.png",
	atlas_table = "ANIMATION_ATLAS",
	frames = 21,
})

assert(SMODS.load_file("src/ui/shared.lua"))()
assert(SMODS.load_file("src/ui/collection.lua"))()
assert(SMODS.load_file("src/ui/blind_select.lua"))()
assert(SMODS.load_file("src/ui/event.lua"))()
