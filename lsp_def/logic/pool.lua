--- @meta

TheEncounter.POOL = {}

------------------

--- @class TheEncounter.Pool.PoolRarityArgs: TheEncounter.Pool.GetDomainsPoolArgs
--- @field domains_in_pool? table<TheEncounter.Domain>
--- @field without_fallback? boolean

------------------

--- @return string | number
function TheEncounter.POOL.get_fallback_rarity() end

--- @param args? TheEncounter.Pool.PoolRarityArgs
--- @return string | number | SMODS.Rarity | nil, boolean
function TheEncounter.POOL.poll_rarity(args) end

------------------

--- @alias TheEncounter.Pool.DomainDuplicatesList table<string, boolean>

--- @class TheEncounter.Pool.IsDomainInPoolArgs: table
--- @field ignore_everything? boolean
--- @field ignore_in_pool? boolean
--- @field ignore_once_per_run? boolean
--- @field ignore_unique? boolean

--- @class TheEncounter.Pool.GetDomainsPoolArgs: TheEncounter.Pool.IsDomainInPoolArgs
--- @field rarity? number | string | SMODS.Rarity
--- @field allow_repeats? boolean
--- @field ignore_rarity? boolean
--- @field options? table<string | number, TheEncounter.DomainResolvable>
--- @field soulable? boolean

--- @class TheEncounter.Pool.PoolDomainArgs: TheEncounter.Pool.GetDomainsPoolArgs
--- @field increment_usage? boolean
--- @field without_fallback? boolean

------------------

--- @return string
function TheEncounter.POOL.get_fallback_domain() end

--- @return table<string, number>
function TheEncounter.POOL.get_domains_usage() end

--- @param domain TheEncounter.DomainResolvable
function TheEncounter.POOL.increment_domain_usage(domain) end

--- @param domain TheEncounter.DomainResolvable
--- @param args? TheEncounter.Pool.IsDomainInPoolArgs
--- @param duplicates_list? TheEncounter.Pool.DomainDuplicatesList
--- @return boolean, table?
function TheEncounter.POOL.is_domain_in_pool(domain, args, duplicates_list) end

--- @param args? TheEncounter.Pool.GetDomainsPoolArgs
--- @param duplicates_list? TheEncounter.Pool.DomainDuplicatesList
--- @return table<TheEncounter.Domain>, table<TheEncounter.Domain>
function TheEncounter.POOL.get_domains_pool(args, duplicates_list) end

--- @param args? TheEncounter.Pool.PoolDomainArgs
--- @param duplicates_list? TheEncounter.Pool.DomainDuplicatesList
--- @return string | nil, boolean
function TheEncounter.POOL.poll_domain(args, duplicates_list) end

--- @param amount number
--- @param args? TheEncounter.Pool.PoolDomainArgs
--- @param duplicates_list? TheEncounter.Pool.DomainDuplicatesList
--- @return string[]
function TheEncounter.POOL.poll_domains(amount, args, duplicates_list) end

------------------

--- @alias TheEncounter.Pool.ScenarioDuplicatesList table<string, boolean>

--- @class TheEncounter.Pool.IsScenarioInPoolArgs: table
--- @field ignore_everything? boolean
--- @field ignore_in_pool? boolean
--- @field ignore_once_per_run? boolean
--- @field ignore_unique? boolean

--- @class TheEncounter.Pool.GetScenariosPoolArgs: TheEncounter.Pool.IsScenarioInPoolArgs
--- @field rarity? number | string | SMODS.Rarity
--- @field allow_repeats? boolean
--- @field ignore_domain? boolean
--- @field options? table<string | number, TheEncounter.ScenarioResolvable>
--- @field soulable? boolean

--- @class TheEncounter.Pool.PoolScenarioArgs: TheEncounter.Pool.GetScenariosPoolArgs
--- @field increment_usage? boolean
--- @field without_fallback? boolean

------------------

--- @param domain? TheEncounter.DomainResolvable
--- @return string
function TheEncounter.POOL.get_fallback_scenario(domain) end

--- @param domain TheEncounter.DomainResolvable
--- @return table<string, number>
function TheEncounter.POOL.get_scenarios_usage(domain) end

--- @param scenario TheEncounter.ScenarioResolvable
--- @param domain TheEncounter.DomainResolvable
function TheEncounter.POOL.increment_scenario_usage(scenario, domain) end

--- @param domain TheEncounter.DomainResolvable
--- @param scenario TheEncounter.ScenarioResolvable
--- @param args? TheEncounter.Pool.IsScenarioInPoolArgs
--- @param duplicates_list? TheEncounter.Pool.ScenarioDuplicatesList
--- @return boolean, table?
function TheEncounter.POOL.is_scenario_in_pool(domain, scenario, args, duplicates_list) end

--- @param domain TheEncounter.DomainResolvable
--- @param args? TheEncounter.Pool.GetScenariosPoolArgs
--- @param duplicates_list?TheEncounter.Pool.ScenarioDuplicatesList
--- @return table<TheEncounter.Scenario>, table<TheEncounter.Scenario>
function TheEncounter.POOL.get_scenarios_pool(domain, args, duplicates_list) end

--- @param domain TheEncounter.DomainResolvable
--- @param args? TheEncounter.Pool.PoolScenarioArgs
--- @param duplicates_list? TheEncounter.Pool.ScenarioDuplicatesList
--- @return string | nil, boolean
function TheEncounter.POOL.poll_scenario(domain, args, duplicates_list) end

--- @param domain TheEncounter.DomainResolvable
--- @param amount number
--- @param args? TheEncounter.Pool.PoolScenarioArgs
--- @param duplicates_list? TheEncounter.Pool.ScenarioDuplicatesList
--- @return string[]
function TheEncounter.POOL.poll_scenarios(domain, amount, args, duplicates_list) end
