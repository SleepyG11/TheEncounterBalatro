--- @meta

--- @alias TheEncounter.ChoiceItem string | TheEncounter.Choice | { value: string | TheEncounter.Choice, ability?: table }

--- @class TheEncounter.Step: SMODS.GameObject
--- @field config? TheEncounter.EventAbility
--- @field text_colour? table Default colour for text in event panel and buttons
--- @field colour? table Base colour for event panel
--- @field background_colour? table Colour for background shader
--- @field get_choices? fun(self: TheEncounter.Step, event: TheEncounter.Event): TheEncounter.ChoiceItem[]
--- Function where you can control displaying text lines and other side effets you need
--- @field start? fun(self: TheEncounter.Step, event: TheEncounter.Event, after_load: boolean)
--- @field finish? fun(self: TheEncounter.Step, event: TheEncounter.Event)
--- @field should_save? boolean
--- @field save? fun(self: TheEncounter.Step, event: TheEncounter.Event, data: table): table
--- @field load? fun(self: TheEncounter.Step, event: TheEncounter.Event, save_data: table): table
--- @field loc_vars? fun(self: TheEncounter.Step, info_queue: table, event: TheEncounter.Event): table
--- @overload fun(self: TheEncounter.Step): TheEncounter.Step
TheEncounter.Step = {}
