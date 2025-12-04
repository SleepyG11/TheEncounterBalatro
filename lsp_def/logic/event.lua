--- @meta

--- Main function to create event from current choice, or load from save table
--- @return TheEncounter.Event
function TheEncounter.before_event_start() end

--- Main function to discover finished scenario, cleanup event and other data such as current choices and seleted choice
function TheEncounter.after_event_finish() end

--- Check is current state is event state, which includes cases of using consumables but excludes case of opened booster pack during event
--- @return boolean
function TheEncounter.is_in_active_event_state() end

--- Check is event object present and current domain matches key
--- @param key string
--- @return boolean
function TheEncounter.is_in_domain(key) end

--- Check is event object present and current scenario matches key
--- @param key string
--- @return boolean
function TheEncounter.is_in_scenario(key) end

--- Check is event object present and current step matches key
--- @param key string
--- @return boolean
function TheEncounter.is_in_step(key) end
