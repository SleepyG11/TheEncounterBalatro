--- @meta

--- @alias TheEncounter.ChoiceObject { scenario_key?: string, domain_key: string }

--- Main function to poll and set choices for current encounter.<br/>
--- Result saved in `G.GAME.TheEncounter_choices` and game can transitions to `G.STATES.ENC_EVENT_SELECT`
--- @return TheEncounter.ChoiceObject[]
function TheEncounter.poll_choices() end

--- Main function which called on clicking "Select".<br/>
--- If no scenario is provided, it be polled from selected domain<br/>
--- Result saved in `G.GAME.TheEncounter_choice` and game can transition to `G.STATES.ENC_EVENT`
--- @param scenario? TheEncounter.ScenarioResolvable
--- @param domain TheEncounter.DomainResolvable
--- @return TheEncounter.ChoiceObject
function TheEncounter.select_choice(domain, scenario) end

--- Function which determines should start encounter sequence and transition to `G.STATES.ENC_EVENT_SELECT`.<br/>
--- Currently event can appear:<br/>
--- - before Shop
--- - after Shop
--- @return boolean
function TheEncounter.should_encounter() end

--- Create, replace or remove choice by index. Update value in `G.GAME.TheEncounter_choices` and rerendering UI if present
--- @param index number
--- @param choice TheEncounter.ChoiceObject | nil
function TheEncounter.replace_choice(index, choice) end

--- Replace choices. Update value in `G.GAME.TheEncounter_choices` and rerendering UI if present
--- @param choices TheEncounter.ChoiceObject[]
--- @param with_prompt boolean? Should rerender prompt box
function TheEncounter.replace_all_choices(choices, with_prompt) end
