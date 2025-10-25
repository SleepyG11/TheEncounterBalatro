TheEncounter = setmetatable({
	current_mod = SMODS.current_mod,
}, {})

-- Stupid fix for stupid problem
local old_align = CardArea.align_cards
function CardArea:align_cards(...)
	self.cards = self.cards or {}
	return old_align(self, ...)
end

assert(SMODS.load_file("utils/table.lua"))()
assert(SMODS.load_file("utils/e_manager.lua"))()

assert(SMODS.load_file("objects/index.lua"))()
assert(SMODS.load_file("ui/index.lua"))()

assert(SMODS.load_file("logic/pool.lua"))()
assert(SMODS.load_file("logic/blind_select.lua"))()
assert(SMODS.load_file("logic/event.lua"))()

assert(SMODS.load_file("items/fallback.lua"))()
assert(SMODS.load_file("items/default.lua"))()
