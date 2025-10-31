--- @meta

--- @alias TheEncounter.ChoiceItem string | TheEncounter.Choice | { value: string | TheEncounter.Choice, ability?: table }

--- @class TheEncounter.Step: SMODS.GameObject
--- @field config? TheEncounter.EventAbility
--- @field text_colour? table Default colour for text in event panel and buttons
--- @field colour? table Base colour for event panel
--- @field background_colour? table Colour for background shader
--- @field get_choices? fun(self: TheEncounter.Step, event: TheEncounter.Event): TheEncounter.ChoiceItem[]
--- @field start? fun(self: TheEncounter.Step, event: TheEncounter.Event, after_load: boolean) Function where you can control displaying text lines and side effets you need on step start
--- @field finish? fun(self: TheEncounter.Step, event: TheEncounter.Event) Function where you can control side effets on step finish
--- @field can_save? boolean Can event state be saved during this step
--- @field save? fun(self: TheEncounter.Step, event: TheEncounter.Event, data: table): table Function to serialize `event.data` object before saving
--- @field load? fun(self: TheEncounter.Step, event: TheEncounter.Event, save_data: table): table Function to deserialize `event.data` object after loading
--- @field loc_vars? fun(self: TheEncounter.Step, info_queue: table, event: TheEncounter.Event): table
--- @overload fun(self: TheEncounter.Step): TheEncounter.Step
TheEncounter.Step = {}

--- @alias TheEncounter.StepResolvable TheEncounter.Step | string

--- @param step? TheEncounter.StepResolvable
--- @return TheEncounter.Step | nil
function TheEncounter.Step.resolve(step) end
