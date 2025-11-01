TheEncounter = setmetatable({
	current_mod = SMODS.current_mod,
}, {})

-- Stupid fix for stupid problem
local old_align = CardArea.align_cards
function CardArea:align_cards(...)
	self.cards = self.cards or {}
	return old_align(self, ...)
end

assert(SMODS.load_file("src/utils/index.lua"))()
assert(SMODS.load_file("src/objects/index.lua"))()
assert(SMODS.load_file("src/ui/index.lua"))()
assert(SMODS.load_file("src/logic/index.lua"))()
assert(SMODS.load_file("src/items/index.lua"))()
