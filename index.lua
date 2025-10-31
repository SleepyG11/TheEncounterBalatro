TheEncounter = setmetatable({
	current_mod = SMODS.current_mod,
}, {})

-- Stupid fix for stupid problem
local old_align = CardArea.align_cards
function CardArea:align_cards(...)
	self.cards = self.cards or {}
	return old_align(self, ...)
end

assert(SMODS.load_file("src/utils/table.lua"))()
assert(SMODS.load_file("src/utils/e_manager.lua"))()

assert(SMODS.load_file("src/objects/index.lua"))()
assert(SMODS.load_file("src/ui/index.lua"))()

assert(SMODS.load_file("src/logic/pool.lua"))()
assert(SMODS.load_file("src/logic/blind_select.lua"))()
assert(SMODS.load_file("src/logic/event.lua"))()

assert(SMODS.load_file("src/items/fallback.lua"))()
assert(SMODS.load_file("src/items/default.lua"))()
