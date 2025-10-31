--- @meta

--- UIBox definition and config for Domain or Scenario in blind choices list
---@param index number
---@param total number
---@param scenario? TheEncounter.ScenarioResolvable
---@param domain TheEncounter.DomainResolvable
---@return table
function TheEncounter.UI.event_choice_render(index, total, scenario, domain) end

--- UIBox definition for Domain or Scenario in blind choices list
---@param choices { scenario_key?: string, domain_key: string }[]
---@return table
function TheEncounter.UI.event_choices_render(choices) end

--- Move event choices in visible area
function TheEncounter.UI.set_event_choices() end

--- Hide event choices and remove
function TheEncounter.UI.remove_event_choices() end
