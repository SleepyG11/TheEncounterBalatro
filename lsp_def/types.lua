--- @meta

--- @class TheEncounter.RewardDisplayObject
--- @field full_ui? table
--- @field value_ui? table
--- @field value? string|number
--- @field colour? table
--- @field symbol? string
--- @field font? SMODS.Font
--- @field scale? number
--- @field limit? number
--- @field spacing? number

--- @alias TheEncounter.RewardDisplay string | number | TheEncounter.RewardDisplayObject

--- Table similar to `card.ability`, which stores various values during event.<br/>**Must be serializeable.**
--- @class TheEncounter.EventAbility: table
--- @field hide_hand? boolean Should `G.hand` be hidden
--- @field hide_deck? boolean Should `G.deck` be hidden
--- @field hide_text? boolean Should event text `event.ui.text` be hidden (this will free space it uses)
--- @field hide_image? boolean Should event image `event.ui.image` be hidden (this will free space it uses, updates only during step change)
--- @field hide_choices? boolean Should event choices `event.ui.choices` be hidden (this will free space it uses)
