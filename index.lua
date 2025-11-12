to_big = to_big or function(x)
	return x
end
to_number = to_number or function(x)
	return x
end
is_big = is_big or function(x)
	return false
end

TheEncounter = setmetatable({
	current_mod = SMODS.current_mod,
}, {})

-- Stupid fix for stupid problem
local old_align = CardArea.align_cards
function CardArea:align_cards(...)
	self.cards = self.cards or {}
	self.children = self.children or {}
	return old_align(self, ...)
end

assert(SMODS.load_file("src/utils/index.lua"))()
assert(SMODS.load_file("src/objects/index.lua"))()
assert(SMODS.load_file("src/ui/index.lua"))()
assert(SMODS.load_file("src/logic/index.lua"))()
assert(SMODS.load_file("src/items/index.lua"))()

-- assert(SMODS.load_file("examples/hotpot_diy.lua"))()
-- assert(SMODS.load_file("examples/hotpot_combat.lua"))()
-- assert(SMODS.load_file("examples/hotpot_transaction.lua"))()
