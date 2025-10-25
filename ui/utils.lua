TheEncounter.UI.get_badges = function(scenario, domain, args, badges)
	domain = TheEncounter.Domain.resolve(domain)
	scenario = TheEncounter.Scenario.resolve(scenario)
	args = args or {}

	badges = badges or {}
	if scenario then
		scenario:set_badges(domain, badges)
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

TheEncounter.UI.set_element_object = function(container, object)
	if container then
		container.config.object:remove()
		container.config.object = object
		if object then
			object.config.parent = container
		else
			container.config.object = Moveable()
		end
		container.UIBox:recalculate()
	end
end
