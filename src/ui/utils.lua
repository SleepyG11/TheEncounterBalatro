TheEncounter.UI.get_badges = function(scenario, domain, args, badges)
	domain = TheEncounter.Domain.resolve(domain)
	scenario = TheEncounter.Scenario.resolve(scenario)
	args = args or {}

	badges = badges or {}
	if scenario then
		scenario:set_badges(badges, domain)
	end
	domain:set_badges(badges)
	if not args.no_rarity then
		badges[#badges + 1] =
			create_badge(SMODS.Rarity:get_rarity_badge(domain.rarity), G.C.RARITY[domain.rarity], nil, 1.2)
	end
	if
		not args.no_mod
		or (scenario and (args.bypass_discovery_check or not scenario.discoverable or scenario.discovered))
	then
		SMODS.create_mod_badges(scenario or domain, badges)
		badges.mod_set = nil
	end
	return badges
end

TheEncounter.UI.set_element_object = function(container, object, no_remove)
	if container then
		if not no_remove then
			container.config.object:remove()
		end
		container.config.object = object
		if object then
			object.config.parent = container
		else
			container.config.object = Moveable()
		end
		container.UIBox:recalculate()
	end
end

TheEncounter.UI.get_colours = function(object, ...)
	if not object then
		return {}
	end
	local res = object.get_colours and type(object.get_colours) == "function" and object:get_colours(...) or {}
	return {
		colour = res.colour or object.colour,
		text_colour = res.text_colour or object.text_colour,
		background_colour = res.background_colour or object.background_colour,
		inactive_colour = res.inactive_colour or object.inactive_colour,
	}
end
