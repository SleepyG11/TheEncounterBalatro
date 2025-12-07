--- @meta

--- @alias TheEncounter.ChoiceItem TheEncounter.ChoiceResolvable | { value: TheEncounter.ChoiceResolvable, ability?: table }

--- @class TheEncounter.Step: SMODS.GameObject
--- @field config? TheEncounter.EventAbility
--- @field text_colour? table Default colour for text in event panel and buttons
--- @field colour? table Base colour for event panel
--- @field background_colour? table | fun(self: TheEncounter.Step, event: TheEncounter.Event) Colour for background shader, or function to adjust background colour
--- @field get_colours? fun(self: TheEncounter.Step, event?: TheEncounter.Event): table?
--- @field get_choices? fun(self: TheEncounter.Step, event: TheEncounter.Event): TheEncounter.ChoiceItem[] | { columns?: number[] }
--- @field setup? fun(self: TheEncounter.Step, event: TheEncounter.Event, after_load: boolean) Function to setup effects and other event variables, called before text rendering
--- @field start? fun(self: TheEncounter.Step, event: TheEncounter.Event, after_load: boolean) Function where you can control displaying text lines and side effets you need on step start
--- @field finish? fun(self: TheEncounter.Step, event: TheEncounter.Event) Function where you can control side effets on step finish
--- @field can_save? boolean Can event state be saved during this step
--- @field save? fun(self: TheEncounter.Step, event: TheEncounter.Event, data: table): table? Function to serialize `event.data` object before saving
--- @field load? fun(self: TheEncounter.Step, event: TheEncounter.Event, save_data: table): table? Function to deserialize `event.data` object after loading
--- @field loc_vars? fun(self: TheEncounter.Step, info_queue: table, event: TheEncounter.Event): table?
--- @field set_text_ui? fun(self: TheEncounter.Step, event: TheEncounter.Event, nodes: table[], objects: Node[]) Function to add/update/remove nodes into text UI. New rows definition should be added to `nodes` table. If element needs to be hidden and revealed in order with other text lines, it should be inserted into `objects` table.
--- @overload fun(self: TheEncounter.Step): TheEncounter.Step
TheEncounter.Step = {}

--- @alias TheEncounter.StepResolvable TheEncounter.Step | string

--- @param step? TheEncounter.StepResolvable
--- @return TheEncounter.Step | nil
function TheEncounter.Step.resolve(step) end
