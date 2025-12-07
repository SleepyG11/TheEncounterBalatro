--- @meta

--- @class TheEncounter.Choice: SMODS.GameObject
--- @field config? table
--- @field text_colour? table
--- @field colour? table
--- @field inactive_colour? table
--- @field get_colours? fun(self: TheEncounter.Choice, event?: TheEncounter.Event, ability?: table): table?
--- @field button? fun(self: TheEncounter.Choice, event: TheEncounter.Event, ability: table)
--- @field func? fun(self: TheEncounter.Choice, event: TheEncounter.Event, ability: table): boolean
--- @field loc_vars? fun(self: TheEncounter.Choice, info_queue: table, event: TheEncounter.Event, ability: table): table?
--- @overload fun(self: TheEncounter.Choice): TheEncounter.Choice
TheEncounter.Choice = {}

--- @alias TheEncounter.ChoiceResolvable TheEncounter.Choice | string

--- @param choice? TheEncounter.ChoiceResolvable
--- @return TheEncounter.Choice | nil
function TheEncounter.Choice.resolve(choice) end
