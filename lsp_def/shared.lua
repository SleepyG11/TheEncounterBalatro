--- @meta

-------------------

--- @class TheEncounter.SimpleRewardDisplayDefinition
--- @field value? string|number
--- @field colour? table
--- @field symbol? string
--- @field font? SMODS.Font
--- @field scale? number
--- @field limit? number
--- @field spacing? number

--- @class TheEncounter.FullRewardDisplayDefinition: TheEncounter.SimpleRewardDisplayDefinition
--- @field full_ui? table
--- @field value_ui? table

--- @alias TheEncounter.RewardDisplay string | number | TheEncounter.SimpleRewardDisplayDefinition

-------------------

--- Table similar to `card.ability`, which stores various values during event.<br/>**Must be serializeable.**
--- @class TheEncounter.EventAbility: table
--- @field hide_hand? boolean Should `G.hand` be hidden (default is `true`)
--- @field hide_deck? boolean Should `G.deck` be hidden (default is `false`)
--- @field hide_text? boolean Should event text `event.ui.text` be hidden (this will free space it uses) (default is `false`)
--- @field hide_image? boolean Should event image `event.ui.image` be hidden (this will free space it uses, updates only during step change) (default is `false`)
--- @field hide_choices? boolean Should event choices `event.ui.choices` be hidden (this will free space it uses) (default is `false`)
--- @field hide_hud? boolean Should event hud be hidden (a blind name, description and reward on top left) (default is `false`)
--- @field hide_panel? boolean Should event panel slide down (default is `false`)
--- @field hide_on_tarot? boolean Should event panel slide down during consumable usage or voucher redeem (default is `true`)
--- @field full_width_choices? boolean Should event choices be inserted into `event.ui.fullw_choices` instead (placed under image so can utilize full width of panel) (default is `false`)
--- @field can_sell? boolean Should "Sell" button for cards be active (default is `true`)
--- @field can_use? boolean Should "Use" button for cards be active (default is `true`)

-------------------

--- @class TheEncounter.EventChoiceOption: table
--- @field domain_key string
--- @field scenario_key? string
