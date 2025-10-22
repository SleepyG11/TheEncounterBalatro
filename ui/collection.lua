TheEncounter.current_mod.custom_collection_tabs = function()
	return {
		UIBox_button({
			button = "your_collection_enc_events",
			id = "your_collection_enc_events",
			label = { "TheEncounter: Events" },
			minw = 5,
			minh = 1,
		}),
	}
end

--

local function collection_domains_list(e)
	local custom_gameobject_tabs = { {} }
	local curr_height = 0
	local curr_col = 1
	local object_tabs = {}
	for _, domain in ipairs(G.P_CENTER_POOLS.enc_Domain) do
		if not domain.no_collection then
			local loc_name = localize({
				type = "name_text",
				key = domain.key,
				set = "enc_Domain",
			})

			object_tabs[#object_tabs + 1] = UIBox_button({
				button = "your_collection_enc_event_domain",
				label = { loc_name },
				minw = 3,
				colour = domain.colour,
				text_colour = domain.text_colour,
				ref_table = domain,
			})
		end
	end
	local custom_gameobject_rows = {}
	if #object_tabs > 0 then
		for _, gameobject_tabs in ipairs(object_tabs) do
			table.insert(custom_gameobject_tabs[curr_col], gameobject_tabs)
			curr_height = curr_height + gameobject_tabs.nodes[1].config.minh
			if curr_height > 2 then
				curr_height = 0
				curr_col = curr_col + 1
				custom_gameobject_tabs[curr_col] = {}
			end
		end
		for _, v in ipairs(custom_gameobject_tabs) do
			table.insert(custom_gameobject_rows, { n = G.UIT.C, config = { align = "cm", padding = 0.15 }, nodes = v })
		end

		local t = {
			n = G.UIT.C,
			config = { align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05 },
			nodes = {
				{ n = G.UIT.R, config = { align = "cm", padding = 0.15 }, nodes = custom_gameobject_rows },
			},
		}

		local ui_cfg = G.ACTIVE_MOD_UI and G.ACTIVE_MOD_UI.ui_config or {}
		return create_UIBox_generic_options({
			colour = ui_cfg.collection_colour or ui_cfg.colour,
			bg_colour = ui_cfg.collection_bg_colour or ui_cfg.bg_colour,
			back_colour = ui_cfg.collection_back_colour or ui_cfg.back_colour,
			outline_colour = ui_cfg.collection_outline_colour or ui_cfg.outline_colour,
			back_func = "your_collection_other_gameobjects",
			contents = { t },
		})
	end
end

local function collection_domain_events_list(e)
	local domain = e.config.ref_table
	local pool = {}

	for _, event in ipairs(G.P_CENTER_POOLS.enc_Scenario) do
		if event.domains and event.domains[domain.key] then
			pool[#pool + 1] = event
		end
	end

	return SMODS.card_collection_UIBox(pool, { 5, 5 }, {
		snap_back = true,
		hide_single_page = true,
		collapse_single_page = true,
		center = "c_base",
		h_mod = 1.18,
		back_func = "your_collection_enc_events",
		infotip = {
			"Events are encountered after the Boss Blind shop",
		},
		modify_card = function(card, scenario)
			local temp_blind = AnimatedSprite(
				card.children.center.T.x,
				card.children.center.T.y,
				1.3,
				1.3,
				G.ANIMATION_ATLAS[scenario.atlas],
				scenario.pos
			)
			temp_blind.states.click.can = false
			temp_blind.states.drag.can = false
			temp_blind.states.hover.can = true
			card.children.center = temp_blind
			temp_blind:set_role({ major = card, role_type = "Glued", draw_major = card })
			card.set_sprites = function(...)
				local args = { ... }
				if not args[1].animation then
					return
				end -- fix for debug unlock
				local c = card.children.center
				Card.set_sprites(...)
				card.children.center = c
			end
			card.T.w = 1.3
			card.T.h = 1.3
			temp_blind:define_draw_steps({
				{ shader = "dissolve", shadow_height = 0.05 },
				{ shader = "dissolve" },
			})
			temp_blind.float = true
			card.enc_scenario = scenario.key
		end,
	})
end

--

G.FUNCS.your_collection_enc_events = function(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu({
		definition = collection_domains_list(e),
	})
end

G.FUNCS.your_collection_enc_event_domain = function(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu({
		definition = collection_domain_events_list(e),
	})
end
