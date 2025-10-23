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
	if not (domain.allow_duplicates or args.allow_duplicates or pool_opts.allow_duplicates) then
		if duplicates_list[domain.key] then
			return false, pool_opts
		end
	end

	return true, pool_opts
end
TheEncounter.POOL.get_domains_pool = function(args)
	args = args or {}
	local options = args.options or TheEncounter.Domains
	-- Make a blacklist dictionary
	local duplicates_pool = TheEncounter.table.to_keys_dictionary(args.initial_pool or {})
	local temp_pool = {}

	local encounters_table = G.GAME.enc_encountered_domains or {}

	for _, domain in ipairs(options) do
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
	local all = function()
		for _, item in ipairs(temp_pool) do
			table.insert(result_pool, item.domain)
		end
	end

	-- Now we have list of domains in pool, now we're doing a loop like in vanilla for blinds
	if not args.ignore_loop then
		-- Count minimal encounters amount
		local min_value = 0
		for _, item in ipairs(temp_pool) do
			if not (item.domain.ignore_loop or item.opts.ignore_loop) then
				if item.count > min_value then
					min_value = item.count
				end
			end
		end

		if min_value > 0 then
			-- Add only which are less than minimal value
			for _, item in ipairs(temp_pool) do
				if not (item.domain.ignore_loop or item.opts.ignore_loop) then
					if item.count < min_value then
						table.insert(result_pool, item.domain)
					end
				end
			end
		else
			all()
		end
	else
		all()
	end

	return result_pool
end
TheEncounter.POOL.poll_domain = function(args)
	args = args or {}

	local options = TheEncounter.POOL.get_domains_pool(args)

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

	return "enc_occurrence"
end
