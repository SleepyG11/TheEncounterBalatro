--- @meta

TheEncounter.POOL = {}

--- @return string | number
function TheEncounter.POOL.get_fallback_rarity() end

--- @param args? { domains_in_pool?: table<TheEncounter.Domain>, without_fallback?: boolean }
--- @return string | number | nil, boolean
function TheEncounter.POOL.poll_rarity(args) end

------------------

--- @return string
function TheEncounter.POOL.get_fallback_domain() end

--- @return table<string, number>
function TheEncounter.POOL.get_domains_usage() end

--- @param domain string | TheEncounter.Domain
function TheEncounter.POOL.increment_domain_usage(domain) end

--- @param domain string | TheEncounter.Domain
--- @param args? { ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return boolean, table?
function TheEncounter.POOL.is_domain_in_pool(domain, args, duplicates_list) end

--- @param args? { options?: table<TheEncounter.Domain>, ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean, allow_repeats?: boolean, ignore_rarity?: boolean, rarity?: string | number, without_fallback?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return table<TheEncounter.Domain>
function TheEncounter.POOL.get_domains_pool(args, duplicates_list) end

--- @param args? { options?: table<TheEncounter.Domain>, ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean, allow_repeats?: boolean, ignore_rarity?: boolean, rarity?: string | number, without_fallback?: boolean, increment_usage?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return string | nil, boolean
function TheEncounter.POOL.poll_domain(args, duplicates_list) end

--- @param amount number
--- @param args? { options?: table<TheEncounter.Domain>, ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean, allow_repeats?: boolean, ignore_rarity?: boolean, rarity?: string | number, without_fallback?: boolean, increment_usage?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return string[]
function TheEncounter.POOL.poll_domains(amount, args, duplicates_list) end

------------------

--- @param domain string | TheEncounter.Domain
--- @return string
function TheEncounter.POOL.get_fallback_scenario(domain) end

--- @param domain string | TheEncounter.Domain
--- @return table<string, number>
function TheEncounter.POOL.get_scenarios_usage(domain) end

--- @param scenario string | TheEncounter.Scenario
--- @param domain string | TheEncounter.Domain
function TheEncounter.POOL.increment_scenario_usage(scenario, domain) end

--- @param scenario string | TheEncounter.Scenario
--- @param domain string | TheEncounter.Domain
--- @param args? { ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return boolean, table?
function TheEncounter.POOL.is_scenario_in_pool(scenario, domain, args, duplicates_list) end

--- @param domain string | TheEncounter.Domain
--- @param args? { options?: table<TheEncounter.Scenario>, ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean, allow_repeats?: boolean, without_fallback?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return table<TheEncounter.Domain>
function TheEncounter.POOL.get_scenarios_pool(domain, args, duplicates_list) end

--- @param domain string | TheEncounter.Domain
--- @param args? { options?: table<TheEncounter.Scenario>, ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean, allow_repeats?: boolean, without_fallback?: boolean, increment_usage?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return string | nil, boolean
function TheEncounter.POOL.poll_scenario(domain, args, duplicates_list) end

--- @param domain string | TheEncounter.Domain
--- @param amount number
--- @param args? { options?: table<TheEncounter.Scenario>, ignore_everything?: boolean, ignore_in_pool?: boolean, ignore_once_per_run?: boolean, ignore_unique?: boolean, allow_repeats?: boolean, without_fallback?: boolean, increment_usage?: boolean }
--- @param duplicates_list? table<string, boolean>
--- @return string[]
function TheEncounter.POOL.poll_scenarios(domain, amount, args, duplicates_list) end
