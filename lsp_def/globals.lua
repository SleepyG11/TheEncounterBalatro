--- @meta

--- @type TheEncounter.Event | nil Object which holds all info and ui about current event
G.TheEncounter_event = nil

--- @type UIBox | nil UIBox which holds prompt UI ("Select your next blind" in vanilla blind select)
G.TheEncounter_prompt_box = nil

--- @type UIBox | nil UIBox which holds all choices UI
G.TheEncounter_blind_choices = nil

--- @type TheEncounter.EventChoiceOption[] | nil List of choices for this specific encounter
G.GAME.TheEncounter_choices = nil

--- @type TheEncounter.EventChoiceOption | nil Choice currently selected for event
G.GAME.TheEncounter_choice = nil

--- @type number | nil State which was replaced by `G.STATE.ENC_EVENT_SELECT`
G.GAME.TheEncounter_replaced_state = nil

--- @type "cashout" | "shop" | string | nil In which point event was replaced
G.GAME.TheEncounter_after = nil

--- @type table | nil Save table for current Event object
G.GAME.TheEncounter_save_table = nil
