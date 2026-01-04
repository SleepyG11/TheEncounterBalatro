--- @meta

--- @class TheEncounter.Domain: SMODS.GameObject
--- @field config? TheEncounter.EventAbility
--- @field rarity? string|number
--- @field reward? TheEncounter.RewardDisplay | fun(self: TheEncounter.Domain, is_hud?: boolean): TheEncounter.RewardDisplay | TheEncounter.FullRewardDisplayDefinition
--- @field text_colour? table Default colour for text in event panel and buttons
--- @field colour? table Base colour for event panel
--- @field background_colour? table | fun(self: TheEncounter.Domain, event: TheEncounter.Event) Colour for background shader, or function to adjust background colour
--- @field get_colours? fun(self: TheEncounter.Domain, event?: TheEncounter.Event): table?
--- @field hidden? boolean Sets if this domain is considered "legendary" (e.x. behaves like "The Soul")
--- @field soul_rate? number Chance this domain replaces. Requires `hidden` to be true
--- @field once_per_run? boolean
--- @field can_repeat? boolean Is this object bypasses unique loop (like boss blinds loop in vanilla)
--- @field in_pool? fun(self: TheEncounter.Domain): boolean, table?
--- @field default_weight? number
--- @field get_weight? fun(self: TheEncounter.Domain, weight: number): number
--- @field setup? fun(self: TheEncounter.Domain, event: TheEncounter.Event) Function to setup effects and other event variables, called once when entered
--- @field start? fun(self: TheEncounter.Domain, event: TheEncounter.Event, after_load: boolean) Function where you can control side effets you need on scenario start
--- @field finish? fun(self: TheEncounter.Domain, event: TheEncounter.Event) Function where you can control side effets on scenario finish
--- @field can_save? boolean Can event state be saved during each step. `scenario.can_save` or `step.can_save` takes priority
--- @field save? fun(self: TheEncounter.Domain, event: TheEncounter.Event, data: table): table? Function to serialize `event.data` object before saving
--- @field load? fun(self: TheEncounter.Domain, event: TheEncounter.Event, save_data: table): table? Function to deserialize `event.data` object after loading
--- @field loc_vars? fun(self: TheEncounter.Domain, info_queue: table): table?
--- @field collection_loc_vars? fun(self: TheEncounter.Domain, info_queue: table): table?
--- @field atlas? string
--- @field pos? { x: number, y: number }
--- @field no_collection? boolean
--- @field get_sprite? fun(self: TheEncounter.Domain): SMODS.Atlas, { x: number, y: number }, { w: number, y: number } | nil
--- @field get_undiscovered_sprite? fun(self: TheEncounter.Domain): SMODS.Atlas, { x: number, y: number }, { w: number, y: number } | nil
--- @field set_badges? fun(self: TheEncounter.Domain, badges: table)
--- @overload fun(self: TheEncounter.Domain): TheEncounter.Domain
TheEncounter.Domain = {}

--- @alias TheEncounter.DomainResolvable TheEncounter.Domain | string

--- @param domain? TheEncounter.DomainResolvable
--- @return TheEncounter.Domain | nil
function TheEncounter.Domain.resolve(domain) end
