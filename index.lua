TheEncounter = setmetatable({
	current_mod = SMODS.current_mod,
}, {})

assert(SMODS.load_file("utils/table.lua"))()

assert(SMODS.load_file("objects/index.lua"))()
assert(SMODS.load_file("ui/index.lua"))()

assert(SMODS.load_file("logic/blind_select.lua"))()
assert(SMODS.load_file("logic/pool.lua"))()
