--- @meta

--- Main function to poll choices for current encounter.
--- @return TheEncounter.EventChoiceOption[]
function TheEncounter.poll_choices() end

--- Main function to poll scenario in domain when choice was selected without predetermined one
--- @param domain TheEncounter.DomainResolvable
--- @return string
function TheEncounter.select_scenario(domain) end

--- Main function which called on clicking "Select".<br/>
--- If no scenario is provided, it will be polled from selected domain by calling `TheEncounter.select_scenario(domain)`<br/>
--- Result saved in `G.GAME.TheEncounter_choice` and game can transition to `G.STATES.ENC_EVENT`
--- @param scenario? TheEncounter.ScenarioResolvable
--- @param domain TheEncounter.DomainResolvable
--- @return TheEncounter.EventChoiceOption
function TheEncounter.select_choice(domain, scenario) end

--- Function which determines should start encounter sequence and transition to `G.STATES.ENC_EVENT_SELECT`.<br/>
--- Currently event can appear:<br/>
--- - before Shop (after cashout)
--- - after Shop (before blind select)
--- @return boolean
function TheEncounter.should_encounter(args) end

--- Function which setups all values needed and proceed to `G.STATES.ENC_EVENT_SELECT`.
--- @param args { after?: "shop" | "cashout", replaced_state?: any }
function TheEncounter.encounter(args) end

--- Create, replace or remove choice by index. Update value in `G.GAME.TheEncounter_choices` and rerender UI
--- @param index number
--- @param choice TheEncounter.EventChoiceOption | nil
function TheEncounter.replace_choice(index, choice) end

--- Replace choices. Update value in `G.GAME.TheEncounter_choices` and rerender UI
--- @param choices TheEncounter.EventChoiceOption[]
--- @param with_prompt boolean? Should rerender prompt box
function TheEncounter.replace_all_choices(choices, with_prompt) end
