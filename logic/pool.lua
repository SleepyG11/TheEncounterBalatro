TheEncounter.POOL = {}

local vanilla_rarities = {
	[1] = "Common",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Legendary",
}
local vanilla_reverse_rarities = {
	["Common"] = 1,
	["Uncommon"] = 2,
	["Rare"] = 3,
	["Legendary"] = 4,
}

-- Rarity pool
TheEncounter.POOL.get_fallback_rarity = function()
	return 1
end

TheEncounter.POOL.poll_rarity = function(args)
	args = args or {}
	local possible_rarities = {}

	-- Collect all rarities
	local all_domains = args.domains_in_pool or TheEncounter.Domains
	for _, domain in pairs(all_domains) do
		possible_rarities[vanilla_rarities[domain.rarity] or domain.rarity] = true
	end

	local available_rarities = {}
	for key, rarity in pairs(SMODS.Rarities) do
		table.insert(available_rarities, {
			key = key,
			weight = rarity.default_weight,
		})
	end
	local filtered_rarities = {}

	-- Calculate total rates of rarities
	local total_weight = 0
	for _, v in ipairs(available_rarities) do
		if possible_rarities[v.key] then
			v.mod = G.GAME["enc_" .. tostring(v.key):lower() .. "_mod"] or 1
			-- Should this fully override the v.weight calcs?
			if
				SMODS.Rarities[v.key]
				and SMODS.Rarities[v.key].get_weight
				and type(SMODS.Rarities[v.key].get_weight) == "function"
			then
				v.weight = SMODS.Rarities[v.key]:get_weight(v.weight, SMODS.ObjectTypes["enc_Domain"])
			end
			v.weight = v.weight * v.mod
			total_weight = total_weight + v.weight
			table.insert(filtered_rarities, v)
		end
	end
	-- recalculate rarities to account for v.mod
	for _, v in ipairs(filtered_rarities) do
		v.weight = v.weight / total_weight
	end

	-- GAMBLING!
	local rarity_poll = pseudorandom(args.seed or ("enc_rarity" .. G.GAME.round_resets.ante))

	-- Calculate selected rarity
	local weight_i = 0
	for _, v in ipairs(filtered_rarities) do
		weight_i = weight_i + v.weight
		if rarity_poll < weight_i then
			return vanilla_reverse_rarities[v.key] or v.key
		end
	end
	if args.will_fallback then
		return TheEncounter.POOL.get_fallback_rarity(), true
	end
	return nil, true
end

-- Domains pool
TheEncounter.POOL.get_fallback_domain = function()
	return "do_enc_occurrence"
end

TheEncounter.POOL.get_domains_usage = function()
	return G.GAME.enc_encountered_domains or {}
end
TheEncounter.POOL.increment_domain_usage = function(domain)
	domain = TheEncounter.Domain.resolve(domain)
	if domain then
		local key = domain.key
		if not G.GAME.enc_encountered_domains then
			G.GAME.enc_encountered_domains = {}
		end
		if not G.GAME.enc_encountered_domains[key] then
			G.GAME.enc_encountered_domains[key] = 1
		else
			G.GAME.enc_encountered_domains[key] = G.GAME.enc_encountered_domains[key] + 1
		end
	end
end

TheEncounter.POOL.is_domain_in_pool = function(domain, args, duplicates_list)
	args = args or {}
	duplicates_list = duplicates_list or {}
	domain = TheEncounter.Domain.resolve(domain)
	if not domain then
		return false
	end

	-- Execute domain:in_pool()
	local add, pool_opts = true, {}
	if type(domain.in_pool) == "function" then
		add, pool_opts = domain:in_pool(args)
		pool_opts = pool_opts or {}
	end

	-- Universal bypass
	if args.ignore_everything or pool_opts.ignore_everything then
		return true, pool_opts
	end

	-- In pool check + bypass
	if not args.ignore_in_pool and not add then
		return false, pool_opts
	end

	-- Once per run check + bypass
	if
		domain.once_per_run
		and not args.ignore_once_per_run
		and not pool_opts.ignore_once_per_run
		and TheEncounter.POOL.get_domains_usage()[domain.key] > 0
	then
		return false, pool_opts
	end

	-- Check is this domain in duplicate_list + bypass
	if not (domain.ignore_unique or args.ignore_unique or pool_opts.ignore_unique) then
		if duplicates_list[domain.key] then
			return false, pool_opts
		end
	end

	return true, pool_opts
