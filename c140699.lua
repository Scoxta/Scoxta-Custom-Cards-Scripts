local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Link Summon procedure
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DIVINE),1,1)
    --Effect on summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Return hand to deck if this card leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.retcon)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetFieldGroup(1-tp,LOCATION_DECK,0)
    Duel.SetTargetPlayer(1-tp)
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,#g)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local g=Duel.GetFieldGroup(p,LOCATION_DECK,0)
    if #g>0 then
        local ct=Duel.SendtoGrave(g,REASON_EFFECT)
        local c=e:GetHandler()
        if ct>0 then
            -- Aumentar el ataque de la carta igual al número de cartas enviadas al cementerio por 300
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(ct*400)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
            
            -- Devolver 5 cartas al azar del cementerio del oponente al deck
            s.returnToDeck(p,5)
        end
    end
end

function s.returnToDeck(tp,ct)
    local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=g:RandomSelect(tp,math.min(#g,ct))
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY) or e:GetHandler():IsReason(REASON_EFFECT)
end

function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
