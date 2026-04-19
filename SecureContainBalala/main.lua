--- STEAMODDED HEADER
--- MOD_NAME: Secure Contain Balala.
--- MOD_ID: SECURECONTAINBALALA
--- MOD_AUTHOR: [atiredguy]
--- MOD_DESCRIPTION: Adds 20 Jokers based on SCP articles in Series 7 to 10
--- PREFIX: scpb
----------------------------------------------
------------MOD CODE -------------------------
TOMFOOL = {vars = {}, funcs = {}, content = SMODS.current_mod}

SMODS.Atlas{
    key = 'Jokers', --atlas key
    path = 'Jokers.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71, --width of one card
    py = 95 -- height of one card
}
SMODS.Atlas {
  key = 'modicon',
  px = 32,
  py = 32,
  path = 'modicon.png'
}
SMODS.Font {
    key = "papyrus",
    path = "PAPYRUS.TTF",
    render_scale = 200,
    TEXT_HEIGHT_SCALE = 0.75,
    TEXT_OFFSET = { x = 10, y = -17 },
    FONTSCALE = 0.1,
    squish = 1,
    DESCSCALE = 1
}
function article_node(strung)
    local artist_node = {n=G.UIT.R, config = {align = 'tm'}, nodes = {
        {n=G.UIT.T, config={
            text = strung[1],
            shadow = true,
            colour = HEX('e3cdb1'),
            scale = 0.19}}
        },
    }
    if strung[2]==" " then return artist_node end
    local artist_node2 = {n=G.UIT.R, config = {align = 'tm'}, nodes = {
        {n=G.UIT.T, config={
            text = strung[2],
            shadow = true,
            colour = HEX('e3cdb1'),
            scale = 0.23}}
        },
    }
    artist_node=
                {
                    n = G.UIT.R,
                    config = { align = "cm",padding = 0.01},
                    nodes = {artist_node,artist_node2}
                }
    return artist_node
end
local mod_path = SMODS.current_mod.path:match("Mods/[^/]+")..'/'
local scpb_card_h_popup_scpb = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
    local ret_val = scpb_card_h_popup_scpb(card)
    local obj = card.config.center or (card.config.tag and G.P_TAGS[card.config.tag.key])
    local positioned = 2
    if card.area and card.area.config.collection and not card.config.center.discovered then return ret_val end
    if obj and obj.article_credits then
        if(#ret_val.nodes[1].nodes[1].nodes[1].nodes>2) then
            positioned=3
        end
        table.insert(ret_val.nodes[1].nodes[1].nodes[1].nodes,2, article_node(obj.article_credits))
    end
    return ret_val
end
G.FUNCS.SCPB_can_use_active_ability_button = function(e)
    local obj = e.config.ref_table.config.center
    local can_use = false
    if obj.scpb and obj.scpb.can_use_ability and type(obj.scpb.can_use_ability) == 'function' and
            G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
        can_use = obj.scpb:can_use_ability(e.config.ref_table)
    end
    if e.config.ref_table.debuff then
        can_use = false
    end
    if (G.play and #G.play.cards > 0) or (G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0) then 
        can_use = false
    end
    if can_use then 
        e.config.colour = G.C.RED
        e.config.button = 'SCPB_use_active_ability_button'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.SCPB_use_active_ability_button = function(e, mute, nosave)
    local card = e.config.ref_table
    local area = card.area

    e.config.ref_table.config.center.scpb:use_ability(card)
    SMODS.calculate_context({scpb = {using_ability = true, card = card, area = card.from_area}})
end

local jest = {"Jest","Look","Pair"}
local function getWizard(center)
    local stringie = " " 
    for k,v in pairs(center.ability.extra.code) do 
        stringie = stringie .. v .. " "
    end 
    return stringie
end
local function event(config)
    local e = Event(config)
    G.E_MANAGER:add_event(e)
    return e
end

local function silentexplode(card,dissolve_colours, explode_time_fac)
    local explode_time = 1.3*(explode_time_fac or 1)*(math.sqrt(G.SETTINGS.GAMESPEED))
    card.dissolve = 0
    card.dissolve_colours = dissolve_colours
        or {G.C.WHITE}

    local start_time = G.TIMERS.TOTAL
    local percent = 0
    card.juice = {
        scale = 0,
        r = 0,
        handled_elsewhere = true,
        start_time = start_time, 
        end_time = start_time + explode_time
    }

    local childParts1 = Particles(0, 0, 0,0, {
        timer_type = 'TOTAL',
        timer = 0.01*explode_time,
        scale = 0.2,
        speed = 2,
        lifespan = 0.2*explode_time,
        attach = card,
        colours = card.dissolve_colours,
        fill = true
    })
    local childParts2 = nil

    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = (function()
                if card.juice then 
                    percent = (G.TIMERS.TOTAL - start_time)/explode_time
                    card.juice.r = 0.05*(math.sin(5*G.TIMERS.TOTAL) + math.cos(0.33 + 41.15332*G.TIMERS.TOTAL) + math.cos(67.12*G.TIMERS.TOTAL))*percent
                    card.juice.scale = percent*0.15
                end
                if G.TIMERS.TOTAL - start_time > 1.5*explode_time then return true end
            end)
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        blockable = false,
        ref_table = card,
        ref_value = 'dissolve',
        ease_to = 0.3,
        delay =  0.9*explode_time,
        func = (function(t) return t end)
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay =  0.9*explode_time,
        func = (function()
            childParts2 = Particles(0, 0, 0,0, {
                timer_type = 'TOTAL',
                pulse_max = 20,
                timer = 0.003,
                scale = 0.3,
                speed = 15,
                lifespan = 0.55,
                attach = card,
                colours = card.dissolve_colours,
            })
            childParts2:set_role({r_bond = 'Weak'})
            G.E_MANAGER:add_event(Event({
                trigger = 'ease',
                blockable = false,
                ref_table = card,
                ref_value = 'dissolve',
                ease_to = 1,
                delay =  0.1*explode_time,
                func = (function(t) return t end)
            }))
            card:juice_up()
            G.VIBRATION = G.VIBRATION + 1
            play_sound('glass1',0.3)
            childParts1:fade(0.3*explode_time) return true end)
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay =  1.4*explode_time,
        func = (function()
            G.E_MANAGER:add_event(Event({
                trigger = 'ease',
                blockable = false, 
                blocking = false,
                ref_value = 'scale',
                ref_table = childParts2,
                ease_to = 0,
                delay = 0.1*explode_time
            }))
            return true end)
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay =  1.5*explode_time,
        func = (function() card:remove() return true end)
    }))
end
local function forced_message(message, card, color, delay)
        
end
local function tablecontains(table, element)
    local numb = 0
  for _, value in pairs(table) do
    if value == element then
      return true
    end
    numb=numb+1
  end
  return false
end
local function tableget(table, element)
    local numb = 0
  for _, value in pairs(table) do
    if value == element then
      return numb
    end
    numb=numb+1
  end
  return -1
