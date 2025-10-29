--- @meta

--- @class TheEncounter.Domain: SMODS.GameObject
--- @field config? TheEncounter.EventAbility
--- @field rarity? string|number
--- @field reward? TheEncounter.RewardDisplay | fun(self: TheEncounter.Domain): TheEncounter.RewardDisplay
--- @field text_colour? table Default colour for text in event panel and buttons
--- @field colour? table Base colour for event panel
--- @field background_colour? table Colour for background shader
--- @field once_per_run? boolean
--- @field can_repeat? boolean Is this object bypasses unique loop (like boss blinds loop in vanilla)
--- @field in_pool? fun(self: TheEncounter.Domain): boolean, table?
--- @field default_weight? number
--- @field get_weight? fun(self: TheEncounter.Domain, weight: number): number
--- @field loc_vars? fun(self: TheEncounter.Domain, info_queue: table): table
--- @field collection_loc_vars? fun(self: TheEncounter.Domain, info_queue: table): table
--- @field atlas? string
--- @field pos? { x: number, y: number }
--- @field no_collection boolean
--- @field get_atlas? fun(self: TheEncounter.Domain): SMODS.Atlas, { x: number, y: number }
--- @field set_badges? fun(self: TheEncounter.Domain, badges: table)
--- @overload fun(self: TheEncounter.Domain): TheEncounter.Domain
TheEncounter.Domain = {}

--- @param domain? string | TheEncounter.Domain
--- @return TheEncounter.Domain | nil
function TheEncounter.Domain.resolve(domain) end
