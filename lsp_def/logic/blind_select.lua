--- Main function to poll and set choices for current encounter.<br/>
--- Result saved in `G.GAME.TheEncounter_choices` and game can transitions to `G.STATES.ENC_EVENT_SELECT`
--- @return { scenario_key?: string, domain_key: string }[]
function TheEncounter.poll_choices() end

--- Main function which called on clicking "Select".<br/>
--- If no scenario is provided, it be polled from selected domain<br/>
--- Result saved in `G.GAME.TheEncounter_choice` and game can transition to `G.STATES.ENC_EVENT`
--- @param scenario? TheEncounter.ScenarioResolvable
--- @param domain TheEncounter.DomainResolvable
--- @return { scenario_key: string, domain_key: string }
function TheEncounter.select_choice(scenario, domain) end

--- Function which determines should start encounter sequence and transition to `G.STATES.ENC_EVENT_SELECT`.<br/>
--- Currently event can appear:<br/>
--- - before Shop
--- - after Shop
--- @return boolean
function TheEncounter.should_encounter() end
