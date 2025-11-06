--- @meta

--- UIBox definition and config for Domain or Scenario in blind choices list
--- @param index number
--- @param total number
--- @param scenario? TheEncounter.ScenarioResolvable
--- @param domain TheEncounter.DomainResolvable
--- @param start_from_bottom boolean? Should initial position be out of screen (used when event choice is replaced)
--- @return table
function TheEncounter.UI.event_choice_render(index, total, scenario, domain, start_from_bottom) end

--- UIBox definition for Domain or Scenario in blind choices list
--- @param choices { scenario_key?: string, domain_key: string }[]
--- @return table
function TheEncounter.UI.event_choices_render(choices) end

--- Move event choices in visible area
function TheEncounter.UI.set_event_choices() end

--- Hide event choices and remove
function TheEncounter.UI.remove_event_choices() end

--- UIBox definition for prompt box (in vanilla, it's "Select your next blind" text on top left during blind select)
function TheEncounter.UI.prompt_box_render() end

--- Move prompt box in visible area
function TheEncounter.UI.set_prompt_box() end

--- Hide prompt box amd remove
function TheEncounter.UI.remove_prompt_box() end

--- Get various sizes for event UI
--- @param event TheEncounter.Event
function TheEncounter.UI.event_panel_sizes(event) end

--- Main event UI UIBox definition and config
--- @param event TheEncounter.Event
--- @return table
function TheEncounter.UI.event_panel_render(event) end

--- Main event UI image area (black area on right) UIBox definition and config
--- @param event TheEncounter.Event
--- @return table
function TheEncounter.UI.image_area_render(event) end

--- Main event UI hud (blind chip, name, text and reward on top left in main HUD) UIBox definition and config
--- @param event TheEncounter.Event
--- @return table
function TheEncounter.UI.event_hud_render(event) end

--- Even choice button definition
--- @param event TheEncounter.Event
--- @param choice TheEncounter.Choice
--- @param ability table
--- @return table
function TheEncounter.UI.choice_button_UIBox(event, choice, ability) end

--- Creating event main panel, assigning other UI elements and moving result in visible area
--- @param event TheEncounter.Event
function TheEncounter.UI.event_panel(event) end

--- Preparing all text lines to display in event text area
--- @param event TheEncounter.Event
function TheEncounter.UI.event_text_lines(event) end

--- Add displaying specified amount of lines to event queue
--- @param event TheEncounter.Event
--- @param amount number Amount of lines to display
--- @param instant? boolean Should added events be with no delay
function TheEncounter.UI.event_show_lines(event, amount, instant) end

--- Add all remaining non-displayed lines to event queue
--- @param event TheEncounter.Event
function TheEncounter.UI.event_show_all_text_lines(event) end

--- Prepare all buttons for choices
--- @param event TheEncounter.Event
function TheEncounter.UI.event_choices(event) end

--- With animation remove text and choices before next step
--- @param event TheEncounter.Event
--- @param is_finish? boolean
function TheEncounter.UI.event_cleanup(event, is_finish) end

--- Hide event panel UI and remove it
--- @param event TheEncounter.Event
function TheEncounter.UI.event_finish(event) end
