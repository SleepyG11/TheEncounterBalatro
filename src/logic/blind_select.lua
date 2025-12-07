G.STATES.ENC_EVENT_SELECT = 292719887369

function Game:update_enc_event_select(dt)
	if self.buttons then
		self.buttons:remove()
		self.buttons = nil
	end
	if self.shop then
		self.shop:remove()
		self.shop = nil
	end

	-- failsafe in case of removing all choices to prevent softlock
	if G.STATE_COMPLETE and G.GAME.TheEncounter_choices and #G.GAME.TheEncounter_choices == 0 then
		G.GAME.TheEncounter_choices = nil
		stop_use()
		TheEncounter.UI.remove_event_choices()
		TheEncounter.UI.remove_prompt_box()
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			func = function()
				G.RESET_JIGGLES = nil
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						G.E_MANAGER:add_event(Event({
							trigger = "immediate",
							func = function()
								G.STATE = G.GAME.TheEncounter_replaced_state
								G.GAME.TheEncounter_replaced_state = nil
								G.GAME.TheEncounter_after = nil
								G.STATE_COMPLETE = false
								return true
							end,
						}))
						return true
					end,
				}))
				return true
			end,
		}))
	end
	if not G.STATE_COMPLETE then
		stop_use()
		ease_background_colour_blind(G.STATES.BLIND_SELECT)

		G.GAME.TheEncounter_choices = G.GAME.TheEncounter_choices or TheEncounter.poll_choices() or {}
		if #G.GAME.TheEncounter_choices == 0 then
			G.GAME.TheEncounter_choices = {
				{
					domain_key = "do_enc_occurrence",
					scenario_key = "sc_enc_nothing",
				},
			}
		end

		G.TheEncounter_blind_choices = UIBox(TheEncounter.UI.event_choices_render(G.GAME.TheEncounter_choices))
		G.TheEncounter_prompt_box = UIBox(TheEncounter.UI.prompt_box_render())

		G.E_MANAGER:add_event(Event({
			func = function()
				save_run()
				return true
			end,
		}))
		G.STATE_COMPLETE = true
		G.CONTROLLER.interrupt.focus = true
		G.E_MANAGER:add_event(Event({
			func = function()
				G.E_MANAGER:add_event(Event({
					trigger = "immediate",
					func = function()
						play_sound("cancel")
						TheEncounter.UI.set_event_choices()
						TheEncounter.UI.set_prompt_box()
						G.CONTROLLER.lock_input = false
						return true
					end,
				}))
				return true
			end,
		}))
	end
end

local old_draw = CardArea.draw
function CardArea:draw(...)
	if
		(
			G.STATE == G.STATES.ENC_EVENT_SELECT
			or G.TAROT_INTERRUPT == G.STATES.ENC_EVENT_SELECT
			or G.PACK_INTERRUPT == G.STATES.ENC_EVENT_SELECT
		) and self == G.hand
	then
		return
	end
	return old_draw(self, ...)
end

