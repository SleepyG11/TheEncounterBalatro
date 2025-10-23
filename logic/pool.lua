TheEncounter.POOL = {}

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
		and (G.GAME.enc_encountered_domains or {})[domain.key] > 0
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

	local encounters_table = G.GAME.enc_encountered_domains or {}

	for _, domain in pairs(options) do
		-- So, we check is domain is already present in initial_pool
		-- Then, we add domain which passed a check to both result_pool and pool which we use for deduping
		local in_pool, pool_opts = TheEncounter.POOL.is_domain_in_pool(domain, args, duplicates_pool)
		if in_pool then
			local d = TheEncounter.Domain.resolve(domain)
			duplicates_pool[d.key] = true
			table.insert(temp_pool, {
				key = d.key,
				domain = d,
				opts = pool_opts,
				count = encounters_table[d.key] or 0,
			})
		end
	end

	local result_pool = {}
	local is_filled = false

	-- Now we have list of domains in pool, now we're doing a loop like in vanilla for blinds
	if not args.allow_duplicates then
		-- Count minimal encounters amount
		local min_value, max_value = math.huge, 0
		for _, item in ipairs(temp_pool) do
			if not (item.domain.allow_duplicates or item.opts.allow_duplicates) then
				max_value = math.max(max_value, item.count)
				min_value = math.min(min_value, item.count)
			end
		end

		if max_value > min_value then
			-- Add only which are less than minimal value
			for _, item in ipairs(temp_pool) do
				if item.domain.allow_duplicates or item.opts.allow_duplicates or item.count < max_value then
					table.insert(result_pool, item.domain)
				end
			end
			is_filled = true
		end
	end

	if not is_filled then
		for _, item in ipairs(temp_pool) do
			table.insert(result_pool, item.domain)
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
		local weight = type(domain.get_weight) == "function" and domain:get_weight(args) or domain.weight or 1
		total_weight = total_weight + weight
		table.insert(pullable, {
			weight = weight,
			key = domain.key,
		})
	end

	-- GAMBLING!
	local domain_poll = pseudorandom(args.seed or "enc_domain")

	local weight_i = 0
	for _, item in ipairs(pullable) do
		weight_i = weight_i + item.weight
		if domain_poll > 1 - (weight_i / total_weight) then
			return item.key
		end
	end
end

function TheEncounter.POOL.poll_domains(amount, args, duplicates_list)
	amount = amount or 0
	args = args or {}
	local result = {}
	local duplicates_pool = TheEncounter.table.to_keys_dictionary(duplicates_list or {})
	for i = 1, amount do
		local domain_key = TheEncounter.POOL.poll_domain(args, duplicates_pool)
		if domain_key then
			table.insert(result, domain_key)
			duplicates_pool[domain_key] = true
			if args.increment_usage then
				if not G.GAME.enc_encountered_domains then
					G.GAME.enc_encountered_domains = {}
				end
				if not G.GAME.enc_encountered_domains[domain_key] then
					G.GAME.enc_encountered_domains[domain_key] = 1
				else
					G.GAME.enc_encountered_domains[domain_key] = G.GAME.enc_encountered_domains[domain_key] + 1
				end
			end
		end
	end
	return result
end
