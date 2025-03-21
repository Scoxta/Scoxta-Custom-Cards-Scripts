--Hydro Refresh

local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    -- Special Summon from Graveyard
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(function(_, tp) return Duel.GetLP(tp) <= 2000 end)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gthtg)
    e2:SetOperation(s.gthop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x1F4}
s.listed_names={19062025}

function s.filter(c)
    return c:IsSetCard(0x1F4) and c:IsAbleToDeck()
end

function s.thfilter(c)
    return c:IsSetCard(0x1F4) and c:IsMonster() and c:IsLevelBelow(4)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:GetLocation() == LOCATION_GRAVE and chkc:GetControler() == tp and s.filter(chkc) end
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 2) and Duel.IsExistingTarget(s.filter, tp, LOCATION_GRAVE, 0, 5, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.filter, tp, LOCATION_GRAVE, 0, 5, 5, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 3)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    if not tg or tg:FilterCount(Card.IsRelateToEffect, nil, e) ~= 5 then return end
    Duel.SendtoDeck(tg, nil, 0, REASON_EFFECT)
    local g = Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then Duel.ShuffleDeck(tp) end
    local ct = g:FilterCount(Card.IsLocation, nil, LOCATION_DECK + LOCATION_EXTRA)
    if ct == 5 then
        Duel.BreakEffect()
        Duel.Draw(tp, 3, REASON_EFFECT)
    end
end

function s.gthtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, LOCATION_GRAVE)
end

function s.gthop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    local tc = g:GetFirst()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        s.flipop(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    -- Add specific Hydro EXTRA monster from predefined list
    --19062025
    --local Htab = {TYPE_EXTRA,OPCODE_ISTYPE} -- Lista de códigos de carta que puedes expandir
    local Htab ={0x1F4,OPCODE_ISSETCARD,TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_AND,}
    local code = Duel.AnnounceCard(tp, table.unpack(Htab)) -- Permitir al jugador seleccionar una carta de Htab
     Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CODE)
    local token = Duel.CreateToken(tp, code)
    if token:IsAbleToDeck() then
        Duel.SendtoDeck(token, tp, 2, REASON_EFFECT)
        --Codigo para generar cartas en el cementerio
        --Duel.SendtoGrave(token, tp, 2, REASON_EFFECT)
    end
end