end
local function deeperDepartment(lower)
    return 

                {
                    n = G.UIT.R,
                    config = { align = "cm",padding = 0.08},
                    nodes = {
                         
                        {
                            n = G.UIT.R,
                            config = { ref_table = card, align = "cm", colour = mix_colours(G.C.BLACK,G.C.WHITE,0.85), outline_colour = G.C.JOKER_GREY,outline = 1, r = 0.05, padding = 0.1,scale=0.9},
                            nodes = {
                                {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                    {
                                        n = G.UIT.O, config = {
                                        object = DynaText({string = {"Department of redundancy department."}, colours = {G.C.WHITE},
                                        scale = 0.32 * G.LANG.font.DESCSCALE})
                                    }},
                                }},
                                {
                                    n = G.UIT.R,
                                    config = { ref_table = card, align = "cm", colour = G.C.WHITE, r = 0.05, padding = 0.05 },
                                    nodes = {
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='Debuff ', colours = {G.C.RED},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='the ', colours = {G.C.L_BLACK},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='first ', colours = {G.C.ORANGE},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='played card', colours = {G.C.L_BLACK},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='Retrigger ', colours = {G.C.L_BLACK},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='last ', colours = {G.C.ORANGE},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='played card', colours = {G.C.L_BLACK},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='3 ', colours = {G.C.ORANGE},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='additional times.', colours = {G.C.L_BLACK},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                        lower
                                    }
                                }
                            }
                        },
                        
                    }
                }
            
        end
SMODS.Joker{
    key = 'thewizard', --joker key
    loc_txt = { -- local text
        name = 'THE WIZARD',
        text = {
            'MAKE YOUR HAND THE',
            'PASSWORD AND',
            'THEE SHALL',
            'GAIN {X:mult,C:white}X#1#{} MULT.'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"THE WIZARD","SCP-6289"},
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 4, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 0, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        Xmult = 5.5,
        code = {0,0,0,0,0}
      }
    },
    loc_vars = function(self,info_queue,center)
         main_end = {
                {
                    n = G.UIT.R,
                    config = { align = "cm",padding = 0.08},
                    nodes = {
                         
                        {
                            n = G.UIT.R,
                            config = { ref_table = card, align = "cm", colour = mix_colours(G.C.GREY,G.C.WHITE,0.7), r = 0.05, padding = 0.06 },
                            nodes = {
                                {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                    {
                                        n = G.UIT.O, config = {
                                        object = DynaText({string = {"   YOUR CODE   "}, colours = {G.C.WHITE},
                                        scale = 0.32 * G.LANG.font.DESCSCALE})
                                    }},
                                }},
                                {
                                    n = G.UIT.R,
                                    config = { ref_table = card, align = "cm", colour = G.C.WHITE, r = 0.05, padding = 0.04 },
                                    nodes = {
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string = {getWizard(center)
                                                }, colours = {G.C.GREY},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }}
                                    }
                                }
                            }
                        },
                        
                    }
                }
            }
        return {vars = {center.ability.extra.Xmult,center.ability.extra.code},main_end = main_end}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.joker_main and context.scoring_hand then
            local listed = {}
            for a = 1, #(card.ability.extra.code) do
                table.insert(listed,card.ability.extra.code[a])
            end
            local numbs = 0

            for a = 1, #(context.scoring_hand) do
                
                if context.scoring_hand[a]:get_id()==listed[a] then
                    numbs = numbs+1
                    sendDebugMessage('[SCB] Yowza')
                end 
            end
            if numbs == 5 then
                local randumb = math.random(5)+5
                card.ability.extra.code = {}
                for a = 1, 5 do
                    table.insert(card.ability.extra.code,randumb-a)
                end
                return {
                    colour = G.C.RED,
                    message = "x".. card.ability.extra.Xmult,
                    Xmult_mod = card.ability.extra.Xmult
                }
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        local randumb = math.random(5)+5
                card.ability.extra.code = {}
                for a = 1, 5 do
                    table.insert(card.ability.extra.code,randumb-a)
                end
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
}

