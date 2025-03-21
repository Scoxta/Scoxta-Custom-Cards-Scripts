--22012024 Custom Koala Ashura
local s, id = GetID()

function s.initial_effect(c)
    --Fusion Procedure
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, 27134689, 69579761)
    Fusion.AddContactProc(c, s.contactfil, s.contactop, nil)
    c:SetSPSummonOnce(id)

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e1)
    
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_SINGLE)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    
    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e4:SetOperation(s.dop)
    c:RegisterEffect(e4)
end

function s.dop(e, tp, eg, ep, ev, re, rp)
    Duel.ChangeBattleDamage(ep, ev * 3)
end

s.listed_names = {27134689}
s.listed_series = {0x531}

function s.IsKoala(c)
    return c:IsCode(42129512) or c:IsCode(69579761) or c:IsCode(1371589) or c:IsCode(87685879) or c:IsCode(7243511) or c:IsCode(71759912) or c:IsCode(27134689)
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

function s.contactop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.spfilter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and s.IsKoala(c)
end

function s.target(e, tp, eg, ep, ev, re, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE + LOCATION_DECK + LOCATION_EXTRA, 0, 2, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, LOCATION_GRAVE + LOCATION_DECK + LOCATION_EXTRA)
end

function s.operation(e, tp, eg, ep, ev, re, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE + LOCATION_DECK + LOCATION_EXTRA, 0, 2, 2, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end