end
TheEncounter.POOL.get_domains_pool = function(args, duplicates_list)
	args = args or {}
	local options = args.options or TheEncounter.Domains
	-- Make a blacklist dictionary
	local duplicates_pool = TheEncounter.table.to_keys_dictionary(duplicates_list or {})
	local temp_pool = {}

	local encounters_table = TheEncounter.POOL.get_domains_usage()

	for _, domain in pairs(options) do
		-- So, we check is domain is already present in initial_pool
		-- Then, we add domain which passed a check to both result_pool and pool which we use for deduping
		local in_pool, pool_opts = args.ignore_everything, nil
		if not in_pool then
			in_pool, pool_opts = TheEncounter.POOL.is_domain_in_pool(domain, args, duplicates_pool)
		end
		if in_pool then
			local d = TheEncounter.Domain.resolve(domain)
			duplicates_pool[d.key] = true
			table.insert(temp_pool, {
				key = d.key,
				value = d,
				opts = pool_opts or {},
				count = encounters_table[d.key] or 0,
			})
		end
	end

	local rarity_pool = {}
	-- Check is polled item in rarity poll
	if args.ignore_everything or args.ignore_rarity then
		rarity_pool = temp_pool
	else
		local items_in_pool = {}
		for _, v in ipairs(temp_pool) do
			table.insert(items_in_pool, v.value)
		end
		local rarity = TheEncounter.POOL.poll_rarity({
			domains_in_pool = items_in_pool,
			with_fallback = args.with_fallback,
		})
		for _, item in ipairs(temp_pool) do
			if item.opts.ignore_rarity or (rarity and item.value.rarity == rarity) then
				table.insert(rarity_pool, item)
			end
		end
	end

	local is_filled = false
	local result_pool = {}

	-- Now we have list of domains in pool, now we're doing a loop like in vanilla for blinds
	if not args.allow_repeats and not args.ignore_everything then
		-- Count minimal encounters amount
		local min_value, max_value = math.huge, 0
		for _, item in ipairs(rarity_pool) do
			if not (item.value.can_repeat or item.opts.can_repeat) then
				max_value = math.max(max_value, item.count)
				min_value = math.min(min_value, item.count)
			end
		end

		if max_value > min_value then
			-- Add only which are less than minimal value
			for _, item in ipairs(rarity_pool) do
				if item.value.can_repeat or item.opts.can_repeat or item.count < max_value then
					table.insert(result_pool, item.value)
				end
			end
			is_filled = true
		end
	end

	if not is_filled then
		for _, item in ipairs(rarity_pool) do
			table.insert(result_pool, item.value)
		end
	end

	return result_pool
end
TheEncounter.POOL.poll_domain = function(args, duplicates_list)
	args = args or {}

	local options = TheEncounter.POOL.get_domains_pool(args, duplicates_list)

	local pullable = {}
	local total_weight = 0
	for _, domain in ipairs(options) do
		local weight = type(domain.get_weight) == "function" and domain:get_weight(domain.default_weight or 5)
			or (domain.default_weight or 5)
		total_weight = total_weight + weight
		table.insert(pullable, {
			weight = weight,
			key = domain.key,
		})
	end

	if #pullable == 0 then
		local fallback = args.with_fallback and TheEncounter.POOL.get_fallback_domain() or nil
		return fallback, true
	else
		-- GAMBLING!
		local domain_poll = pseudorandom(args.seed or ("enc_domain" .. G.GAME.round_resets.ante))

		local weight_i = 0
		for _, item in ipairs(pullable) do
			weight_i = weight_i + item.weight
			if domain_poll > 1 - (weight_i / total_weight) then
				if args.increment_usage then
					TheEncounter.POOL.increment_domain_usage(item.key)
				end
				return item.key
			end
		end
	end
