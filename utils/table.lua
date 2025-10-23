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
