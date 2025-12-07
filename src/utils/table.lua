TheEncounter.table = {}

-- Checks is `t[v]` present, or is `v` present in array `t`
function TheEncounter.table.contains_key(t, v)
	if t == nil or v == nil or type(t) ~= "table" then
		return false
	end
	if t[v] then
		return true
	end
	if #t == 0 then
		return false
	end
	for _k, _v in ipairs(t) do
		if _v == v then
			return true
		end
	end
	return false
end

-- Checks is any value in `t` is `v`
function TheEncounter.table.contains_value(t, v)
	if t == nil or v == nil or type(t) ~= "table" then
		return false
	end
	for _k, _v in pairs(t) do
		if _v == v then
			return true
		end
	end
	return false
end

function TheEncounter.table.array_contains_value(t, v)
	if t == nil or v == nil or type(t) ~= "table" or #t == 0 then
		return false
	end
	for _k, _v in ipairs(t) do
		if _v == v then
			return true
		end
	end
	return false
end

function TheEncounter.table.shallow_copy(t)
	local res = {}
	if not t or type(t) ~= "table" then
		return res
	end
	for k, v in pairs(t) do
		res[k] = v
	end
	return res
end

function TheEncounter.table.slice(t, start, stop)
	local res = {}

	local len = #t
	start = start or 0
	stop = (stop ~= nil) and stop or len

	if start < 0 then
		start = len + start
	else
		start = start + 1
	end
	if stop < 0 then
		stop = len + stop
	end

	if start < 1 then
		start = 1
	end
	if stop > len then
		stop = len
	end

	for i = start, stop do
		res[#res + 1] = t[i]
	end

	return res
end

function TheEncounter.table.to_keys_dictionary(t)
	local res = {}
	if not t or type(t) ~= "table" then
		return res
	end
	for k, v in pairs(t) do
		local kt, vt = type(k), type(v)
		if kt == "number" then
			if vt == "table" and v.key then
				res[v.key] = true
			elseif vt == "string" then
				res[v] = true
			end
		elseif kt == "string" then
			res[k] = true
		end
	end
	return res
end

--- @generic T
--- @generic S
--- @param target T
--- @param source S
--- @param ... any
--- @return T | S
function TheEncounter.table.merge(target, source, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { source, ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			if type(v) == "table" then
				target[k] = target[k] or {}
				target[k] = TheEncounter.table.merge(target[k], v)
			else
				target[k] = v
			end
		end
	end

	return target
end

--- @generic T
--- @generic S
--- @param target T
--- @param source S
--- @param ... any
--- @return T | S
function TheEncounter.table.shallow_merge(target, source, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { source, ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			target[k] = v
		end
	end

	return target
end

function TheEncounter.table.concat(t1, t2)
	local result = TheEncounter.table.shallow_copy(t1)
	for k, v in ipairs(t2) do
		result[#result + 1] = v
	end
	return result
end

function TheEncounter.table.first_not_nil(...)
	local args = { ... }
	for _, value in pairs(args) do
		if value ~= nil then
			return value
		end
	end
	return nil
end
