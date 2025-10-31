--- @meta

--- @class TheEncounter.Scenario: SMODS.GameObject
--- @field config? TheEncounter.EventAbility
--- @field reward? TheEncounter.RewardDisplay | fun(self: TheEncounter.Scenario, domain?: TheEncounter.Domain): TheEncounter.RewardDisplay
--- @field text_colour? table Default colour for text in event panel and buttons
--- @field colour? table Base colour for event panel
--- @field background_colour? table Colour for background shader
--- @field once_per_run? boolean
--- @field can_repeat? boolean Is this object bypasses unique loop (like boss blinds loop in vanilla)
--- @field in_pool? fun(self: TheEncounter.Scenario, domain?: TheEncounter.Domain): boolean, table?
--- @field default_weight? number
--- @field get_weight? fun(self: TheEncounter.Scenario, weight: number, domain?: TheEncounter.Domain): number
--- @field can_save? boolean Can event state be saved during each step. `step.can_save` takes priority
--- @field save? fun(self: TheEncounter.Scenario, event: TheEncounter.Event, data: table): table
--- @field load? fun(self: TheEncounter.Scenario, event: TheEncounter.Event, save_data: table): table
--- @field loc_vars? fun(self: TheEncounter.Scenario, info_queue: table, domain?: TheEncounter.Domain): table
--- @field collection_loc_vars? fun(self: TheEncounter.Scenario, info_queue: table, domain?: TheEncounter.Domain): table
--- @field atlas? string
--- @field pos? { x: number, y: number }
--- @field no_collection boolean
--- @field discoverable boolean
--- @field discovered boolean
--- @field get_atlas? fun(self: TheEncounter.Scenario, domain?: TheEncounter.Domain): SMODS.Atlas, { x: number, y: number }
--- @field set_badges? fun(self: TheEncounter.Scenario, badges: table, domain?: TheEncounter.Domain)
--- @overload fun(self: TheEncounter.Scenario): TheEncounter.Scenario
TheEncounter.Scenario = {}

--- @alias TheEncounter.ScenarioResolvable TheEncounter.Scenario | string

--- @param scenario? TheEncounter.ScenarioResolvable
--- @return TheEncounter.Scenario | nil
function TheEncounter.Scenario.resolve(scenario) end