TheEncounter.poll_choices = function()
	local duplicates_list = {}
	for _, item in ipairs(G.GAME.TheEncounter_choices or {}) do
		if item.scenario_key then
			duplicates_list[item.scenario_key] = true
		end
		duplicates_list[item.domain_key] = true
	end

	local effects = {}
	SMODS.calculate_context(
		{ enc_poll_choices = true, duplicates_list = duplicates_list, after = G.GAME.TheEncounter_after },
		effects
	)

	local context_result = {
		initial_choices = {},
		additional_choices = {},
		amount = 0,
		amount_mod = 0,
	}
	for _, v in ipairs(effects) do
		for _, effect in pairs(v) do
			context_result.set_choices = effect.set_choices or context_result.set_choices
			if effect.initial_choices then
				context_result.initial_choices =
					TheEncounter.table.concat(context_result.initial_choices, effect.initial_choices)
			end
			context_result.amount = math.max(context_result.amount, effect.amount or 0)
			context_result.amount_mod = context_result.amount_mod + (effect.amount_mod or 0)
			if effect.domain_options then
				context_result.domain_options =
					TheEncounter.table.concat(context_result.domain_options or {}, effect.domain_options)
			end
			context_result.allow_repeats = context_result.allow_repeats or effect.allow_repeats
			context_result.no_soulable = context_result.no_soulable or effect.no_soulable
			context_result.rarity = effect.rarity or context_result.rarity
			context_result.ignore_unique = context_result.ignore_unique or effect.ignore_unique
			context_result.ignore_once_per_run = context_result.ignore_once_per_run or effect.ignore_once_per_run
			context_result.ignore_rarity = context_result.ignore_rarity or effect.ignore_rarity
			if effect.additional_choices then
				context_result.additional_choices =
					TheEncounter.table.concat(context_result.additional_choices, effect.additional_choices)
			end
		end
	end

	if context_result.set_choices then
		return context_result.set_choices
	end

	local result = {}
	for _, choice in ipairs(context_result.initial_choices or {}) do
		table.insert(result, choice)
	end

	local amount = math.max(0, context_result.amount + context_result.amount_mod - #result)
	local poll_result = TheEncounter.POOL.poll_domains(amount, {
		increment_usage = true,
		without_fallback = false,

		options = context_result.domain_options,
		allow_repeats = context_result.allow_repeats,
		soulable = not context_result.no_soulable,
		rarity = context_result.rarity,
		ignore_unique = context_result.ignore_unique,
		ignore_once_per_run = context_result.ignore_once_per_run,
		ignore_rarity = context_result.ignore_rarity,
	}, duplicates_list)

	for _, choice in ipairs(context_result.additional_choices or {}) do
		table.insert(result, choice)
	end

	for _, item in ipairs(poll_result) do
		table.insert(result, {
			domain_key = item,
		})
	end

	return result
end
TheEncounter.select_scenario = function(domain)
	local effects = {}
	SMODS.calculate_context({ enc_select_scenario = true, domain = domain }, effects)

	local context_result = {}

	for _, v in ipairs(effects) do
		for _, effect in pairs(v) do
			context_result.scenario_key = effect.scenario_key or context_result.scenario_key
			if effect.scenario_options then
				context_result.scenario_options =
					TheEncounter.table.concat(context_result.scenario_options or {}, effect.scenario_options)
			end
			context_result.allow_repeats = context_result.allow_repeats or effect.allow_repeats
			context_result.no_soulable = context_result.no_soulable or effect.no_soulable
			context_result.ignore_once_per_run = context_result.ignore_once_per_run or effect.ignore_once_per_run
			context_result.ignore_unique = context_result.ignore_unique or effect.ignore_unique
		end
	end

	if context_result.scenario_key then
		return context_result.scenario_key
	end
	return TheEncounter.POOL.poll_scenario(domain, {
		increment_usage = true,
		without_fallback = false,

		options = context_result.scenario_options,
		allow_repeats = context_result.allow_repeats,
		soulable = not context_result.no_soulable,
		ignore_once_per_run = context_result.ignore_once_per_run,
		ignore_unique = context_result.ignore_unique,
	})
end
TheEncounter.select_choice = function(scenario, domain)
	domain = TheEncounter.Domain.resolve(domain)
	if not scenario then
		scenario = TheEncounter.select_scenario(domain)
	end
	scenario = TheEncounter.Scenario.resolve(scenario)

	return {
		domain_key = domain.key,
		scenario_key = scenario.key,
	}
end
TheEncounter.should_encounter = function(args)
	args = args or {}
	local effects = {}
	SMODS.calculate_context({ enc_check_should_encounter = true, after = args.after }, effects)

	local context_result = {}
	for _, v in ipairs(effects) do
		for _, effect in pairs(v) do
			context_result.should_encounter = context_result.should_encounter or effect.should_encounter
			if effect.blinds then
				context_result.blinds =
					TheEncounter.table.shallow_merge(context_result.blinds or {}, context_result.blinds)
			end
		end
	end

	if context_result.should_encounter ~= nil then
		return context_result.should_encounter or false
	else
		-- TODO: support for modded small/big blinds? how?
		if args.after == "shop" or args.after == "cashout" then
			local type = args.blind_type or G.GAME.blind_on_deck or "Boss"
			if args.blind == "bl_small" then
				type = "Small"
			elseif args.blind == "bl_big" then
				type = "Big"
			end

			local table_to_check = context_result.blinds
				or (args.after == "shop" and G.GAME.TheEncounter_after_shop_encounter)
				or (args.after == "cashout" and G.GAME.TheEncounter_after_cashout_encounter)
				or {}
			if table_to_check[type] then
				return true
			end
		end
	end
	return false
end
TheEncounter.replace_choice = function(index, choice)
	if G.GAME.TheEncounter_choices then
		if not choice then
			table.remove(G.GAME.TheEncounter_choices, index)
		else
			G.GAME.TheEncounter_choices[index] = choice
		end
		TheEncounter.UI.event_replace_choice(index, choice)
	else
		-- TODO: decide what to do in this case
	end
end
TheEncounter.replace_all_choices = function(choices, with_prompt)
	G.GAME.TheEncounter_choices = choices
	TheEncounter.UI.event_replace_all_choices(with_prompt)
end