SMODS.Joker{
    key = 'dorddord', --joker key
    loc_txt = { -- local text
        name = 'Department of redundancy department.',
        text = {
            '{C:mult}Debuff{} the {C:attention}first{} played card',
            'Retrigger {C:attention}last{} played card',
            '{C:attention}#1#{} additional times.'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"DEPARTMENTALIZED","SCP-8190"},
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 4, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 1, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        repetitions = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        local firstiter = 
                {
                    n = G.UIT.R,
                    config = { align = "cm",padding = 0.05},
                    nodes = {
                         
                    }
                }
            
            local main_end = deeperDepartment(firstiter)
            for a = 1,4 do
                main_end = deeperDepartment(main_end)
            end
            main_end = {main_end}
        return {vars = {center.ability.extra.repetitions},main_end = main_end}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[#context.scoring_hand] then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
        if context.before then
            context.scoring_hand[1]:set_debuff(true)
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
}
SMODS.Joker{
    key = 'thejokerthatmakesyouracist', --joker key
    loc_txt = { -- local text
        name = '{f:scpb_papyrus}The joker that makes you racist{}',
        text = {
            '{f:scpb_papyrus}Played cards with{}',
            '{f:scpb_papyrus,C:diamonds}Diamond{} {f:scpb_papyrus}or{} {f:scpb_papyrus,C:hearts}Heart{} {f:scpb_papyrus}suit{}',
            '{f:scpb_papyrus}Give{} {f:scpb_papyrus,C:mult}+#1#{} {f:scpb_papyrus}Mult when scored{}'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"The bike that makes you racist","SCP-9002"},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 1, y = 3}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        mult = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.mult}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play and context.other_card ~= nil then
            if context.other_card:is_suit('Diamonds') or context.other_card:is_suit('Hearts') then
            return {
                mult = card.ability.extra.mult
            }
        end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
}

SMODS.Joker{
    key = 'automatonophobia', --joker key
    loc_txt = { -- local text
        name = 'Automatonophobia',
        text = {
            'Gains {C:chips}+#2#{} Chips',
            'When a played {C:attention}Face{} card',
            'is scored',
            '{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Automatonophobia: False Positive" , "SCP-8986"},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 2, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        chips = 0,
        additional = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.chips,center.ability.extra.additional}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            card.ability.extra.chips=card.ability.extra.chips+card.ability.extra.additional
            return {
                message = '+' .. card.ability.extra.additional,
                colour = G.C.CHIPS,
                message_card = card
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
}

SMODS.Joker{
    key = 'ohshitarat', --joker key
    loc_txt = { -- local text
        name = 'A rat',
        text = {
            'If score is set on fire',
            'All scored cards gain {C:mult}#1#{} Mult',
            '{C:attention}Explodes{} afterwards'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Site-333's Rodent"," "},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 3, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        mult = 3,
        time = 0,
        timeadd = 0.1,
        childParts = nil
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.mult,center.ability.extra.time,center.ability.extra.timeadd,center.ability.extra.childParts}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        
         if context.joker_main then
            local temp_chips = G.GAME.blind.chips
            if math.floor(hand_chips * mult) > (temp_chips) and card.ability.extra.timeadd == 0.1 then
                
                event({trigger = 'before', delay = 0.1, func = function()
                    for a =1, #(context.scoring_hand) do
                    context.scoring_hand[a]:juice_up()
                    context.scoring_hand[a].ability.perma_mult = context.scoring_hand[a].ability.perma_mult + card.ability.extra.mult
                    card_eval_status_text(
                        context.scoring_hand[a],
                        'extra',
                        nil, nil, nil,
                        {message = "+"..card.ability.extra.mult .. " Mult", colour = G.C.RED, instant = true}
                    )
                    end
                    card.ability.extra.timeadd = 1.0
                    card_eval_status_text(
                        card,
                        'extra',
                        nil, nil, nil,
                        {message = "OH DAMN A RAT", colour = color, instant = true}
                    )
                return true
                end})
                
                
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if (self.discovered or card.bypass_discovery_center) then
            local timeadd = card.ability.extra.timeadd
            
            if timeadd~=nil and timeadd>0.1 then
                local timer = card.ability.extra.time+(1.0/G.ANIMATION_FPS * 8.0)/(timeadd+0.4)
                timeadd = timeadd-1.0/G.ANIMATION_FPS/5.5
                local timeclamped = math.max(math.min(1.0/timeadd,3.0),0.5)
                if timeadd<0.5 and card.ability.extra.timeadd>=0.5 then
                    
                end
                if timeadd<0.1 then
                    if card.ability.extra.childParts ~= nil then
                    card.ability.extra.childParts:fade(0.8)
                    end
                    card:juice_up(0.9)
                    silentexplode(card,{HEX('cf2727'),HEX('fd5f55')},0.6)
                    play_sound('slice1', 0.96+math.random()*0.08)
                    timeadd = 0.0
                end
                card.ability.extra.time = timer
                card.children.center.CT.r = card.children.center.CT.r+math.cos(timer/3.0)/6.0*timeclamped
                card.children.center.CT.y = card.children.center.CT.y-math.sin(timer)/12.0*timeclamped
                card.children.center.scale.y = card.children.center.scale.y+math.sin(timer)/24.0*timeclamped
                card.children.center.CT.x = card.children.center.CT.x-math.cos(timer)/26.0*timeclamped
                card.children.center.scale.x = card.children.center.scale.x+math.cos(timer)/72.0*timeclamped
            end
            card.ability.extra.timeadd = timeadd
            
            
        end
    end,
}
SMODS.Joker {
	key = "paperbirch_eyes",
	loc_txt = {
		name = "Paper Birch Trail",
		text = {
			'{C:mult}Destroy{} the rightmost', '{C:mult}Discarded{} card'
		}
	},
	no_collection = true,
	in_pool = function(self, args)
		return false
	end,
}
SMODS.Joker {
	key = "paperbirch_jokerr",
	loc_txt = {
		name = "Paper Birch Trail",
		text = {
			'Gain {C:money}+#1#${} Sell Price', 'When a {C:attention}Hand{} is played'
		}
	},
	no_collection = true,
	in_pool = function(self, args)
		return false
	end,
}
SMODS.Joker {
	key = "paperbirch_pair",
	loc_txt = {
		name = "Paper Birch Trail",
		text = {
			{'If the Played Hand contains a {C:attention}Pair{}', '{C:attention}First{} Card gets the {C:attention}Second{} Cards Suit'},
            {'{C:mult}AND{}','{C:attention}First{} and {C:attention}Second{} Cards get {C:mult}+#3#{} Mult'}
		}
	},
	no_collection = true,
	in_pool = function(self, args)
		return false
	end,
}
SMODS.Joker{
    key = 'paperbirch', --joker key
    loc_txt = { -- local text
        name = 'Paper Birch Trail',
        text = {
            '#1#'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Paper Birch Trail","SCP-8411"},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 0, y = 1}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        price = 2,
        type = 1,
        additional = 1
      }
    },
    loc_vars = function(self,info_queue,center)
        local priced = center.ability.extra.price
        if(center.ability.extra.type==1) then
            return {
				key = "j_scpb_paperbirch_jokerr",
				vars = {priced,center.ability.extra.type,center.ability.extra.additional}
			}
        end
        if(center.ability.extra.type==2) then
            return {
				key = "j_scpb_paperbirch_eyes",
				vars = {priced,center.ability.extra.type,center.ability.extra.additional}
			}
        end
        if(center.ability.extra.type==3) then
            return {
				key = "j_scpb_paperbirch_pair",
				vars = {priced,center.ability.extra.type,center.ability.extra.additional}
			}
        end
        return {vars = {priced,center.ability.extra.type,center.ability.extra.additional}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            local randumber = math.random(3)
            local delayed = 0.0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then delayed = i/5.0 break end
            end
            event({trigger = 'before', delay = 0.0, func = function()
                card:flip()
                
                card.ability.extra.type = randumber
                card_eval_status_text(
                    card,
                    'extra',
                    nil, nil, nil,
                    {message = jest[randumber], colour = G.C.GREY, instant = true}
                )
                return true
            end})
            event({trigger = 'before', delay = 1.0, func = function()
                card.children.center:set_sprite_pos({x =card.ability.extra.type-1, y=1})
                card:flip()
                return true
            end})
            
        end
        if context.joker_main and card.ability.extra.type == 1 then
            card.ability.extra_value = card.ability.extra_value + card.ability.extra.price
            card:set_cost()
            return {
                message = "+"..card.ability.extra.price.."$",
                colour = G.C.MONEY
            }
        end
        if context.joker_main and context.scoring_hand and next(context.poker_hands["Pair"]) and card.ability.extra.type == 3 then
            SMODS.change_base(context.scoring_hand[1], context.scoring_hand[2].base.suit)
            context.scoring_hand[1].ability.perma_mult = context.scoring_hand[1].ability.perma_mult + card.ability.extra.additional
            context.scoring_hand[2].ability.perma_mult = context.scoring_hand[2].ability.perma_mult + card.ability.extra.additional
            card:juice_up()
        end
        if card.ability.extra.type==2 and context.pre_discard and not context.blueprint and G.hand.highlighted then
            local carded = G.hand.highlighted[#G.hand.highlighted]
            carded:start_dissolve({G.C.RED}, nil, 1.6)
            event({trigger = 'before', delay = 0.1, func = function()
                carded:remove()
                return true end})
        end
        if context.flip and not context.blueprint then
            
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    set_sprites = function(self, card, front)
        if (self.discovered or card.bypass_discovery_center) and card.ability and card.ability.extra then
            card.children.center:set_sprite_pos({x =card.ability.extra.type-1, y=1})
        end
    end
}

  SMODS.Joker{
    key = 'aquaphobia', --joker key
    loc_txt = { -- local text
        name = 'Aquaphobia',
        text = {
            {'{C:mult}Destroy{} and then',
            'Create a {C:attention}copy{} of',
            'Leftmost {C:attention}discarded{} card'},
            {
                'The card gains',
                '{C:chips}+#1#{} chips'
            }
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Aquaphobia: Surface Tension","SCP-8380"},
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = false, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 0, y = 2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    draw = function(self, card, layer)
        if card.config.center.discovered or card.bypass_discovery_center then
            card.children.center:draw_shader('voucher', nil, card.ARGS.send_to_shader)
        end
    end,
    config = { 
      extra = {
        chips = 3,
        additional = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.chips,center.ability.extra.additional}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    calculate = function(self, card, context)
        
        if context.pre_discard and not context.blueprint and G.hand.highlighted then
            local carded = G.hand.highlighted[1]
            local copy_card = copy_card(carded, nil, nil,1)
            copy_card:add_to_deck()
            copy_card.ability.perma_bonus = (copy_card.ability.perma_bonus or 0) + card.ability.extra.chips
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            table.insert(G.playing_cards, copy_card)
            G.hand:emplace(copy_card)

            copy_card.states.visible = nil
            copy_card:juice_up()
                
                    card_eval_status_text(
                        copy_card,
                        'extra',
                        nil, nil, nil,
                        {message = "+"..card.ability.extra.chips .. " Chips", colour = G.C.BLUE, instant = true}
                    )
            G.E_MANAGER:add_event(Event({
                func = function()
                    copy_card:start_materialize()
                    return true
                end
            }))
            carded:start_dissolve({G.C.BLUE}, nil, 1.6)
            event({trigger = 'before', delay = 0.1, func = function()
                SMODS.destroy_cards(carded)
                return true end})
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        
    end
}

  SMODS.Joker{
    key = 'uselesswerewolf', --joker key
    loc_txt = { -- local text
        name = 'The Useless Werewolf Joker',
        text = {
            'When a {C:attention}Joker{} is destroyed,',
            'Gain {C:money}#1#${}'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Netzach: The Useless Werewolf Machine","SCP-9660"},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 3, y = 2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        payout = 6,
        frameTime = 0
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.payout,
                                center.ability.extra.frameTime}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.joker_type_destroyed and context.card.ability.set == "Joker" then
            card.ability.extra.frameTime = 1.2
            card:juice_up(0.5, 0.4)
            G.E_MANAGER:add_event(Event{func = function()
                            card_eval_status_text(
                            card,
                            'extra',
                            nil, nil, nil,
                            {message = '$'..card.ability.extra.payout, colour = G.C.MONEY, instant = true})
                        return true end})
            ease_dollars(card.ability.extra.payout)
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.2) + 20
        card.children.center.CT.r = math.sin(timer*0.3)*0.1*math.cos(timer*0.2)
        if self.discovered or card.bypass_discovery_center and (not G.SETTINGS.paused) then
            if G.SETTINGS.paused then
                return
            end
            if card.ability.extra.frameTime>1.0 then  
                card.children.center:set_sprite_pos({x =3, y =math.floor(card.ability.extra.frameTime/3.0)%2+2})
                card.ability.extra.frameTime=card.ability.extra.frameTime+1.5/G.ANIMATION_FPS
                local off = 1.0-(math.abs(card.ability.extra.frameTime-6.28)/6.28)
                card.children.center.CT.y = card.children.center.CT.y-math.sin(card.ability.extra.frameTime)/3.0*off
            end
            if card.ability.extra.frameTime>12.56 then
                card.ability.extra.frameTime=0.0
                card.children.center:set_sprite_pos({x = 3,y = 2})
            end
        else
            card.children.center:set_sprite_pos({x = 3,y = 2})
        end
    end
}

  SMODS.Joker{
    key = 'forthefairest', --joker key
    loc_txt = { -- local text
        name = 'For the Fairest',
        text = {
            '{C:mult}+#1#{} Mult',
            'Create a copy when beating a {C:attention}Blind{}',
            '{C:inactive}(Must have space)'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Tiphereth: For The Fairest", "SCP-9490"},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 4, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 2, y =2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        mult = 5,
        active = 1
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.mult,center.ability.extra.active}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if  context.end_of_round and context.game_over == false and #G.jokers.cards < G.jokers.config.card_limit and context.main_eval and (not context.blueprint) and card.ability.extra.active == 1 then
            card.ability.extra.active = 0
            card:juice_up()
            local copy_card = copy_card(card, nil, nil,1)
            copy_card:add_to_deck()
            G.jokers:emplace(copy_card)
            copy_card:start_materialize()
        end
       if context.joker_main then
            card.ability.extra.active = 1
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
    end
}
SMODS.Joker {
	key = "twowaystreet_flipped",
	loc_txt = {
		name = "Two Way Street",
		text = {
			{'When a Joker is {C:attention}Sold{}', 'Create a {C:spectral}Spectral{} card'},
            {'{C:attention}Flips{} after {C:chips}Playing{}'}
		}
	},
	no_collection = true,
	in_pool = function(self, args)
		return false
	end,
}
  SMODS.Joker{
    key = 'twowaystreet', --joker key
    loc_txt = { -- local text
        name = 'Two Way Street',
        text = {
            {'When a Playing Card is {C:mult}Destroyed{}', 'Create a {C:planet}Planet{} card'},
            {'{C:attention}Flips{} after {C:mult}Discarding{}'}
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Yesod: Two Way Street", "SCP-8984"},
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 6, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 1, y =2}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        chips = 0,
        additional = 3,
        angle = 0,
        angle_rn = 0,
        odds = 2
      }
    },
    loc_vars = function(self,info_queue,center)
		local probabilities_normal, odds = SMODS.get_probability_vars(center, 1, center.ability.extra.odds, "scpb_twowaystreet")
        if (center.ability.extra.angle==1.0) then
            return {key="j_scpb_twowaystreet_flipped",vars = {center.ability.extra.chips,center.ability.extra.additional,center.ability.extra.angle,center.ability.extra.angle_rn,probabilities_normal,odds}}
        end
        return {vars = {center.ability.extra.chips,center.ability.extra.additional,center.ability.extra.angle,center.ability.extra.angle_rn,probabilities_normal,odds}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
         if context.remove_playing_cards and context.removed and #context.removed > 0 then
            
            for i = 1, #context.removed do
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
             G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            set = 'Planet',
                            key_append = 'scpb_twowaystreet' -- Optional, useful for manipulating the random seed and checking the source of the creation in `in_pool`.
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
            end
            return {
                    extra = {
                        message = "Astrological.",
                        message_card = card
                    },
                }
         end
        if context.selling_card and context.cardarea == G.jokers then
            if context.other_card ~= self and 
                #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            set = 'Spectral',
                            key_append = 'scpb_twowaystreet' -- Optional, useful for manipulating the random seed and checking the source of the creation in `in_pool`.
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
                return {
                    message = "Theological.",
                    colour = G.C.SECONDARY_SET.Spectral
                }
            end
        end
       if context.final_scoring_step then
            local smiley=false
             event({
                    trigger = 'before',
                    delay = 0.7,
                    func = function()
                        card.ability.extra.angle = 0
                        return true
                    end
                })
        end
        if context.pre_discard then
            card.ability.extra.angle = 1
        end    
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if self.discovered or card.bypass_discovery_center then
        local timer = 1.0/G.ANIMATION_FPS
        card.ability.extra.angle_rn = card.ability.extra.angle_rn*(1.0-timer)+card.ability.extra.angle*timer
        card.children.center.CT.r = card.ability.extra.angle_rn*3.14
        end
    end
}
  SMODS.Joker{
    key = 'malkuth', --joker key
    loc_txt = { -- local text
        name = 'Our oldest friend',
        text = {
            'Upon using a planet card',
            '{C:mult}Destroy{} rightmost joker',
            'The hand gains {C:mult}+#1#{} mult'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Malkuth: Symphonia Universalis", "SCP-9911"},
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 2, y = 4}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        mult = 9
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.mult}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        
       --see lovely mixin
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if self.discovered or card.bypass_discovery_center then
            --local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.2) + 20
            --card.children.center.CT.r = card.children.center.CT.r+math.cos(timer/3.0)/32.0
            --card.children.center.CT.y = card.children.center.CT.y-math.sin(timer)/6.0
            --card.children.center.scale.y = card.children.center.scale.y+math.sin(timer)/12.0
            --card.children.center.CT.x = card.children.center.CT.x-math.cos(timer)/18.0
            --card.children.center.scale.x = card.children.center.scale.x+math.cos(timer)/36.0
            
        end
    end
}

  SMODS.Joker{
    key = 'francois', --joker key
    loc_txt = { -- local text
        name = 'Francois Couperin',
        text = {
            ''
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    
    article_credits = {"Keter: A White and Shining Fire", "SCP-9987"},
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 2, y = 3}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        mult = 8,
        chips = 30
      }
    },
    loc_vars = function(self,info_queue,center)
        
        info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
        info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
        main_end = {
                {
                    n = G.UIT.R,
                    config = { align = "cm",padding = 0.08},
                    nodes = {
                    {
                            
                            n = G.UIT.R,
                            config = { ref_table = card, align = "cm", colour =HEX('e3cdb1'), outline_colour  =HEX('c9af8d'),outline = 1, r = 0.1, padding = 0.08,scale=1.0},
                            nodes = {
                                {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                    {
                                        n = G.UIT.O, config = {
                                        object = DynaText({string = {"RAISA NOTICE:"}, colours = {HEX('301c01')},
                                        scale = 0.32 * G.LANG.font.DESCSCALE})
                                        }
                                    },
                                }},
                                
                                {
                                    n = G.UIT.R,
                                    config = { ref_table = card, align = "cm", colour = HEX('301c01'), r = 0.01, padding = 0.01 },
                                    nodes = {
                                        {n = G.UIT.R, config = {align = "lm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='                            ', colours = {G.C.RED},
                                                scale = 0.12* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                    }
                                },
                                
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='Mult ', colours = {G.C.RED},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='cards ', colours = {HEX('301c01')},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='give ', colours = {HEX('301c01')},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='+'..center.ability.extra.mult, colours = {G.C.RED},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string =' Mult', colours = {HEX('301c01')},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='Bonus ', colours = {G.C.BLUE},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='cards ', colours = {HEX('301c01')},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='give ', colours = {HEX('301c01')},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                        {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string ='+'..center.ability.extra.chips, colours = {G.C.BLUE},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }},
                                            {
                                                n = G.UIT.O, config = {
                                                object = DynaText({string =' Chips', colours = {HEX('301c01')},
                                                scale = 0.32* G.LANG.font.DESCSCALE})
                                            }}
                                        }},
                                
                            
                            }
                        }
                    }
                }
            }
        
        return {vars = {center.ability.extra.mult,center.ability.extra.chips},main_end = main_end}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play and context.other_card.config.center == G.P_CENTERS.m_mult then
                context.other_card:juice_up()
                return {
                    mult = card.ability.extra.mult
                }
        end
        if context.individual and context.cardarea == G.play and context.other_card.config.center == G.P_CENTERS.m_bonus then
            context.other_card:juice_up()
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if self.discovered or card.bypass_discovery_center then
            --local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.2) + 20
            --card.children.center.CT.r = card.children.center.CT.r+math.cos(timer/3.0)/32.0
            --card.children.center.CT.y = card.children.center.CT.y-math.sin(timer)/6.0
            --card.children.center.scale.y = card.children.center.scale.y+math.sin(timer)/12.0
            --card.children.center.CT.x = card.children.center.CT.x-math.cos(timer)/18.0
            --card.children.center.scale.x = card.children.center.scale.x+math.cos(timer)/36.0
            
        end
    end
}
  
  SMODS.Joker{
    key = 'stillwater', --joker key
    loc_txt = { -- local text
        name = 'Lidar Scan',
        text = {
            {'Gain {X:mult,C:white}x#2#{} Mult per {C:attention}Scored{} card',
            'When scoring a hand with {C:attention}Unscored{} cards',
            '{C:inactive}(Currently{} {X:mult,C:white}x#1#{}{C:inactive} Mult){}'},{
            '{C:mult}Resets{} at the end of Round'
            }
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Hokma: Still Waters Run Deep", "SCP-9330"},
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 0, y = 5}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        Xmult = 1,
        additional = 0.2,
        hands = 1
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.Xmult,center.ability.extra.additional,center.ability.extra.hands}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint and card.ability.extra.Xmult > 1 then
            card.ability.extra.Xmult = 1
            return {
                message = "Deeper",
                colour = G.C.RED
            }
        end
        if context.joker_main and context.scoring_hand then
            local listed = {}
            local numbs = 0
            local should = false
            for a = 1, #G.play.cards do
                if not tablecontains(context.scoring_hand,G.play.cards[a]) then
                    should = true
                else
                    numbs=1+numbs
                    G.play.cards[a]:juice_up(0.5, 0.4)
                    G.E_MANAGER:add_event(Event{delay=1.0,func = function()
                            card_eval_status_text(
                            G.play.cards[a],
                            'extra',
                            nil, nil, nil,
                            {message = 'x'..card.ability.extra.additional, colour = G.C.MULT, instant = true})
                        return true end})
                end
            end
            if numbs >0 and should then
                card.ability.extra.Xmult=card.ability.extra.additional*numbs+card.ability.extra.Xmult
                return {
                    colour = G.C.RED,
                    message = "x".. card.ability.extra.Xmult,
                    Xmult_mod = card.ability.extra.Xmult
                }
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    set_sprites = function(self, card, front)
        
    end,
    update = function(self, card)
        if (self.discovered or card.bypass_discovery_center) and card.ability then
            card.children.center:set_sprite_pos({x =math.min(math.floor((card.ability.extra.Xmult-1.0)*3.0),3.0), y=5})
        end
    end
}
--dummy joker so binah can be SCION
SMODS.Joker {
	key = "scion_john",
	loc_txt = {
		name = "SCION",
		text = {
			{'Copies the {C:attention}Joker{}', 'to the {C:attention}Right{}'},
            {'Flips to {C:mult}Server Rack{} next hand.'}
		}
	},
	no_collection = true,
	in_pool = function(self, args)
		return false
	end,
}
SMODS.Joker{
    key = 'binah', --joker key
    loc_txt = { -- local text
        name = 'Server Rack',
        text = {
            'Flips to {C:mult}SCION{} next hand.'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Binah: Machine, Learning", "SCP-8483"},
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 5, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 0, y = 4}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        chips = 0,
        binah_type = false,
        binah_lerp = 0.0,
        additional = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        if center.ability.extra.binah_type==false and not tablecontains(info_queue,G.P_CENTERS.j_scpb_binah) then 
            info_queue[#info_queue + 1] = G.P_CENTERS.j_scpb_scion_john
        else
        end
        if center.ability.extra.binah_type==true then
            local other_joker
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == center then other_joker = G.jokers.cards[i + 1] end
            end
            local compatible = other_joker and other_joker ~= center and other_joker.config.center.blueprint_compat
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.4 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { ref_table = center, align = "m", colour = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                            nodes = {
                                { n = G.UIT.T, config = { text = ' ' .. (compatible and 'Compatible!' or 'Incompatible.') .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                            }
                        }
                    }
                }
            }
            return {
				key = "j_scpb_scion_john",
				vars = {center.ability.extra.chips,center.ability.extra.binah_type,center.ability.extra.binah_lerp,center.ability.extra.additional }, main_end = main_end
			}
        end
        return {vars = {center.ability.extra.chips,center.ability.extra.binah_type,center.ability.extra.binah_lerp,center.ability.extra.additional}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        if context.final_scoring_step then
            local smiley=false
             event({
                    trigger = 'before',
                    delay = 0.7,
                    func = function()
                        if card.ability.extra.binah_type then
                            card.ability.extra.binah_type = false
                        else
                            card.ability.extra.binah_type = true
                        end
                        return true
                    end
                })
        end
        if card.ability.extra.binah_type==true then
            local other_joker = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
            end
            local ret = SMODS.blueprint_effect(card, other_joker, context)
            if ret then
                ret.colour = G.C.BLUE
            end
            return ret
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if self.discovered or card.bypass_discovery_center then
            if(card.ability.extra.binah_type==true) then
                local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.1) + 20
                card.children.center.CT.r = math.sin(timer*2.0)*0.2*math.cos(timer*3.2)
                card.children.center:set_sprite_pos({x =1, y=4})
                card.ability.extra.binah_lerp = card.ability.extra.binah_lerp*0.9+1.0*0.1
            else
                card.ability.extra.binah_lerp = card.ability.extra.binah_lerp*0.9+0.0
                card.children.center:set_sprite_pos({x =0, y=4})
            end
            card.children.center.T.w = (2.0-math.abs(card.ability.extra.binah_lerp-0.5)*2.0)*G.CARD_W
            --local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.2) + 20
            --card.children.center.CT.r = card.children.center.CT.r+math.cos(timer/3.0)/32.0
            --card.children.center.CT.y = card.children.center.CT.y-math.sin(timer)/6.0
            --card.children.center.scale.y = card.children.center.scale.y+math.sin(timer)/12.0
            --card.children.center.CT.x = card.children.center.CT.x-math.cos(timer)/18.0
            --card.children.center.scale.x = card.children.center.scale.x+math.cos(timer)/36.0
        end
    end
}
SMODS.Joker{
    key = 'geburah', --joker key
    loc_txt = { -- local text
        name = 'Continuity',
        text = {
            {'{X:inactive,C:white,s:0.85}Activatable{}',
            'Costs {C:money}#2#${}'},
            {'Lowers the current {C:attention}Blind requirement{}',
            'By {C:attention}#1#%{}'}
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Geburah: This Corner of the World", "SCP-9880"},
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 0, y =3}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        chips = 10,
        cost = 2,
        additional = 3
      }
    },
    scpb = {
        -- THIS ONE IS HEAVILY BASED UPON All In Jest github. go call their team goated because they absolutely are.
        ability_cost = function(self, card)
             return card.ability.extra.cost
        end,
        
        can_use_ability = function(self, card, context)
            
            if not G.GAME.blind.in_blind then return false end
            if to_big(G.GAME.dollars) >= to_big(card.ability.extra.cost) and G.STATE == G.STATES.SELECTING_HAND then
                return true
            end
        end,

        use_ability = function(self, card)
            
            if not G.GAME.blind.in_blind or G.GAME.blind.chips == nil then return end
            ease_dollars(-card.ability.extra.cost)
            card_eval_status_text(card, 'dollars', -card.ability.extra.cost)
            local desired_chip_amount = G.GAME.blind.chips*((100.0-card.ability.extra.chips)/100.0)
            local chips_text_integer = desired_chip_amount
            G.GAME.blind.chip_text = number_format(chips_text_integer)
            G.GAME.blind.chips = desired_chip_amount
            card:juice_up()
        end,
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.chips,center.ability.extra.cost,center.ability.extra.additional}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
       
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if not card.scpb_ability_cost_label or card.config.center.scpb:ability_cost(card) ~= card.scpb_ability_cost_label then
            card.scpb_ability_cost_label = card.config.center.scpb:ability_cost(card)
        end
    end
}

  SMODS.Joker{
    key = 'bebe', --joker key
    loc_txt = { -- local text
        name = 'Immortal Joker Trapped in Concrete',
        text = {
            'Scored {C:attention}Stone cards{} become {C:spectral}Eternal{}',
            'And give {X:mult,C:white}X#1#{} Mult'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"THE IMMORTAL BABY TRAPPED IN CONCRETE SAGA", "SCP-9730"},
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 8, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 3, y = 4}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        xmult = 1.5,
        additional = 3, 
        sticker = 'eternal'
      }
    },
    loc_vars = function(self,info_queue,center)
        
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        return {vars = {center.ability.extra.xmult,center.ability.extra.additional, localize({type = 'name_text', set = 'Other', key = center.ability.extra.sticker})}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        
        if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_stone') then
            if not context.other_card.ability[card.ability.extra.sticker] then
                        return {
                            message = "Immortal.",
                            xmult=card.ability.extra.xmult,
                            message_card = context.other_card,
                            func = function()
                                card:juice_up()
                                context.other_card:add_sticker(card.ability.extra.sticker, true)
                                if context.other_card.ability.perishable then context.other_card.ability.perishable = false end
                            end
                        }
            else
                return {
                            xmult=card.ability.extra.xmult,
                            message_card = context.other_card,
                            func = function()
                                card:juice_up()
                            end
                        }
            end
            return
        end
       
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_stone') then
                return true
            end
        end
        return false
    end,
    update = function(self, card)
    end
}

  SMODS.Joker{
    key = 'rvjokerstern', --joker key
    loc_txt = { -- local text
        name = 'R.V Jokerstern',
        text = {
           {
             '{C:attention}Gains{} the following:',
            '{s:0.8}\"At the end of each round, the{} {C:attention,s:0.8}Counter{} {s:0.8}Above{}',
            '{s:0.8}Gains{} {C:chips,s:0.8}+#1#{} {s:0.8}Chips\"{}',
            'After beating a {C:attention}Boss Blind{}',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)'
           }
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"CONTENTS UNDER PRESSURE", "SCP-9377"},
    atlas = 'Jokers', --atlas' key
    rarity = 3, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 4, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        chips = 1,
        additional = 0,
        chip_list = {1}
      }
    },
    loc_vars = function(self,info_queue,center)
        
        main_end = {}
        for i = 1, #center.ability.extra.chip_list do
            table.insert(main_end,{
                    n = G.UIT.R,
                    config = { ref_table = card, align = "cm", colour =G.C.L_BLACK,outline = 0, r = 0.1, padding = 0.04,scale=0.8},
                    nodes = {
                    {
                            
                            n = G.UIT.R,
                            config = { ref_table = card, align = "cm", colour =HEX('FFFFFF'),outline = 0, r = 0.1, padding = 0.08,scale=0.8},
                            nodes = {
                                {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                    {
                                        n = G.UIT.O, config = {
                                        object = DynaText({string = {"At the end of each round, the "}, colours = {G.C.L_BLACK},
                                        scale = 0.32 * G.LANG.font.DESCSCALE*0.8})
                                        }
                                    },
                                    {
                                         n = G.UIT.O, config = {
                                        object = DynaText({string = {"Counter "}, colours = {G.C.ORANGE},
                                        scale = 0.32 * G.LANG.font.DESCSCALE*0.8})
                                        }
                                    },
                                    {
                                        n = G.UIT.O, config = {
                                        object = DynaText({string = {"above"}, colours = {G.C.L_BLACK},
                                        scale = 0.32 * G.LANG.font.DESCSCALE*0.8})
                                        }
                                    },
                                }},
                                 {n = G.UIT.R, config = {align = "cm"}, nodes = {
                                    {
                                        n = G.UIT.O, config = {
                                        object = DynaText({string = {"Gains "}, colours = {G.C.L_BLACK},
                                        scale = 0.32 * G.LANG.font.DESCSCALE*0.8})
                                        }
                                        
                                    },
                                    {
                                         n = G.UIT.O, config = {
                                        object = DynaText({string = {"+"..center.ability.extra.chip_list[i]}, colours = {G.C.CHIPS},
                                        scale = 0.32 * G.LANG.font.DESCSCALE*0.8})
                                        }
                                        
                                    },
                                    {
                                        n = G.UIT.O, config = {
                                        object = DynaText({string = {" Chips"}, colours = {G.C.L_BLACK},
                                        scale = 0.32 * G.LANG.font.DESCSCALE*0.8})
                                        },
                                    },
                                }}
                                
                        
                            }
                        }
                    }
                })
        end
        return {vars = {center.ability.extra.chips,center.ability.extra.additional,center.ability.extra.chip_list},main_end=main_end}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
       if context.end_of_round and context.game_over == false and context.main_eval then
            card:juice_up()
            local lengthChip = #card.ability.extra.chip_list
            for i = 0, lengthChip-2 do
                card.ability.extra.chip_list[lengthChip-i-1]=card.ability.extra.chip_list[lengthChip-i-1]+card.ability.extra.chip_list[lengthChip-i]
            end
            card.ability.extra.additional = card.ability.extra.chip_list[1]+card.ability.extra.additional
            if context.beat_boss then
                table.insert(card.ability.extra.chip_list,card.ability.extra.chips)
            end
            return{
                message = "+1 atm"

            }
       end
       if context.joker_main then
            return {
                chips = card.ability.extra.additional
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if (self.discovered or card.bypass_discovery_center) and (not G.SETTINGS.paused) then
            local multed =math.max(0,#card.ability.extra.chip_list-1)
            local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 1.3)*math.pow(multed,0.5) + 10
            card.children.center:set_sprite_pos({x =4, y=0+math.min(multed,2)})
            card.children.center.CT.y = card.children.center.CT.y-math.sin(timer)/24.0
            card.children.center.CT.x = card.children.center.CT.x+math.cos(timer*1.2+0.3)/24.0
            card.children.center.CT.r = (math.sin(timer*6)*0.1+math.cos(timer*1.2)*0.15)/12.0
        end
    end
}

  SMODS.Joker{
    key = 'psychokiller', --joker key
    loc_txt = { -- local text
        name = 'Headache',
        text = {
            '{C:mult}Mark{} a random card after',
            '{C:attention}drawing{} cards',
            '{C:mult}Marked{} cards permanently',
            'Gain {C:mult}+#1#{} Mult when {C:attention}Scored{}'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"PSYCHO KILLER", "SCP-9067"},
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 4, y = 4}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        mult = 1,
        additional = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.mult,center.ability.extra.additional}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
       if context.hand_drawn then
            local isit = 0
            while isit<40 do
                local rng = math.random(#G.hand.cards)
                if G.hand.cards[rng] then
                    if not G.hand.cards[rng].ability.marked_death then
                        isit=400
                        G.hand.cards[rng].ability.marked_death=1
                        G.hand.cards[rng]:juice_up()
                        card:juice_up()
                    end
                end
                isit=1+isit
            end
       end
       if context.individual and context.cardarea == G.play and context.other_card.ability.marked_death and context.other_card.ability.marked_death==1 then
            context.other_card:juice_up()
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.mult
            card_eval_status_text(
                context.other_card,
                'extra',
                nil, nil, nil,
                {message = "+"..card.ability.extra.mult .. " Mult", colour = G.C.RED, instant = true}
            )
       end
       if context.end_of_round and context.main_eval then
            self.remove_mark_cards()
        end
    end,
    remove_mark_cards = function()
        for _, card in ipairs(G.playing_cards) do
            if card.ability.marked_death then card.ability.marked_death=nil end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        self.remove_mark_cards()
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
    end
}

  SMODS.Joker{
    key = 'heaven', --joker key
    loc_txt = { -- local text
        name = 'Where nothing ever happens.',
        text = {
            {'{C:mult}+#1#{} Mult for each {C:mult}Debuffed{} card',
            'in {C:attention}Played Hand{}'},
            {'{X:inactive,C:white,s:0.85}Activatable{}',
            '{C:mult}Debuff{} a Playing card'}
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Heaven", "SCP-9720"},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 4, y = 3}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        mult = 3,
        additional = 0,
        lerp = 0
      }
    },
    scpb = {
        -- THIS ONE IS HEAVILY BASED UPON All In Jest github. go call their team goated because they absolutely are.
        ability_cost = function(self, card)
             return 0
        end,
        
        can_use_ability = function(self, card, context)
            
            if #G.hand.highlighted == 1 and G.STATE == G.STATES.SELECTING_HAND then
                if not G.hand.highlighted[1].debuff then
                    return true
                end
            end
            return false
        end,

        use_ability = function(self, card)
            G.hand.highlighted[1]:set_debuff(true)
            G.hand.highlighted[1]:juice_up()
            card:juice_up()
        end,
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.mult,center.ability.extra.additional,center.ability.extra.lerp}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
        local addmult = 0
        if context.before then
            for a = 1, #G.play.cards do
                if  G.play.cards[a].debuff then
                    G.play.cards[a]:juice_up(0.5, 0.4)
                    addmult = addmult + card.ability.extra.mult
                    G.E_MANAGER:add_event(Event{func = function()
                            card_eval_status_text(
                            G.play.cards[a],
                            'extra',
                            nil, nil, nil,
                            {message = '+'..card.ability.extra.mult, colour = G.C.MULT, instant = true})
                        return true end})
                end
            end
            
            card.ability.extra.additional = addmult
            if addmult>0 then
                return {
                    message = "STAMPED",
                    card = card
                }
            end
        end
        if context.joker_main and context.scoring_hand and card.ability.extra.additional>0 then
            local added = card.ability.extra.additional
            card.ability.extra.additional=0
            return {
                colour = G.C.RED,
                mult = added
            }
                
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if (self.discovered or card.bypass_discovery_center) and (not G.SETTINGS.paused) then
            card.ability.extra.lerp =  math.max(-G.ANIMATION_FPS * 0.009+card.ability.extra.lerp ,0.0)
            if #G.hand.highlighted == 1 and G.STATE == G.STATES.SELECTING_HAND and #G.jokers.highlighted>=1 then
                if not G.hand.highlighted[1].debuff and  G.jokers.highlighted[1] == card then
                    card.ability.extra.lerp =  math.min(G.ANIMATION_FPS * 0.012+card.ability.extra.lerp ,1.0)
                end
            end
            if card.ability.extra.lerp > 0.1 then
                local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.2) + 20
                card.children.center.CT.r = (math.sin(timer)*0.1+math.cos(timer*0.2)*0.05)*card.ability.extra.lerp
                card.children.center.CT.y = card.children.center.CT.y-math.sin(timer)/6.0*card.ability.extra.lerp
                card.children.center.CT.x = card.children.center.CT.x-math.cos(timer)/18.0*card.ability.extra.lerp
            end
        end
    end
}

  SMODS.Joker{
    key = 'burningdownthehouse', --joker key
    loc_txt = { -- local text
        name = 'Eye Opener',
        text = {
            {'{X:inactive,C:white,s:0.85}Activatable{}',
            'Costs {C:money}#2#${}',
            'Multiplies the Cost {X:money,C:white}X#3#{} for every use'},
            {'{C:mult}Destroys{} the selected {C:attention}Consumable{} card',
            'And {C:mult}Removes{} it from the pool.'}
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Burning Down the House", "SCP-9068"},
    atlas = 'Jokers', --atlas' key
    rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 7, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 4, y = 5}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        xmult = 1.5,
        cost=5,
        add_cost=1.5
      }
    },
    scpb = {
        -- THIS ONE IS HEAVILY BASED UPON All In Jest github. go call their team goated because they absolutely are.
        ability_cost = function(self, card)
             return card.ability.extra.cost
        end,
        
        can_use_ability = function(self, card, context)
            
            if to_big(G.GAME.dollars) >= to_big(card.ability.extra.cost) and #G.consumeables.highlighted == 1 then
                return true
            end
            return false
        end,

        use_ability = function(self, card)
            local carded = G.consumeables.highlighted[1]
            ease_dollars(-card.ability.extra.cost)
            card_eval_status_text(card, 'dollars', -card.ability.extra.cost)
            card.ability.extra.cost=math.floor(card.ability.extra.cost*card.ability.extra.add_cost)
            carded:start_dissolve({G.C.ORANGE}, nil, 1.6)
            G.GAME.banned_keys[carded.config.center_key] = true
            event({trigger = 'before', delay = 0.1, func = function()
                SMODS.destroy_cards(carded)
                return true end})
            card:juice_up()
        end,
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.xmult,center.ability.extra.cost,center.ability.extra.add_cost}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
       
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end,
    update = function(self, card)
        if not card.scpb_ability_cost_label or card.config.center.scpb:ability_cost(card) ~= card.scpb_ability_cost_label then
            card.scpb_ability_cost_label = card.config.center.scpb:ability_cost(card)
        end
    end
}
SMODS.DrawStep({
    key = 'test',
    order = -1000,
    func = function(card, layer)
         if card.config.center.key=="j_scpb_housewithpeople" and card.ability and tablecontains(G.jokers.cards,card) then
            if not card.children.houses then
                    local sprited = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 5, y = 3})
                    card.children.houses=sprited
                    sprited.states.visible = false

                    sprited = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 5, y = 3})
                    card.children.houses1=sprited
                    sprited.states.visible = false

                    sprited = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 5, y = 3})
                    card.children.houses2=sprited
                    sprited.states.visible = false

                    sprited = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 5, y = 2})
                    card.children.houses3=sprited
                    sprited.states.visible = false

                    sprited = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 5, y = 2})
                    card.children.houses4=sprited
                    sprited.states.visible = false
                    sprited = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 5, y = 2})
                    card.children.houses5=sprited
                    sprited.states.visible = false
                    sprited = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 5, y = 2})
                    card.children.houses6=sprited
                    sprited.states.visible = false
            end
            local houses = {card.children.houses,card.children.houses1,card.children.houses2,card.children.houses3,card.children.houses4,card.children.houses5,card.children.houses6}
            for i = 1, #houses do
                local sprited2=houses[i]
                card.children.center.CT.w = card.children.center.CT.w*(i/7.0)
                card.children.center.CT.h = card.children.center.CT.h*(i/7.0)
                card.children.center.CT.x=card.children.center.CT.x+((0.0-i)/14.0+0.5)*G.CARD_W
                card.children.center.CT.y=card.children.center.CT.y+((0.0-i)/14.0+0.5)*G.CARD_H
                sprited2:draw_shader('dissolve', nil, nil, nil, card.children.center, 0, 0)
                sprited2.role.draw_major = card
                card.children.center.CT.x=card.children.center.CT.x-((0.0-i)/14.0+0.5)*G.CARD_W
                card.children.center.CT.y=card.children.center.CT.y-((0.0-i)/14.0+0.5)*G.CARD_H
                card.children.center.CT.w = card.children.center.CT.w/(i/7.0)
                card.children.center.CT.h = card.children.center.CT.h/(i/7.0)
            end
        end

    end
})
SMODS.DrawStep({
    key = 'mark',
    order = 500,
    func = function(card, layer)
        if not card.ability.marked_death then
            if card.ability.marked_death_lerp then
                card.ability.marked_death_lerp=0.0
            end
            return
        else
            if card.ability.marked_death_lerp then
                card.ability.marked_death_lerp=card.ability.marked_death_lerp*0.95+0.05
            else
                card.ability.marked_death_lerp=0.0
            end
        end
        local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.15) + 20
        if not card.children.mark then
            card.children.mark = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['scpb_Jokers'], {x = 0, y = 6})
            card.children.mark.states.visible = false
        else
            local sinused = math.sin(timer*1.3)*0.3
            card.children.mark.CT.r = timer+sinused
            card.children.mark.T.x = card.T.x-card.ability.marked_death_lerp+1.0
            card.children.mark.T.y = card.T.y-card.ability.marked_death_lerp+1.0
            card.children.mark.CT.w = card.CT.w*card.ability.marked_death_lerp
            card.children.mark.CT.h = card.CT.h*card.ability.marked_death_lerp
            card.children.mark:draw_shader('dissolve', nil, nil, nil, card.children.mark, 0, 0)
        end
       
    end
})
  SMODS.Joker{
    key = 'alexthorley', --joker key
    loc_txt = { -- local text
        name = 'What',
        text = {
            'Why are you here??',
            'Who are they???'
        },
        --[[unlock = {
            'Be {C:legendary}cool{}',
        }]]
    },
    article_credits = {"Alex Thorley Eats a Bagel", "Alex Thorley Does Not get Away With It, Alex Thorley Gets away with It, BAROQUE, Alex Thorley Confuses a Guy, Magazine"},
    atlas = 'Jokers', --atlas' key
    rarity = 1, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 3, --cost
    unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered
    blueprint_compat = true, --can it be blueprinted/brainstormed/other
    eternal_compat = false, --can it be eternal
    perishable_compat = false, --can it be perishable
    pos = {x = 3, y = 0}, --position in atlas, starts at 0, scales by the atlas' card size (px and py): {x = 1, y = 0} would mean the sprite is 71 pixels to the right
    config = { 
      extra = {
        chips = 0,
        additional = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        
        return {vars = {center.ability.extra.chips,center.ability.extra.additional}}
    end,
    check_for_unlock = function(self, args)
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,
    
    calculate = function(self,card,context)
       
    end,
    add_to_deck = function(self, card, from_debuff)
        return
    end,
    in_pool = function(self,wawa,wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return false
    end,
    update = function(self, card)
        if self.discovered or card.bypass_discovery_center then
            local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.2) + 20
            card.children.center.CT.r = math.sin(timer*2.0)*0.5*math.cos(timer*3.2)
            --local timer = (G.TIMERS.REAL * G.ANIMATION_FPS * 0.2) + 20
            --card.children.center.CT.r = card.children.center.CT.r+math.cos(timer/3.0)/32.0
            --card.children.center.CT.y = card.children.center.CT.y-math.sin(timer)/6.0
            --card.children.center.scale.y = card.children.center.scale.y+math.sin(timer)/12.0
            --card.children.center.CT.x = card.children.center.CT.x-math.cos(timer)/18.0
            --card.children.center.scale.x = card.children.center.scale.x+math.cos(timer)/36.0
        end
    end
}

  
----------------------------------------------
------------MOD CODE END----------------------