end
TheEncounter.POOL.poll_domains = function(amount, args, duplicates_list)
	amount = amount or 1
	args = args or {}
	local result = {}
	local duplicates_pool = TheEncounter.table.to_keys_dictionary(duplicates_list or {})
	for i = 1, amount do
		local domain_key, is_fallback = TheEncounter.POOL.poll_domain(args, duplicates_pool)
		if domain_key and (not is_fallback or #result == 0) then
			table.insert(result, domain_key)
			duplicates_pool[domain_key] = true
		end
		if is_fallback then
			break
		end
	end
	return result
end

-- Scenarios pool
TheEncounter.POOL.get_fallback_scenario = function(domain)
	return "sc_enc_nothing"
end

TheEncounter.POOL.get_scenarios_usage = function(domain)
	return G.GAME.enc_encountered_scenarios or {}
end
TheEncounter.POOL.increment_scenario_usage = function(scenario, domain)
	scenario = TheEncounter.Scenario.resolve(scenario)
	if scenario then
		local key = scenario.key
		if not G.GAME.enc_encountered_scenarios then
			G.GAME.enc_encountered_scenarios = {}
		end
		if not G.GAME.enc_encountered_scenarios[key] then
			G.GAME.enc_encountered_scenarios[key] = 1
		else
			G.GAME.enc_encountered_scenarios[key] = G.GAME.enc_encountered_scenarios[key] + 1
		end
	end
end

TheEncounter.POOL.is_scenario_in_pool = function(scenario, domain, args, duplicates_list)
	args = args or {}
	duplicates_list = duplicates_list or {}
	domain = TheEncounter.Domain.resolve(domain)
	scenario = TheEncounter.Scenario.resolve(scenario)
	if not scenario or not domain then
		return false
	end

	-- Execute scenario:in_pool()
	local add, pool_opts = true, {}
	if type(scenario.in_pool) == "function" then
		add, pool_opts = scenario:in_pool(args, domain)
		pool_opts = pool_opts or {}
	end

	-- Universal bypass
	if args.ignore_everything or pool_opts.ignore_everything then
		return true, pool_opts
	end

	-- In pool check + bypass
	if not args.ignore_in_pool and not add then
		return false, pool_opts
	end

	-- Once per run check + bypass
	if
		scenario.once_per_run
		and not args.ignore_once_per_run
		and not pool_opts.ignore_once_per_run
		and TheEncounter.POOL.get_scenarios_usage(domain)[scenario.key] > 0
	then
		return false, pool_opts
	end

	-- Check is this scenario in duplicate_list + bypass
	if not (scenario.ignore_unique or args.ignore_unique or pool_opts.ignore_unique) then
		if duplicates_list[scenario.key] then
			return false, pool_opts
		end
	end

	return true, pool_opts
end
TheEncounter.POOL.get_scenarios_pool = function(domain, args, duplicates_list)
	domain = TheEncounter.Domain.resolve(domain)
	args = args or {}
	if not domain then
		return {}
	end

	-- Filter scenarios by domain passed
	local all_options = args.options or TheEncounter.Scenarios
	local options = {}
	if args.ignore_domain then
		options = TheEncounter.table.shallow_copy(all_options)
	else
		for _, scenario in pairs(all_options) do
			scenario = TheEncounter.Scenario.resolve(scenario)
			if scenario.domains[domain.key] then
				table.insert(options, scenario)
			end
		end
	end

	-- Make a blacklist dictionary
	local duplicates_pool = TheEncounter.table.to_keys_dictionary(duplicates_list or {})
	local temp_pool = {}

	local encounters_table = TheEncounter.POOL.get_scenarios_usage(domain)

	for _, scenario in pairs(options) do
		-- So, we check is scenario is already present in initial_pool
		-- Then, we add scenario which passed a check to both result_pool and pool which we use for deduping
		local in_pool, pool_opts = args.ignore_everything, nil
		if not in_pool then
			in_pool, pool_opts = TheEncounter.POOL.is_scenario_in_pool(scenario, domain, args, duplicates_pool)
		end
		if in_pool then
			local s = TheEncounter.Scenario.resolve(scenario)
			duplicates_pool[s.key] = true
			table.insert(temp_pool, {
				key = s.key,
				value = s,
				opts = pool_opts or {},
				count = encounters_table[s.key] or 0,
			})
		end
	end

	local result_pool = {}
	local is_filled = false

	-- Now we have list of scenarios in pool, now we're doing a loop like in vanilla for blinds
	if not args.allow_repeats and not args.ignore_everything then
		-- Count minimal encounters amount
		local min_value, max_value = math.huge, 0
		for _, item in ipairs(temp_pool) do
			if not (item.value.allow_repeats or item.opts.can_repeat or item.opts.allow_repeats) then
				max_value = math.max(max_value, item.count)
				min_value = math.min(min_value, item.count)
			end
		end

		if max_value > min_value then
			-- Add only which are less than minimal value
			for _, item in ipairs(temp_pool) do
				if item.value.allow_repeats or item.opts.can_repeat or item.count < max_value then
					table.insert(result_pool, item.value)
				end
			end
			is_filled = true
		end
	end

	if not is_filled then
		for _, item in ipairs(temp_pool) do
			table.insert(result_pool, item.value)
		end
	end

	return result_pool
end
TheEncounter.POOL.poll_scenario = function(domain, args, duplicates_list)
	args = args or {}

	local options = TheEncounter.POOL.get_scenarios_pool(domain, args, duplicates_list)

	local pullable = {}
	local total_weight = 0
	for _, scenario in ipairs(options) do
		local weight = type(scenario.get_weight) == "function"
				and scenario:get_weight(scenario.default_weight or 5, domain)
			or (scenario.default_weight or 5)
		total_weight = total_weight + weight
		table.insert(pullable, {
			weight = weight,
			key = scenario.key,
		})
	end

	if #pullable == 0 then
		local fallback = args.with_fallback and TheEncounter.POOL.get_fallback_scenario(domain) or nil
		return fallback, true
	else
		-- GAMBLING!
		local scenario_poll = pseudorandom(args.seed or ("enc_scenario" .. G.GAME.round_resets.ante))

		local weight_i = 0
		for _, item in ipairs(pullable) do
			weight_i = weight_i + item.weight
			if scenario_poll > 1 - (weight_i / total_weight) then
				if args.increment_usage then
					TheEncounter.POOL.increment_scenario_usage(item.key, domain)
				end
				return item.key
			end
		end
	end
end
TheEncounter.POOL.poll_scenarios = function(domain, amount, args, duplicates_list)
	amount = amount or 1
	args = args or {}
	local result = {}
	local duplicates_pool = TheEncounter.table.to_keys_dictionary(duplicates_list or {})
	for i = 1, amount do
		local scenario_key, is_fallback = TheEncounter.POOL.poll_scenario(domain, args, duplicates_pool)
		if scenario_key and (not is_fallback or #result == 0) then
			table.insert(result, scenario_key)
			duplicates_pool[scenario_key] = true
		end
		if is_fallback then
			break
		end
	end
	return result
end
